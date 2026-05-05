import 'package:adaptive_dialog/adaptive_dialog.dart';
import './map_controller2.dart';
import './my_order_controller.dart';
import './shipment_types_controller.dart';
import './vehicle_category_controller.dart';
import 'package:biadgo/models/confirm_order_model.dart';
import 'package:biadgo/services/confirm_order_services.dart';
import 'package:biadgo/services/order_accepted_services.dart';
import 'package:biadgo/widgets/Orders/SearchingDriverScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ConfirmOrderController extends GetxController {
  final ConfirmOrderServices confirmOrderServices = ConfirmOrderServices();
  ShipmentTypesController get shipmentTypesController => Get.find<ShipmentTypesController>();
  VehicleCategoryController get vehicleCategoryController => Get.find<VehicleCategoryController>();
  MapController2 get mapController2 => Get.find<MapController2>();
  RxString selectedConfirmOrderTypeName = ''.obs;
  var dataConfirmOrder = Rxn<DataConfirmOrder>();
  RxBool isLoading = false.obs;
  final RxBool isOffline = false.obs;
  Rx<DateTime?> searchStartTime = Rx<DateTime?>(null);

  @override
  void onInit() {
    super.onInit();
    _loadState();
    
    // حفظ تلقائي عند التغيير
    ever(searchStartTime, (DateTime? val) {
      if (val != null) {
        GetStorage().write('search_start_time', val.toIso8601String());
      } else {
        GetStorage().remove('search_start_time');
      }
    });

    ever(dataConfirmOrder, (DataConfirmOrder? val) {
      if (val != null) {
        GetStorage().write('last_order_data', val.toJson());
      } else {
        GetStorage().remove('last_order_data');
      }
    });

    // تفقد إذا كان هناك بحث قيد الانتظار للانتقال إليه تلقائياً
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndResumeSearch();
    });
  }

  void _checkAndResumeSearch() {
    if (searchStartTime.value != null && dataConfirmOrder.value != null) {
      debugPrint("🚀 جاري استئناف جلسة البحث عن سائق...");

      // إعادة تفعيل استماع Pusher في حال كان مغلقاً
      OrderAcceptedServices().listenForNextAccepted();

      // الانتقال لشاشة البحث (وهي ستتعامل مع التايم آوت إذا مر الوقت)
      Get.to(() => const SearchingDriverScreen());
    }
  }

  void _loadState() {
    final box = GetStorage();
    final savedTime = box.read('search_start_time');
    if (savedTime != null) {
      searchStartTime.value = DateTime.tryParse(savedTime)?.toLocal();
    }
    final savedOrder = box.read('last_order_data');
    if (savedOrder != null && searchStartTime.value != null) {
      // إذا مر أكثر من 15 دقيقة على البحث، نعتبره منتهياً ونحذفه
      if (DateTime.now().difference(searchStartTime.value!).inMinutes > 15) {
        clearSearchSession();
        return;
      }
      try {
        dataConfirmOrder.value = DataConfirmOrder.fromJson(savedOrder);
      } catch (e) {
        debugPrint("Error loading saved order: $e");
      }
    }
  }

  void clearSearchSession() {
    searchStartTime.value = null;
    dataConfirmOrder.value = null;
    GetStorage().remove('search_start_time');
    GetStorage().remove('last_order_data');
  }

  Future<void> confirmOrder(BuildContext context) async {
    isLoading.value = true;
    try {
      // التحقق أولاً من عدم وجود طلب نشط
      final myOrderCtrl = Get.find<MyOrderController>();
      final hasActive = await myOrderCtrl.checkOngoingOrders();
      if (hasActive) {
        isLoading.value = false;
        await showOkAlertDialog(
          context: context,
          title: 'لديك طلب نشط بالفعل',
          message: 'يرجى إكمال طلبك الحالي أو إلغاؤه أولاً قبل إنشاء طلب جديد.',
          okLabel: 'حسناً',
        );
        return;
      }

      final vehicleTypeId = vehicleCategoryController.selectedVehicleId.value;
      final stCtrl = shipmentTypesController;
      final shipmentTypeId = stCtrl.selectedShipmentTypeId.value;

      final sourceAddress = mapController2.firstLocality.value.isNotEmpty
          ? mapController2.firstLocality.value
          : mapController2.firstAddress.value;
      final sourceLat =
          mapController2.firstLocation.value?.latitude.toString() ?? "";
      final sourceLng =
          mapController2.firstLocation.value?.longitude.toString() ?? "";

      final destinationAddress = mapController2.secondLocality.value.isNotEmpty
          ? mapController2.secondLocality.value
          : mapController2.secondAddress.value;
      final destinationLat =
          mapController2.secondLocation.value?.latitude.toString() ?? "";
      final destinationLng =
          mapController2.secondLocation.value?.longitude.toString() ?? "";

      final selectedType =
          stCtrl.shipmentTypes.firstWhereOrNull((t) => t.id == shipmentTypeId);
      final bool hasSecond = mapController2.secondLocation.value != null;
      int autoDispose;
      if (selectedType == null || selectedType.isAutoDispose == 0) {
        autoDispose = 0;
      } else {
        autoDispose = hasSecond ? 0 : 1;
      }

      final result = await confirmOrderServices.confirmOrder(
        sourceAddress: sourceAddress,
        sourceLat: sourceLat,
        sourceLng: sourceLng,
        destinationAddress: destinationAddress,
        destinationLat: destinationLat,
        destinationLng: destinationLng,
        shipmentTypeId: shipmentTypeId,
        vehicleTypeId: vehicleTypeId,
        paymentMethod: "cash",
        autoDispose: autoDispose,
      );

      if (result != null) {
        dataConfirmOrder.value = result;
        searchStartTime.value = DateTime.now(); // تعيين وقت بدء البحث
        await OrderAcceptedServices().listenForNextAccepted();
        
        mapController2.clearAllFields();
        clearAllFields();
        
        Get.to(() => const SearchingDriverScreen());
      }
    } catch (e) {
      String errorMessage = e.toString().replaceAll('Exception:', '').trim();
      if (errorMessage.isEmpty) errorMessage = "حدث خطأ غير متوقع، يرجى المحاولة لاحقاً";

      await showOkAlertDialog(
        context: context,
        title: "تنبيه",
        message: errorMessage,
        okLabel: "حسناً",
      );
    } finally {
      isLoading.value = false;
    }
  }

  void setSelectedConfirmOrderType(String name) {
    selectedConfirmOrderTypeName.value = name;
    debugPrint("تم اختيار طريقة الدفع: $name");
  }

  void clearAllFields() {
    vehicleCategoryController.selectedVehicleId.value = 0;
    shipmentTypesController.selectedShipmentTypeId.value = 0;
    selectedConfirmOrderTypeName.value = "";
    shipmentTypesController.selectedShipmentTypeId.value = 0;
    vehicleCategoryController.selectedVehicleId.value = 0;
    vehicleCategoryController.selectedCategoryId.value = 0;
  }

  Future<bool> validateAllFields(BuildContext context) async {
    if (mapController2.firstLocation.value == null) {
      await _showWarning(context, "يرجى اختيار النقطة الأولى");
      return false;
    }
    if (mapController2.secondLocation.value == null &&
        shipmentTypesController.shipmentTypes
                .firstWhereOrNull((type) =>
                    type.id ==
                    shipmentTypesController.selectedShipmentTypeId.value)
                ?.isAutoDispose ==
            0) {
      await _showWarning(context, "يرجى اختيار النقطة الثانية");
      return false;
    }
    if (shipmentTypesController.selectedShipmentTypeId.value == 0) {
      await _showWarning(context, "يرجى اختيار نوع البضاعة");
      return false;
    }
    if (vehicleCategoryController.selectedVehicleId.value == 0) {
      await _showWarning(context, "يرجى اختيار نوع المركبة (تأكد من توفر مركبات لهذا المسار)");
      return false;
    }
    return true;
  }

  Future<void> _showWarning(BuildContext context, String message) async {
    await showOkAlertDialog(
      context: context,
      title: "تنبيه",
      message: message,
      okLabel: "حسناً",
    );
  }
}

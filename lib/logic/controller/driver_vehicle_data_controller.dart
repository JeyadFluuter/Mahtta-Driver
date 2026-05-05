import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:piaggio_driver/logic/controller/me_controller.dart';
import 'package:piaggio_driver/model/driver_vehicle_data_model.dart';
import 'package:piaggio_driver/services/driver_vehcile_data_services.dart';
import 'package:piaggio_driver/views/home_screen.dart';

class DriverVehicleDataController extends GetxController {
  final DriverVehcileDataServices _driverVehcileDataServices =
      DriverVehcileDataServices();
  final meCtrl = Get.find<MeController>();
  final signupfromKey = GlobalKey<FormState>();
  final signupfromKey2 = GlobalKey<FormState>();
  final GetStorage getStorage = GetStorage();
  final TextEditingController vehicleBoardCtrl = TextEditingController();
  final TextEditingController plateNumberCtrl = TextEditingController();
  final TextEditingController chassisNumberCtrl = TextEditingController();
  final TextEditingController vehicleBrandCtrl = TextEditingController();
  final TextEditingController vehicleBrochureCtrl = TextEditingController();
  final TextEditingController vehicleModelCtrl = TextEditingController();
  final TextEditingController vehicleColorCtrl = TextEditingController();
  final TextEditingController modelCtrl = TextEditingController();
  final TextEditingController capacityCtrl = TextEditingController();

  final isLoading = false.obs;
  Rxn<DriverVehicleDataModel> driverVehicleDataModel =
      Rxn<DriverVehicleDataModel>();
  var errorMessage = ''.obs;
  final selectedVehicleId = 0.obs;
  String? token;
  var phonecache = ''.obs;
  var firstnamecache = ''.obs;
  var lastnamecache = ''.obs;
  var email = ''.obs;
  var images = ''.obs;
  var status = ''.obs;
  Rx<File?> documentImage = Rx<File?>(null);
  Rx<File?> vehicleFrontImage = Rx<File?>(null);
  Rx<File?> vehicleBackImage = Rx<File?>(null);
  Rx<File?> vehicleRightImage = Rx<File?>(null);
  Rx<File?> vehicleLeftImage = Rx<File?>(null);
  Rx<File?> vehicleInsideImage = Rx<File?>(null);
  Rx<File?> vehicleTrunkImage = Rx<File?>(null);

  Future<void> captureDocumentImage() async {
    final pickedFile = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 50, maxWidth: 800, maxHeight: 800);
    if (pickedFile != null) {
      documentImage.value = File(pickedFile.path);
      debugPrint("تم التقاط صورة المستند  : ${pickedFile.path}");
    }
  }

  Future<void> captureVehicleFrontImage() async {
    final pickedFile = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 50, maxWidth: 800, maxHeight: 800);
    if (pickedFile != null) {
      vehicleFrontImage.value = File(pickedFile.path);
      debugPrint("تم التقاط صورة السيارة من الأمام: ${pickedFile.path}");
    }
  }

  Future<void> captureVehicleBackImage() async {
    final pickedFile = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 50, maxWidth: 800, maxHeight: 800);
    if (pickedFile != null) {
      vehicleBackImage.value = File(pickedFile.path);
      debugPrint("تم التقاط صورة السيارة من الخلف: ${pickedFile.path}");
    }
  }

  Future<void> captureVehicleRightImage() async {
    final pickedFile = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 50, maxWidth: 800, maxHeight: 800);
    if (pickedFile != null) {
      vehicleRightImage.value = File(pickedFile.path);
      debugPrint("تم التقاط صورة السيارة من اليمين: ${pickedFile.path}");
    }
  }

  Future<void> captureVehicleLeftImage() async {
    final pickedFile = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 50, maxWidth: 800, maxHeight: 800);
    if (pickedFile != null) {
      vehicleLeftImage.value = File(pickedFile.path);
      debugPrint("تم التقاط صورة السيارة من اليسار: ${pickedFile.path}");
    }
  }

  Future<void> captureVehicleInsideImage() async {
    final pickedFile = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 50, maxWidth: 800, maxHeight: 800);
    if (pickedFile != null) {
      vehicleInsideImage.value = File(pickedFile.path);
      debugPrint("تم التقاط صورة السيارة من الداخل: ${pickedFile.path}");
    }
  }

  Future<void> captureVehicleTrunkImage() async {
    final pickedFile = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 50, maxWidth: 800, maxHeight: 800);
    if (pickedFile != null) {
      vehicleTrunkImage.value = File(pickedFile.path);
      debugPrint("تم التقاط صورة السيارة من الصندوق: ${pickedFile.path}");
    }
  }

  Future<void> driverVehicleData({
    required String vehicleType,
    required String vehicleBoard,
    required String vehicleColor,
    required String plateNumber,
    required String vehicleBrochure,
    required String chassisNumber,
    required String model,
    required String capacity,
  }) async {
    bool isValidate = signupfromKey2.currentState!.validate();
    if (!isValidate) {
      return;
    }
    try {
      isLoading(true);
      errorMessage.value = '';
      String base64DocumentImage = "";
      String base64VehicleFront = "";
      String base64VehicleBack = "";
      String base64VehicleRight = "";
      String base64VehicleLeft = "";
      String base64VehicleInside = "";
      String base64VehicleTrunk = "";

      if (documentImage.value != null) {
        base64DocumentImage = 'data:image/jpeg;base64,' +
            base64Encode(documentImage.value!.readAsBytesSync());
      }
      if (vehicleFrontImage.value != null) {
        base64VehicleFront = 'data:image/jpeg;base64,' +
            base64Encode(vehicleFrontImage.value!.readAsBytesSync());
      }
      if (vehicleBackImage.value != null) {
        base64VehicleBack = 'data:image/jpeg;base64,' +
            base64Encode(vehicleBackImage.value!.readAsBytesSync());
      }
      if (vehicleRightImage.value != null) {
        base64VehicleRight = 'data:image/jpeg;base64,' +
            base64Encode(vehicleRightImage.value!.readAsBytesSync());
      }
      if (vehicleLeftImage.value != null) {
        base64VehicleLeft = 'data:image/jpeg;base64,' +
            base64Encode(vehicleLeftImage.value!.readAsBytesSync());
      }
      if (vehicleInsideImage.value != null) {
        base64VehicleInside = 'data:image/jpeg;base64,' +
            base64Encode(vehicleInsideImage.value!.readAsBytesSync());
      }
      if (vehicleTrunkImage.value != null) {
        base64VehicleTrunk = 'data:image/jpeg;base64,' +
            base64Encode(vehicleTrunkImage.value!.readAsBytesSync());
      }

      debugPrint("📸 Images sizes (Base64) - Vehicle:");
      debugPrint("- Document: ${base64DocumentImage.length}");
      debugPrint("- Front: ${base64VehicleFront.length}");
      debugPrint("- Back: ${base64VehicleBack.length}");
      debugPrint("- Right: ${base64VehicleRight.length}");
      debugPrint("- Left: ${base64VehicleLeft.length}");
      debugPrint("- Inside: ${base64VehicleInside.length}");
      debugPrint("- Trunk: ${base64VehicleTrunk.length}");

      final result = await _driverVehcileDataServices.driverVehcileData(
        vehicle_type: selectedVehicleId.value.toString(),
        plate_number: plateNumberCtrl.text,
        chassis_number: chassisNumberCtrl.text,
        vehicle_brand: vehicleBrandCtrl.text,
        vehicle_brochure: vehicleBrandCtrl.text,
        vehicle_color: vehicleColorCtrl.text,
        model: vehicleModelCtrl.text,
        capacity: capacityCtrl.text,
        insurance_document: base64DocumentImage,
        vehicle_front_image: base64VehicleFront,
        vehicle_back_image: base64VehicleBack,
        vehicle_right_image: base64VehicleRight,
        vehicle_left_image: base64VehicleLeft,
        vehicle_inside_image: base64VehicleInside,
        vehicle_trunk_image: base64VehicleTrunk,
      );

      if (result != null) {
        driverVehicleDataModel.value = result as DriverVehicleDataModel?;
        await meCtrl.refreshMe();
        Get.snackbar("نجاح", "تم إضافة بيانات المركبة بنجاح");
        Get.offAll(() => HomeScreen());
      } else {
        errorMessage.value = 'فشل في إضافة بيانات المركبة. تحقق من البيانات.';
        Get.snackbar(
            "إضافة بيانات المركبة", "هناك خطأ في عملية إضافة البيانات");
      }
    } catch (e) {
      errorMessage.value = 'حدث خطأ: $e';
    } finally {
      isLoading(false);
    }
  }
}

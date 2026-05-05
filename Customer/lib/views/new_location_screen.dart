import 'package:biadgo/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_theme.dart';
import '../logic/controller/new_location_controller.dart';

class NewLocationScreen extends StatefulWidget {
  const NewLocationScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<NewLocationScreen> {
  static const LatLng _initialLocation =
      LatLng(32.884163656898494, 13.185209436775189);
  LatLng? _cameraCenter;

  final NewLocationController controller = Get.put(NewLocationController());

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text("تحديد المواقع"),
          backgroundColor: Get.theme.primaryColor,
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingSmall),
          child: Form(
            key: controller.addlocationFormKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              children: [
                _buildTextField(
                  label: "إسم مكان الحمولة",
                  hintText: " الرجاء إدخال إسم مكان الحمولة",
                  textController: controller.nameSourceController,
                  readOnly: false,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "الرجاء إدخال إسم مكان الحمولة";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.paddingSmall),
                _buildTextField(
                  label: "مكان الحمولة",
                  hintText: "الرجاء إدخال موقع مكان الحمولة",
                  textController: controller.pickupController,
                  readOnly: true,
                  onTap: () {
                    setState(() {
                      controller.selectingPickup = true;
                      controller.selectingDropoff = false;
                    });
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "الرجاء إدخال موقع مكان الحمولة";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.paddingSmall),
                _buildTextField(
                  label: "إسم مكان تفريغ الحمولة",
                  hintText: " الرجاء إدخال إسم مكان تفريغ الحمولة",
                  textController: controller.nameDestinationController,
                  readOnly: false,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "الرجاء إدخال إسم مكان تفريغ الحمولة";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.paddingSmall),
                _buildTextField(
                  label: "مكان تفريغ الحمولة",
                  hintText: " الرجاء إدخال موقع مكان تفريغ الحمولة",
                  textController: controller.dropoffController,
                  readOnly: true,
                  onTap: () {
                    setState(() {
                      controller.selectingPickup = false;
                      controller.selectingDropoff = true;
                    });
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "الرجاء إدخال موقع مكان تفريغ الحمولة";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.paddingMediumX),
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: GoogleMap(
                          initialCameraPosition: const CameraPosition(
                            target: _initialLocation,
                            zoom: 15,
                          ),
                          onCameraMove: (position) {
                            _cameraCenter = position.target;
                          },
                          onCameraIdle: () {
                            if (_cameraCenter != null) {
                              setState(() {
                                if (controller.selectingPickup) {
                                  controller.pickupLocation = _cameraCenter;
                                  final lat = _cameraCenter!.latitude;
                                  final lng = _cameraCenter!.longitude;
                                  controller.pickupController.text = "$lat, $lng";
                                  controller.pickupLatController.text = lat.toString();
                                  controller.pickupLngController.text = lng.toString();
                                } else if (controller.selectingDropoff) {
                                  controller.dropoffLocation = _cameraCenter;
                                  final lat = _cameraCenter!.latitude;
                                  final lng = _cameraCenter!.longitude;
                                  controller.dropoffController.text = "$lat, $lng";
                                  controller.dropoffLatController.text = lat.toString();
                                  controller.dropoffLngController.text = lng.toString();
                                }
                              });
                            }
                          },
                          markers: {
                            if (controller.pickupLocation != null && !controller.selectingPickup)
                              Marker(
                                markerId: const MarkerId('pickup'),
                                position: controller.pickupLocation!,
                                icon: BitmapDescriptor.defaultMarkerWithHue(
                                    AppThemes.pinAHue),
                              ),
                            if (controller.dropoffLocation != null && !controller.selectingDropoff)
                              Marker(
                                markerId: const MarkerId('dropoff'),
                                position: controller.dropoffLocation!,
                                icon: BitmapDescriptor.defaultMarkerWithHue(
                                    AppThemes.pinBHue),
                              ),
                          },
                        ),
                      ),
                      // الدبوس العائم في المنتصف
                      if (controller.selectingPickup || controller.selectingDropoff)
                        Positioned.fill(
                          child: Container(
                            alignment: Alignment.center,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 25.0),
                              child: Icon(
                                Icons.location_on,
                                size: 50,
                                color: controller.selectingPickup
                                    ? AppThemes.pinAColor
                                    : AppThemes.pinBColor,
                              ),
                            ),
                          ),
                        ),
                      // رسالة توجيهية للمستخدم
                      if (controller.selectingPickup || controller.selectingDropoff)
                        Positioned(
                          top: 16,
                          left: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: .9),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                            ),
                            child: Text(
                              controller.selectingPickup
                                  ? "حرك الخريطة لتحديد موقع الحمولة"
                                  : "حرك الخريطة لتحديد موقع التفريغ",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppThemes.primaryNavy,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                    child: Button(
                      name: "حفظ المواقع",
                      onPressed: () {
                        controller.addnewlocation();
                      },
                      size: Size(
                        AppDimensions.screenWidth * 0.8,
                        AppDimensions.buttonHeight,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hintText,
    required TextEditingController textController,
    required String? Function(String?) validator,
    required bool readOnly,
    VoidCallback? onTap,
  }) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: TextFormField(
        controller: textController,
        readOnly: readOnly,
        onTap: onTap,
        cursorColor: Get.theme.primaryColor,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 13, color: Colors.black),
          hintText: hintText,
          hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Get.theme.primaryColor, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Get.theme.primaryColor, width: 2),
          ),
        ),
        validator: validator,
      ),
    );
  }
}

import 'package:get/get.dart';
import 'package:flutter/material.dart';

class Dropdown extends StatefulWidget {
  const Dropdown({super.key});

  @override
  _LocationDropdownState createState() => _LocationDropdownState();
}

class _LocationDropdownState extends State<Dropdown> {
  String _selectedLocation = "شركة النوفليين"; // ✅ الموقع الافتراضي

  // ✅ قائمة المواقع المتاحة
  final List<String> _locations = [
    "شركة النوفليين",
    "شركة الهضبة",
    "شركة السراج",
    "شركة حي الأندلس",
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // ✅ زر القائمة المنسدلة
        PopupMenuButton<String>(
          icon: Icon(Icons.keyboard_arrow_down, color: Get.theme.primaryColor, size: 20),
          onSelected: (String value) {
            setState(() {
              _selectedLocation = value; // ✅ تغيير النص بعد الاختيار
            });
          },
          itemBuilder: (BuildContext context) {
            return _locations.map((String location) {
              return PopupMenuItem<String>(
                value: location,
                child: Text(location, style: TextStyle(color: Get.theme.primaryColor)),
              );
            }).toList();
          },
        ),

        // ✅ أيقونة الموقع
        Icon(Icons.location_on, color: Get.theme.primaryColor, size: 18),

        const SizedBox(width: 5),

        // ✅ اسم الموقع المختار
        Text(
          _selectedLocation,
          style: TextStyle(
            color: Get.theme.primaryColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

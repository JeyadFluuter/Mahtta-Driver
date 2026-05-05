// import 'package:biadgo/constants/app_dimensions.dart';
// // import 'package:biadgo/logic/controller/confirm_order_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class InformationPaymentScreen extends StatelessWidget {
//   InformationPaymentScreen({super.key});

//   final ConfirmOrderController confirmOrderController = Get.put(ConfirmOrderController());

//   @override
//   Widget build(BuildContext context) {
//     return Directionality(
//       textDirection: TextDirection.rtl,
//       child: Scaffold(
//         body: Padding(
//           padding: EdgeInsets.all(AppDimensions.paddingMedium * 2),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 "اختر طريقة الدفع",
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Get.theme.primaryColor,
//                 ),
//               ),
//               const SizedBox(height: 16),

//               Expanded(
//                 child: ListView(
//                   children: [
//                     _buildPaymentOption("cash", Icons.money, Colors.green),
//                     _buildPaymentOption("الدفع عبر البطاقة", Icons.credit_card, Colors.blue),
//                   ],
//                 ),
//               ),

//               // ✅ عرض طريقة الدفع المختارة
//               Obx(() {
//                 return Text(
//                   "طريقة الدفع المختارة: ${confirmOrderController.selectedConfirmOrderTypeName.value}",
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Get.theme.primaryColor),
//                 );
//               }),

//               const SizedBox(height: 20),

//               // ✅ زر إنهاء الطلب

//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildPaymentOption(String title, IconData icon, Color color) {
//     return GestureDetector(
//       onTap: () {
//         confirmOrderController.setSelectedConfirmOrderType(title); // ✅ تمرير اسم طريقة الدفع عند الاختيار
//       },
//       child: Obx(() {
//         final isSelected = confirmOrderController.selectedConfirmOrderTypeName.value == title;

//         return Container(
//           margin: const EdgeInsets.symmetric(vertical: 8),
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: isSelected ? Get.theme.primaryColor.withOpacity(0.2) : Colors.white, // ✅ تغيير لون الخلفية إذا كان مختارًا
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(color: isSelected ? primarycolor : Colors.transparent, width: 2),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.grey.withOpacity(0.2),
//                 blurRadius: 5,
//                 spreadRadius: 2,
//               ),
//             ],
//           ),
//           child: Row(
//             children: [
//               Icon(icon, color: color, size: 28),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Text(
//                   title,
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: Get.theme.primaryColor,
//                   ),
//                 ),
//               ),
//               Icon(Icons.check, color: isSelected ? primarycolor : Colors.transparent),
//             ],
//           ),
//         );
//       }),
//     );
//   }
// }

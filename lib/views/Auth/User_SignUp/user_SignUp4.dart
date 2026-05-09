import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piaggio_driver/constants/app_dimensions.dart';
import 'package:piaggio_driver/constants/app_theme.dart';
import 'package:piaggio_driver/logic/controller/all_shipmetn_types_signUp_controller.dart';
import 'package:piaggio_driver/logic/controller/auth_controller.dart';
import 'package:piaggio_driver/model/all_shipment_types_signUp_model.dart';
import 'package:shimmer/shimmer.dart';

class UserSignup4 extends StatelessWidget {
  UserSignup4({super.key});

  final ctrl = Get.put(AllShipmentTypesSignupController());
  final auth = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Form(
        key: auth.loginfromKey3,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            right: AppDimensions.paddingMedium,
            top: AppDimensions.paddingMedium,
            bottom: 40, // Space for the footer
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'أنواع البضاعة',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
              FormField<bool>(
                validator: (_) => ctrl.selected.isEmpty
                    ? 'اختر نوعًا واحدًا على الأقل'
                    : null,
                builder: (state) => InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _openSheet(context),
                  child: Obx(() {
                    final chosen = ctrl.selected;
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: state.hasError
                              ? AppThemes.light.colorScheme.error
                              : AppThemes.primaryNavy.withOpacity(0.1),
                        ),
                        color: Colors.white,
                        boxShadow: const [
                          BoxShadow(
                              blurRadius: 4,
                              color: Colors.black12,
                              offset: Offset(0, 2))
                        ],
                      ),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: -4,
                        children: chosen.isEmpty
                            ? const [
                                Text('اختر نوع الشحن',
                                    style: TextStyle(color: Colors.grey))
                              ]
                            : chosen
                                .map((e) => Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      child: Chip(
                                        label: Text(e.name),
                                        deleteIcon: const Icon(Icons.cancel,
                                            size: 18, color: AppThemes.primaryNavy),
                                        onDeleted: () => ctrl.toggle(e),
                                        backgroundColor:
                                            AppThemes.primaryNavy.withOpacity(.08),
                                        side: BorderSide.none,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        labelStyle: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: AppThemes.primaryNavy),
                                      ),
                                    ))
                                .toList(),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingLarge),
              const Text("- ملاحظة :",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: AppDimensions.paddingMedium),
              Padding(
                padding:
                    const EdgeInsets.only(right: AppDimensions.paddingSmall),
                child: Text("يمكنك التعديل على أنواع البضاعة من داخل التطبيق",
                    style:
                        TextStyle(fontSize: 14, color: AppThemes.primaryNavy.withOpacity(0.6))),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: .8,
        minChildSize: .4,
        maxChildSize: .95,
        builder: (_, scrollCtrl) => Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppThemes.primaryNavy.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Text('اختر نوع / أنواع البضاعة',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppThemes.primaryNavy,
                        )),
                const SizedBox(height: 16),
                Expanded(
                  child: Obx(() {
                    if (ctrl.isLoading.value) {
                      return GridView.builder(
                        controller: scrollCtrl,
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: 6,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisExtent: 115,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemBuilder: (_, i) => Shimmer.fromColors(
                          baseColor: Colors.grey.shade300,
                          highlightColor: Colors.grey.shade100,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      );
                    }

                    final allItems = ctrl.types;
                    return GridView.builder(
                      controller: scrollCtrl,
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: allItems.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisExtent: 115,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemBuilder: (_, i) {
                        final item = allItems[i];
                        return Obx(() {
                          final isChosen =
                              ctrl.selected.any((e) => e.id == item.id);
                          return GestureDetector(
                            onTap: () => ctrl.toggle(item),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isChosen
                                      ? AppThemes.primaryOrange
                                      : AppThemes.primaryNavy.withOpacity(0.1),
                                  width: isChosen ? 2 : 1,
                                ),
                                color: isChosen
                                    ? AppThemes.primaryOrange.withOpacity(.05)
                                    : Colors.white,
                              ),
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _typeImage(item, isChosen),
                                  const SizedBox(height: 10),
                                  Text(
                                    item.name,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isChosen
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: isChosen
                                          ? AppThemes.primaryOrange
                                          : AppThemes.primaryNavy.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        });
                      },
                    );
                  }),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppThemes.primaryOrange,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('تم الموافقة',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
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

  Widget _typeImage(AllShipmentTypesSignupModel t, bool chosen) {
    if (t.image.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          t.image,
          height: 42, // ارتفاع الصورة 42px
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.inventory_2, size: 42),
        ),
      );
    }
    return Icon(Icons.inventory_2,
        size: 42, color: chosen ? AppThemes.primaryNavy : Colors.grey);
  }
}

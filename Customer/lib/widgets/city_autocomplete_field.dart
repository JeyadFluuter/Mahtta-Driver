import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CityAutocompleteField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final String? Function(String?)? validator;
  final double borderRadius;
  final double iconSize;

  const CityAutocompleteField({
    Key? key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.validator,
    this.borderRadius = 12.0,
    this.iconSize = 20.0,
  }) : super(key: key);

  @override
  State<CityAutocompleteField> createState() => _CityAutocompleteFieldState();
}

class _CityAutocompleteFieldState extends State<CityAutocompleteField> {
  static const List<String> libyanCities = [
    'طرابلس', 'بنغازي', 'مصراتة', 'الزاوية', 'البيضاء', 'طبرق', 'زليتن', 'الخمس',
    'صبراتة', 'سبها', 'سرت', 'أجدابيا', 'درنة', 'ترهونة', 'غريان', 'المرج', 'يفرن',
    'نالوت', 'الزنتان', 'زواره', 'بني وليد', 'مسلاتة', 'رقدالين', 'صرمان', 'غدامس',
    'غات', 'أوباري', 'مرزق', 'القطرون', 'براك الشاطئ', 'هون', 'ودان', 'سوكنة',
    'جالو', 'أوجلة', 'إجخرة', 'الكفرة', 'تازربو', 'شحات', 'سوسة', 'القبة', 'توكرة',
    'البريقة', 'راس لانوف', 'بن جواد', 'هراوة', 'تاجوارء', 'جنزور', 'القره بوللي',
    'الأصابعة', 'ككلة', 'جادو', 'الرجبان', 'العجيلات', 'الجميل', 'القلعة', 'وازن',
    'درج', 'إدري', 'تراغن', 'الغريفة', 'العوينات', 'امساعد', 'الأبيار', 'سلوق', 'قمينس'
  ];

  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => RawAutocomplete<String>(
        textEditingController: widget.controller,
        focusNode: _focusNode,
        optionsBuilder: (TextEditingValue textEditingValue) {
          if (textEditingValue.text.isEmpty) {
            return libyanCities;
          }
          return libyanCities.where((String option) {
            return option.contains(textEditingValue.text);
          });
        },
        onSelected: (String selection) {
          widget.controller.text = selection;
        },
        fieldViewBuilder: (
          BuildContext context,
          TextEditingController textEditingController,
          FocusNode focusNode,
          VoidCallback onFieldSubmitted,
        ) {
          return TextFormField(
            controller: textEditingController,
            focusNode: focusNode,
            validator: (value) {
              if (value != null && value.isNotEmpty && !libyanCities.contains(value)) {
                return 'يرجى اختيار مدينة صحيحة من القائمة';
              }
              if (widget.validator != null) {
                return widget.validator!(value);
              }
              return null;
            },
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 15),
            decoration: InputDecoration(
              prefixIcon: Icon(widget.icon, color: Colors.grey.shade400, size: widget.iconSize),
              suffixIcon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
              hintText: widget.hint,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                borderSide: BorderSide(color: Get.theme.primaryColor, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                borderSide: const BorderSide(color: Colors.red, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
            ),
            cursorColor: Get.theme.primaryColor,
          );
        },
        optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<String> onSelected, Iterable<String> options) {
          return Align(
            alignment: Alignment.topRight,
            child: Material(
              elevation: 4.0,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              color: Colors.white,
              child: SizedBox(
                width: constraints.maxWidth,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 250),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (BuildContext context, int index) {
                      final String option = options.elementAt(index);
                      return InkWell(
                        onTap: () {
                          onSelected(option);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          child: Text(
                            option,
                            textAlign: TextAlign.right,
                            style: const TextStyle(fontSize: 15, color: Colors.black87),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

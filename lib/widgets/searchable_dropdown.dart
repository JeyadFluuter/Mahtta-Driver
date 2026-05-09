import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piaggio_driver/constants/app_theme.dart';

class SearchableDropdown<T> extends StatefulWidget {
  final String hint;
  final T? value;
  final List<T> items;
  final String Function(T) itemAsString;
  final void Function(T?) onChanged;
  final String? Function(T?)? validator;
  final IconData? icon;

  const SearchableDropdown({
    super.key,
    required this.hint,
    required this.value,
    required this.items,
    required this.itemAsString,
    required this.onChanged,
    this.validator,
    this.icon,
  });

  @override
  State<SearchableDropdown<T>> createState() => _SearchableDropdownState<T>();
}

class _SearchableDropdownState<T> extends State<SearchableDropdown<T>> {
  T? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.value;
  }

  @override
  void didUpdateWidget(SearchableDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _selectedValue = widget.value;
    }
  }

  void _showBottomSheet() {
    Get.bottomSheet(
      _SearchableBottomSheet<T>(
        title: widget.hint,
        items: widget.items,
        itemAsString: widget.itemAsString,
        selectedValue: _selectedValue,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    ).then((result) {
      if (result != null && result is T) {
        setState(() {
          _selectedValue = result;
        });
        widget.onChanged(result);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FormField<T>(
      validator: widget.validator,
      initialValue: _selectedValue,
      builder: (FormFieldState<T> state) {
        // Ensure state updates when internal value changes
        if (state.value != _selectedValue) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            state.didChange(_selectedValue);
          });
        }
        
        final hasError = state.hasError;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: _showBottomSheet,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: hasError
                        ? AppThemes.light.colorScheme.error
                        : AppThemes.primaryNavy.withOpacity(0.1),
                    width: hasError ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          if (widget.icon != null) ...[
                            Icon(widget.icon, color: AppThemes.primaryNavy.withOpacity(0.4), size: 20),
                            const SizedBox(width: 12),
                          ],
                          Expanded(
                            child: Text(
                              _selectedValue != null &&
                                      (_selectedValue is int ? _selectedValue != 0 : _selectedValue.toString().isNotEmpty)
                                  ? widget.itemAsString(_selectedValue as T)
                                  : widget.hint,
                              style: TextStyle(
                                fontSize: 14,
                                color: _selectedValue != null &&
                                        (_selectedValue is int ? _selectedValue != 0 : _selectedValue.toString().isNotEmpty)
                                    ? AppThemes.primaryNavy
                                    : AppThemes.primaryNavy.withOpacity(0.4),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppThemes.primaryNavy.withOpacity(0.4),
                    ),
                  ],
                ),
              ),
            ),
            if (hasError)
              Padding(
                padding: const EdgeInsets.only(top: 8, right: 12),
                child: Text(
                  state.errorText!,
                  style: TextStyle(
                    color: AppThemes.light.colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SearchableBottomSheet<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final String Function(T) itemAsString;
  final T? selectedValue;

  const _SearchableBottomSheet({
    required this.title,
    required this.items,
    required this.itemAsString,
    this.selectedValue,
  });

  @override
  State<_SearchableBottomSheet<T>> createState() => _SearchableBottomSheetState<T>();
}

class _SearchableBottomSheetState<T> extends State<_SearchableBottomSheet<T>> {
  late List<T> filteredItems;
  final TextEditingController searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredItems = widget.items;
  }

  void filterSearchResults(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredItems = widget.items;
      });
      return;
    }
    setState(() {
      filteredItems = widget.items
          .where((item) => widget.itemAsString(item).toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppThemes.primaryNavy,
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close_rounded, color: Colors.grey),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: searchCtrl,
              onChanged: filterSearchResults,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: 'بحث...',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: AppThemes.primaryOrange),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: filteredItems.isEmpty
                ? const Center(
                    child: Text('لا توجد نتائج', style: TextStyle(color: Colors.grey)),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    itemCount: filteredItems.length,
                    separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade100),
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      final isSelected = item == widget.selectedValue;
                      return ListTile(
                        title: Text(
                          widget.itemAsString(item),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? AppThemes.primaryOrange : AppThemes.primaryNavy,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle_rounded, color: AppThemes.primaryOrange)
                            : null,
                        onTap: () => Get.back(result: item),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

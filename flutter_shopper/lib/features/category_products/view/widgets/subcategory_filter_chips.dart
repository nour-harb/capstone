import 'package:flutter/material.dart';
import 'package:flutter_shopper/core/product/models/filter_item.dart';
import 'package:flutter_shopper/core/theme/app_pallete.dart';

class SubcategoryFilterChips extends StatelessWidget {
  final List<FilterItem> subcategories;
  final int? selectedSubcategoryId;
  final ValueChanged<int?> onSubcategoryToggle;
  final bool isLoading;

  const SubcategoryFilterChips({
    super.key,
    required this.subcategories,
    required this.selectedSubcategoryId,
    required this.onSubcategoryToggle,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (subcategories.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 56,
      decoration: const BoxDecoration(
        color: Pallete.whiteColor,
        border: Border(
          bottom: BorderSide(color: Pallete.borderColor, width: 0.5),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: subcategories.length,
        itemBuilder: (context, index) {
          final subcategory = subcategories[index];
          final isSelected = selectedSubcategoryId == subcategory.id;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Text(subcategory.name),
              selected: isSelected,
              onSelected: isLoading
                  ? null
                  : (_) => onSubcategoryToggle(subcategory.id),
              labelStyle: TextStyle(
                color: isSelected ? Pallete.whiteColor : Pallete.blackColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }
}

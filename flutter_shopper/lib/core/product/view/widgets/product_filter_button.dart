import 'package:flutter/material.dart';

class ProductFilterButton extends StatelessWidget {
  final int filterCount;
  final VoidCallback onTap;

  const ProductFilterButton({
    super.key,
    required this.filterCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasFilters = filterCount > 0;

    return IconButton(
      icon: Badge(
        isLabelVisible: hasFilters,
        label: Text('$filterCount'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        textColor: Theme.of(context).colorScheme.onPrimary,
        child: const Icon(Icons.tune_rounded),
      ),
      onPressed: onTap,
    );
  }
}

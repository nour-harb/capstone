import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_shopper/core/product/view/widgets/product_list_view.dart';
import 'package:flutter_shopper/core/product/view/widgets/product_filter_button.dart';
import 'package:flutter_shopper/core/product/view/widgets/product_filter_sheet.dart';
import 'package:flutter_shopper/features/category_products/view/widgets/subcategory_filter_chips.dart';
import 'package:flutter_shopper/features/category_products/viewmodel/category_product_viewmodel.dart';
import 'package:flutter_shopper/core/providers/navigation_notifier.dart';

class ProductsScreen extends ConsumerWidget {
  final int menuCategoryId;
  final String menuCategoryName;

  const ProductsScreen({
    super.key,
    required this.menuCategoryId,
    required this.menuCategoryName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(
      categoryProductViewModelProvider(menuCategoryId: menuCategoryId),
    );

    final vm = ref.read(
      categoryProductViewModelProvider(menuCategoryId: menuCategoryId).notifier,
    );

    final navigationNotifier = ref.read(navigationProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(menuCategoryName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            navigationNotifier.setBottomBarVisible(true);
            Navigator.of(context).pop();
          },
        ),
        actions: [
          Opacity(
            opacity: state.isLoading ? 0.5 : 1.0,
            child: IgnorePointer(
              ignoring: state.isLoading,
              child: ProductFilterButton(
                filterCount: vm.activeFilterCount,
                onTap: () async {
                  // hide the bottom bar before opening the sheet
                  navigationNotifier.setBottomBarVisible(false);

                  // open the sheet and wait for it to be dismissed
                  await showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) =>
                        ProductFilterSheet(viewModel: vm, state: state),
                  );

                  // restore the bottom bar visibility after the sheet is closed
                  navigationNotifier.setBottomBarVisible(true);
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          if (state.availableSubcategories.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: SubcategoryFilterChips(
                subcategories: state.availableSubcategories,
                selectedSubcategoryId: state.currentFilter.subcategoryId,
                onSubcategoryToggle: vm.filterBySubcategory,
                isLoading: state.isLoading,
              ),
            ),
          Expanded(
            child: ProductListView(state: state, viewModel: vm),
          ),
        ],
      ),
    );
  }
}

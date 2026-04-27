import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_shopper/core/product/view/widgets/product_list_view.dart';
import 'package:flutter_shopper/core/product/view/widgets/product_filter_button.dart';
import 'package:flutter_shopper/core/product/view/widgets/product_filter_sheet.dart';
import 'package:flutter_shopper/features/search_products/viewmodel/search_product_viewmodel.dart';
import 'package:flutter_shopper/core/providers/navigation_notifier.dart';

class SearchResultsPage extends ConsumerWidget {
  final String queryText;
  final String gender;

  const SearchResultsPage({
    super.key,
    required this.queryText,
    required this.gender,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(
      searchProductViewModelProvider(queryText: queryText, gender: gender),
    );

    final vm = ref.read(
      searchProductViewModelProvider(
        queryText: queryText,
        gender: gender,
      ).notifier,
    );

    final navigationNotifier = ref.read(navigationProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(queryText.toUpperCase()),
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
                  navigationNotifier.setBottomBarVisible(false);

                  await showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) =>
                        ProductFilterSheet(viewModel: vm, state: state),
                  );

                  navigationNotifier.setBottomBarVisible(true);
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ProductListView(state: state, viewModel: vm),
    );
  }
}

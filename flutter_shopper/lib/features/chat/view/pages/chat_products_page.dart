import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_shopper/core/product/view/widgets/product_filter_button.dart';
import 'package:flutter_shopper/core/product/view/widgets/product_filter_sheet.dart';
import 'package:flutter_shopper/core/product/view/widgets/product_list_view.dart';
import 'package:flutter_shopper/core/providers/navigation_notifier.dart';
import 'package:flutter_shopper/features/chat/models/chat_product_query.dart';
import 'package:flutter_shopper/features/chat/models/chat_product_state.dart';
import 'package:flutter_shopper/features/chat/viewmodel/chat_products_viewmodel.dart';

class ChatProductsPage extends ConsumerStatefulWidget {
  final String title;
  final List<int> productIds;

  const ChatProductsPage({
    super.key,
    required this.title,
    required this.productIds,
  });

  @override
  ConsumerState<ChatProductsPage> createState() => _ChatProductsPageState();
}

class _ChatProductsPageState extends ConsumerState<ChatProductsPage> {
  late final ChatProductsViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = ChatProductsViewModel(productIds: widget.productIds);
    Future.microtask(
      () => _vm.loadProducts(_vm.state.currentFilter, reset: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final navigationNotifier = ref.read(navigationProvider.notifier);

    return ValueListenableBuilder<ChatProductsState>(
      valueListenable: _vm.stateNotifier,
      builder: (context, state, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.title.toUpperCase()),
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
                    filterCount: _vm.activeFilterCount,
                    onTap: () async {
                      navigationNotifier.setBottomBarVisible(false);
                      await showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) =>
                            ProductFilterSheet<
                              ChatProductsQuery,
                              ChatProductsState
                            >(viewModel: _vm, state: _vm.state),
                      );
                      navigationNotifier.setBottomBarVisible(true);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: ProductListView<ChatProductsQuery, ChatProductsState>(
            state: state,
            viewModel: _vm,
          ),
        );
      },
    );
  }
}

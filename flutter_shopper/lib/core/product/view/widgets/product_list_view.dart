import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_shopper/core/product/models/base_product_query.dart';
import 'package:flutter_shopper/core/product/models/base_product_state.dart';
import 'package:flutter_shopper/core/product/viewmodel/product_filter_mixin.dart';
import 'package:flutter_shopper/core/product/view/widgets/product_grid_item.dart';
import 'package:flutter_shopper/core/product/view/pages/product_detail_page.dart';
import 'package:flutter_shopper/core/providers/navigation_notifier.dart';
import 'package:flutter_shopper/core/widgets/loader.dart';

class ProductListView<T extends BaseProductQuery, S extends BaseProductState<T>>
    extends ConsumerStatefulWidget {
  final S state;
  final ProductFilterMixin<T, S> viewModel;

  const ProductListView({
    super.key,
    required this.state,
    required this.viewModel,
  });

  @override
  ConsumerState<ProductListView<T, S>> createState() =>
      _ProductListViewState<T, S>();
}

class _ProductListViewState<
  T extends BaseProductQuery,
  S extends BaseProductState<T>
>
    extends ConsumerState<ProductListView<T, S>> {
  late final ScrollController _scrollController;
  bool _showBackToTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final currentOffset = _scrollController.offset;

    if (currentOffset > 600 && !_showBackToTop) {
      setState(() => _showBackToTop = true);
    } else if (currentOffset <= 600 && _showBackToTop) {
      setState(() => _showBackToTop = false);
    }

    final direction = _scrollController.position.userScrollDirection;
    if (direction == ScrollDirection.reverse) {
      ref.read(navigationProvider.notifier).setBottomBarVisible(false);
    } else if (direction == ScrollDirection.forward || currentOffset < 10) {
      ref.read(navigationProvider.notifier).setBottomBarVisible(true);
    }

    if (widget.state.isPaginationLoading || widget.state.isLastPage) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    if (currentOffset >= maxScroll * 0.7 && maxScroll > 0) {
      widget.viewModel.loadMoreProducts();
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutQuart,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.state.isInitial && !widget.state.isLoading) {
      return const SizedBox.shrink();
    }

    if (widget.state.isLoading) {
      return const Center(child: Loader());
    }

    if (widget.state.errorMessage != null && widget.state.products.isEmpty) {
      return _buildErrorView();
    }

    if (widget.state.products.isEmpty) {
      return _buildNoResultsView();
    }

    return _buildProductGrid();
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              widget.state.errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => widget.viewModel.loadProducts(
                widget.state.currentFilter.copyWith(page: 1) as T,
                reset: true,
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'No products found.',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try adjusting filters.',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => widget.viewModel.clearCommonFilters(),
            child: const Text(
              'Reset All Filters',
              style: TextStyle(color: Color(0xFF8B4D53)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    final isBottomBarVisible = ref.watch(navigationProvider).isBottomBarVisible;

    return Stack(
      children: [
        GridView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 220,
            crossAxisSpacing: 16,
            mainAxisSpacing: 24,
            childAspectRatio: 0.6,
          ),
          itemCount:
              widget.state.products.length +
              (widget.state.isPaginationLoading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index < widget.state.products.length) {
              final product = widget.state.products[index];
              return ProductGridItem(
                product: product,
                onTap: () {
                  // reset bottom bar visibility so it's visible on the detail page
                  ref
                      .read(navigationProvider.notifier)
                      .setBottomBarVisible(true);

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          ProductDetailPage(productId: product.id),
                    ),
                  );
                },
              );
            }
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Loader(),
              ),
            );
          },
        ),
        if (_showBackToTop)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            right: 20,
            bottom: isBottomBarVisible ? 80 : 20,
            child: FloatingActionButton.small(
              onPressed: _scrollToTop,
              child: const Icon(Icons.arrow_upward, size: 20),
            ),
          ),
      ],
    );
  }
}

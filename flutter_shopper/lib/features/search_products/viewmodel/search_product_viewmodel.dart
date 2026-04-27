import 'package:flutter_shopper/core/product/viewmodel/product_filter_mixin.dart';
import 'package:flutter_shopper/features/search_products/models/search_product_query.dart';
import 'package:flutter_shopper/features/search_products/models/search_product_state.dart';
import 'package:flutter_shopper/features/search_products/repositories/search_product_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search_product_viewmodel.g.dart';

@Riverpod(keepAlive: true)
class SearchProductViewModel extends _$SearchProductViewModel
    with ProductFilterMixin<SearchProductQuery, SearchProductState> {
  late SearchProductRepository _repository;
  bool _isLoadingRequest = false;

  @override
  SearchProductState build({
    String? queryText,
    required String gender,
    int? menuCategoryId,
  }) {
    _repository = ref.read(searchProductRepositoryProvider);

    final initialFilter = SearchProductQuery(
      q: queryText,
      gender: gender,
      menuCategoryId: menuCategoryId,
      page: 1,
    );

    // initial search trigger
    Future.microtask(() => loadProducts(initialFilter, reset: true));

    return SearchProductState(currentFilter: initialFilter);
  }

  @override
  Future<void> loadProducts(
    SearchProductQuery filter, {
    bool reset = false,
  }) async {
    if (_isLoadingRequest) return;
    _isLoadingRequest = true;

    try {
      state = state.copyWith(
        isLoading: reset,
        isPaginationLoading: !reset,
        products: reset ? [] : state.products,
        isLastPage: reset ? false : state.isLastPage,
        currentFilter: filter,
      );

      final result = await _repository.searchProducts(params: filter);

      result.fold(
        (failure) {
          state = state.copyWith(
            errorMessage: failure.message,
            isLoading: false,
            isPaginationLoading: false,
            isInitial: false,
          );
        },
        (response) {
          state = state.copyWith(
            products: reset
                ? response.products
                : [...state.products, ...response.products],
            availableBrands: response.brands,
            availableSizes: response.sizes,
            availableColors: response.colors,
            isLoading: false,
            isPaginationLoading: false,
            errorMessage: null,
            isLastPage: response.products.length < filter.pageSize,
            isInitial: false,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
        isLoading: false,
        isPaginationLoading: false,
        isInitial: false,
      );
    } finally {
      _isLoadingRequest = false;
    }
  }
}

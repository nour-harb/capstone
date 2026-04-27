import 'package:flutter_shopper/core/product/viewmodel/product_filter_mixin.dart';
import 'package:flutter_shopper/features/category_products/models/category_product_query.dart';
import 'package:flutter_shopper/features/category_products/models/category_product_state.dart';
import 'package:flutter_shopper/features/category_products/repositories/category_product_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'category_product_viewmodel.g.dart';

@Riverpod(keepAlive: true)
class CategoryProductViewModel extends _$CategoryProductViewModel
    with ProductFilterMixin<CategoryProductQuery, CategoryProductState> {
  late CategoryProductRepository _repository;
  bool _isLoadingRequest = false;

  @override
  CategoryProductState build({
    required int menuCategoryId,
    int initialPageSize = 20,
  }) {
    _repository = ref.read(categoryProductRepositoryProvider);

    ref.onDispose(() {
      _isLoadingRequest = false;
    });

    final initialFilter = CategoryProductQuery(
      menuCategoryId: menuCategoryId,
      page: 1,
      pageSize: initialPageSize,
    );

    Future.microtask(() => loadProducts(initialFilter, reset: true));

    return CategoryProductState(currentFilter: initialFilter);
  }

  @override
  Future<void> loadProducts(
    CategoryProductQuery filter, {
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

      final result = await _repository.getCategoryProducts(params: filter);

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
            availableSubcategories: response.subcategories,
            availableBrands: response.brands,
            availableSizes: response.sizes,
            availableColors: response.colors,
            isLoading: false,
            isPaginationLoading: false,
            errorMessage: null,
            isLastPage: response.products.length < filter.pageSize,
            currentFilter: filter,
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

  Future<void> filterBySubcategory(int? subcategoryId) async {
    final newId = (state.currentFilter.subcategoryId == subcategoryId)
        ? null
        : subcategoryId;

    final updatedFilter = CategoryProductQuery(
      menuCategoryId: state.currentFilter.menuCategoryId,
      subcategoryId: newId,
      brandIds: state.currentFilter.brandIds,
      colorIds: state.currentFilter.colorIds,
      sizeIds: state.currentFilter.sizeIds,
      sortBy: state.currentFilter.sortBy,
      page: 1,
      pageSize: state.currentFilter.pageSize,
    );

    await loadProducts(updatedFilter, reset: true);
  }

  Future<void> clearSubcategoryFilter() => filterBySubcategory(null);
}

import 'package:flutter_shopper/core/product/models/base_product_query.dart';
import 'package:flutter_shopper/core/product/models/base_product_state.dart';

mixin ProductFilterMixin<
  T extends BaseProductQuery,
  S extends BaseProductState<T>
> {
  S get state;
  set state(S value);
  Future<void> loadProducts(T filter, {bool reset = false});

  Future<void> toggleBrandFilter(int brandId) async {
    final currentIds = List<int>.from(state.currentFilter.brandIds);
    currentIds.contains(brandId)
        ? currentIds.remove(brandId)
        : currentIds.add(brandId);

    await loadProducts(
      state.currentFilter.copyWith(brandIds: currentIds, page: 1) as T,
      reset: true,
    );
  }

  Future<void> toggleSizeFilter(int sizeId) async {
    final currentIds = List<int>.from(state.currentFilter.sizeIds);
    currentIds.contains(sizeId)
        ? currentIds.remove(sizeId)
        : currentIds.add(sizeId);

    await loadProducts(
      state.currentFilter.copyWith(sizeIds: currentIds, page: 1) as T,
      reset: true,
    );
  }

  Future<void> toggleColorFilter(int colorId) async {
    final currentIds = List<int>.from(state.currentFilter.colorIds);
    currentIds.contains(colorId)
        ? currentIds.remove(colorId)
        : currentIds.add(colorId);

    await loadProducts(
      state.currentFilter.copyWith(colorIds: currentIds, page: 1) as T,
      reset: true,
    );
  }

  Future<void> applySort(String sortBy) async {
    if (state.currentFilter.sortBy == sortBy) return;
    await loadProducts(
      state.currentFilter.copyWith(sortBy: sortBy, page: 1) as T,
      reset: true,
    );
  }

  Future<void> clearCommonFilters() async {
    final updatedFilter =
        state.currentFilter.copyWith(
              sizeIds: [],
              colorIds: [],
              brandIds: [],
              sortBy: 'newest',
              page: 1,
            )
            as T;
    await loadProducts(updatedFilter, reset: true);
  }

  Future<void> loadMoreProducts() async {
    if (state.isPaginationLoading || state.isLastPage) return;

    await loadProducts(
      state.currentFilter.copyWith(page: state.currentFilter.page + 1) as T,
      reset: false,
    );
  }

  int get activeFilterCount {
    int count = 0;
    if (state.hasSizeFilter) count++;
    if (state.hasColorFilter) count++;
    if (state.hasBrandFilter) count++;
    if (state.hasSort) count++;
    return count;
  }
}

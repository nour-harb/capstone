import 'package:flutter_shopper/core/product/models/base_product_query.dart';
import 'package:flutter_shopper/core/product/models/filter_item.dart';
import 'package:flutter_shopper/core/product/models/product_model.dart';

class BaseProductState<T extends BaseProductQuery> {
  final List<ProductModel> products;
  final bool isLoading;
  final bool isPaginationLoading;
  final String? errorMessage;
  final T currentFilter;
  final List<FilterItem> availableSizes;
  final List<FilterItem> availableColors;
  final List<FilterItem> availableBrands;
  final bool isLastPage;

  // track if the first data fetch has ever completed to prevent showing "No Results" at first
  final bool isInitial;

  const BaseProductState({
    this.products = const [],
    this.isLoading = false,
    this.isPaginationLoading = false,
    this.errorMessage,
    required this.currentFilter,
    this.availableSizes = const [],
    this.availableColors = const [],
    this.availableBrands = const [],
    this.isLastPage = false,
    this.isInitial = true,
  });

  BaseProductState<T> copyWith({
    List<ProductModel>? products,
    bool? isLoading,
    bool? isPaginationLoading,
    String? errorMessage,
    T? currentFilter,
    List<FilterItem>? availableSizes,
    List<FilterItem>? availableColors,
    List<FilterItem>? availableBrands,
    bool? isLastPage,
    bool? isInitial,
  }) {
    return BaseProductState<T>(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      isPaginationLoading: isPaginationLoading ?? this.isPaginationLoading,
      errorMessage: errorMessage,
      currentFilter: currentFilter ?? this.currentFilter,
      availableSizes: availableSizes ?? this.availableSizes,
      availableColors: availableColors ?? this.availableColors,
      availableBrands: availableBrands ?? this.availableBrands,
      isLastPage: isLastPage ?? this.isLastPage,
      isInitial: isInitial ?? this.isInitial,
    );
  }

  /// Determines if filters (excluding subcategories) are active
  bool get hasActiveFilters {
    return currentFilter.sizeIds.isNotEmpty ||
        currentFilter.colorIds.isNotEmpty ||
        currentFilter.brandIds.isNotEmpty ||
        currentFilter.sortBy != 'newest';
  }

  bool get hasSizeFilter => currentFilter.sizeIds.isNotEmpty;
  bool get hasColorFilter => currentFilter.colorIds.isNotEmpty;
  bool get hasBrandFilter => currentFilter.brandIds.isNotEmpty;
  bool get hasSort => currentFilter.sortBy != 'newest';

  List<int> get selectedSizes => currentFilter.sizeIds;
  List<int> get selectedColors => currentFilter.colorIds;
  List<int> get selectedBrands => currentFilter.brandIds;
  String get selectedSort => currentFilter.sortBy;
}

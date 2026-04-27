import 'package:flutter_shopper/core/product/models/base_product_state.dart';
import 'package:flutter_shopper/core/product/models/filter_item.dart';
import 'package:flutter_shopper/core/product/models/product_model.dart';
import 'package:flutter_shopper/features/category_products/models/category_product_query.dart';

class CategoryProductState extends BaseProductState<CategoryProductQuery> {
  final List<FilterItem> availableSubcategories;

  const CategoryProductState({
    required super.currentFilter,
    this.availableSubcategories = const [],
    super.products,
    super.isLoading,
    super.isPaginationLoading,
    super.errorMessage,
    super.availableSizes,
    super.availableColors,
    super.availableBrands,
    super.isLastPage,
    super.isInitial,
  });

  @override
  CategoryProductState copyWith({
    List<ProductModel>? products,
    bool? isLoading,
    bool? isPaginationLoading,
    String? errorMessage,
    CategoryProductQuery? currentFilter,
    List<FilterItem>? availableSubcategories,
    List<FilterItem>? availableSizes,
    List<FilterItem>? availableColors,
    List<FilterItem>? availableBrands,
    bool? isLastPage,
    bool? isInitial,
  }) {
    return CategoryProductState(
      currentFilter: currentFilter ?? this.currentFilter,
      availableSubcategories:
          availableSubcategories ?? this.availableSubcategories,
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      isPaginationLoading: isPaginationLoading ?? this.isPaginationLoading,
      errorMessage: errorMessage,
      availableSizes: availableSizes ?? this.availableSizes,
      availableColors: availableColors ?? this.availableColors,
      availableBrands: availableBrands ?? this.availableBrands,
      isLastPage: isLastPage ?? this.isLastPage,
      isInitial: isInitial ?? this.isInitial,
    );
  }

  int? get selectedSubcategory => currentFilter.subcategoryId;
}

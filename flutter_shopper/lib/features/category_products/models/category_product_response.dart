import 'package:flutter_shopper/core/product/models/base_product_response.dart';
import 'package:flutter_shopper/core/product/models/filter_item.dart';

class CategoryProductResponse extends ProductQueryResponse {
  final List<FilterItem> subcategories;

  CategoryProductResponse({
    required super.products,
    required super.sizes,
    required super.colors,
    required super.brands,
    required this.subcategories,
  });

  factory CategoryProductResponse.fromMap(Map<String, dynamic> map) {
    final baseResponse = ProductQueryResponse.fromMap(map);

    return CategoryProductResponse(
      products: baseResponse.products,
      sizes: baseResponse.sizes,
      colors: baseResponse.colors,
      brands: baseResponse.brands,
      subcategories: (map['subcategories'] as List? ?? [])
          .map((x) => FilterItem.fromMap(x as Map<String, dynamic>))
          .toList(),
    );
  }
}

import 'package:flutter_shopper/core/product/models/filter_item.dart';
import 'package:flutter_shopper/core/product/models/product_model.dart';

class ProductQueryResponse {
  final List<ProductModel> products;
  final List<FilterItem> sizes;
  final List<FilterItem> colors;
  final List<FilterItem> brands;

  ProductQueryResponse({
    required this.products,
    required this.sizes,
    required this.colors,
    required this.brands,
  });

  factory ProductQueryResponse.fromMap(Map<String, dynamic> map) {
    return ProductQueryResponse(
      products: (map['products'] as List? ?? [])
          .map((x) => ProductModel.fromMap(x as Map<String, dynamic>))
          .toList(),
      sizes: (map['sizes'] as List? ?? [])
          .map((x) => FilterItem.fromMap(x as Map<String, dynamic>))
          .toList(),
      colors: (map['colors'] as List? ?? [])
          .map((x) => FilterItem.fromMap(x as Map<String, dynamic>))
          .toList(),
      brands: (map['brands'] as List? ?? [])
          .map((x) => FilterItem.fromMap(x as Map<String, dynamic>))
          .toList(),
    );
  }
}

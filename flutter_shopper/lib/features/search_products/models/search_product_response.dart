import 'package:flutter_shopper/core/product/models/base_product_response.dart';

class SearchProductResponse extends ProductQueryResponse {
  SearchProductResponse({
    required super.products,
    required super.sizes,
    required super.colors,
    required super.brands,
  });

  factory SearchProductResponse.fromMap(Map<String, dynamic> map) {
    final baseResponse = ProductQueryResponse.fromMap(map);
    return SearchProductResponse(
      products: baseResponse.products,
      sizes: baseResponse.sizes,
      colors: baseResponse.colors,
      brands: baseResponse.brands,
    );
  }
}

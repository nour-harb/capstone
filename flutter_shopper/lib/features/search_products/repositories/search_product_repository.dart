import 'dart:convert';
import 'package:flutter_shopper/core/constants/server_constant.dart';
import 'package:flutter_shopper/core/failure.dart';
import 'package:flutter_shopper/features/search_products/models/search_product_query.dart';
import 'package:flutter_shopper/features/search_products/models/search_product_response.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search_product_repository.g.dart';

@Riverpod(keepAlive: true)
SearchProductRepository searchProductRepository(Ref ref) =>
    SearchProductRepository();

class SearchProductRepository {
  final String _baseUrl = ServerConstant.serverURL;

  Future<Either<AppFailure, SearchProductResponse>> searchProducts({
    required SearchProductQuery params,
  }) async {
    try {
      final queryParams = params.toMap();
      final Map<String, dynamic> formattedParams = {};

      for (final entry in queryParams.entries) {
        final value = entry.value;
        if (value == null) continue;

        if (value is List) {
          formattedParams[entry.key] = value.map((e) => e.toString()).toList();
        } else {
          formattedParams[entry.key] = value.toString();
        }
      }

      final uri = Uri.parse(
        '$_baseUrl/products/search',
      ).replace(queryParameters: formattedParams);

      final res = await http.get(uri);

      if (res.statusCode != 200) {
        return Left(AppFailure.server());
      }

      final resBody = jsonDecode(res.body) as Map<String, dynamic>;
      return Right(SearchProductResponse.fromMap(resBody));
    } catch (e) {
      return Left(AppFailure.network());
    }
  }
}

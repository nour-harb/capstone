import 'dart:convert';

import 'package:flutter_shopper/core/constants/server_constant.dart';
import 'package:flutter_shopper/core/product/models/base_product_response.dart';
import 'package:flutter_shopper/features/chat/models/chat_product_query.dart';
import 'package:http/http.dart' as http;

class ChatProductsRepository {
  Future<ProductQueryResponse> fetchByIds({
    required ChatProductsQuery params,
  }) async {
    final queryParams = params.toMap();
    final Map<String, dynamic> formattedParams = {};

    for (final entry in queryParams.entries) {
      final value = entry.value;
      if (value == null) continue;

      if (value is List) {
        formattedParams[entry.key] = value
            .map((e) => e.toString())
            .toList(growable: false);
      } else {
        formattedParams[entry.key] = value.toString();
      }
    }

    final uri = Uri.parse(
      '$_baseUrl/products/by_ids',
    ).replace(queryParameters: formattedParams);

    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Server error: ${res.statusCode}');
    }

    final resBody = jsonDecode(res.body) as Map<String, dynamic>;
    return ProductQueryResponse.fromMap(resBody);
  }

  static const String _baseUrl = ServerConstant.serverURL;
}

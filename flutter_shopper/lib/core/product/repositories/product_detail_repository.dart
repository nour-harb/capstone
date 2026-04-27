import 'dart:convert';
import 'package:flutter_shopper/core/constants/server_constant.dart';
import 'package:flutter_shopper/core/failure.dart';
import 'package:flutter_shopper/core/product/models/product_detail_model.dart';
import 'package:flutter_shopper/features/auth/repositories/auth_local_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'product_detail_repository.g.dart';

@Riverpod(keepAlive: true)
ProductDetailRepository productDetailRepository(Ref ref) {
  return ProductDetailRepository(ref.watch(authLocalRepositoryProvider));
}

class ProductDetailRepository {
  final String _baseUrl = ServerConstant.serverURL;
  final AuthLocalRepository _authLocal;

  ProductDetailRepository(this._authLocal);

  Future<Either<AppFailure, ProductDetailModel>> getProductById(int id) async {
    final token = _authLocal.getToken();
    try {
      final uri = Uri.parse('$_baseUrl/products/$id');

      final res = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null && token.isNotEmpty) 'x-auth-token': token,
        },
      );

      // handle errors
      if (res.statusCode != 200) {
        return Left(AppFailure.server());
      }

      final resBody = jsonDecode(res.body) as Map<String, dynamic>;

      final productDetail = ProductDetailModel.fromMap(resBody);

      return Right(productDetail);
    } catch (e) {
      return Left(AppFailure.network());
    }
  }
}

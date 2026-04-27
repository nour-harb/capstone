import 'dart:convert';

import 'package:flutter_shopper/core/constants/server_constant.dart';
import 'package:flutter_shopper/core/failure.dart';
import 'package:flutter_shopper/core/product/models/base_product_response.dart';
import 'package:flutter_shopper/features/auth/repositories/auth_local_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'favorites_repository.g.dart';

@Riverpod(keepAlive: true)
FavoritesRepository favoritesRepository(Ref ref) {
  return FavoritesRepository(ref.watch(authLocalRepositoryProvider).getToken());
}

class FavoritesRepository {
  FavoritesRepository(this._token);
  final String? _token;

  String get _t => _token ?? '';

  Map<String, String> get _authHeaders => {
    'Content-Type': 'application/json',
    'x-auth-token': _t,
  };

  Future<Either<AppFailure, int>> fetchPriceDropAlertCount() async {
    try {
      final res = await http.get(
        Uri.parse('${ServerConstant.serverURL}/favorites/price-drop-alerts'),
        headers: _authHeaders,
      );
      if (res.statusCode != 200) {
        return Left(AppFailure.server());
      }
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final n = body['affected_count'];
      if (n is! num) {
        return Left(AppFailure.server());
      }
      return Right(n.toInt());
    } catch (_) {
      return Left(AppFailure.network());
    }
  }

  Future<Either<AppFailure, ProductQueryResponse>> getFavorites({
    int page = 1,
    int pageSize = 40,
  }) async {
    try {
      final uri = Uri.parse(
        '${ServerConstant.serverURL}/favorites',
      ).replace(queryParameters: {'page': '$page', 'page_size': '$pageSize'});
      final res = await http.get(uri, headers: _authHeaders);
      if (res.statusCode != 200) {
        return Left(AppFailure.server());
      }
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return Right(ProductQueryResponse.fromMap(body));
    } catch (_) {
      return Left(AppFailure.network());
    }
  }

  Future<Either<AppFailure, void>> addFavorite(int productId) async {
    try {
      final res = await http.post(
        Uri.parse('${ServerConstant.serverURL}/favorites/$productId'),
        headers: _authHeaders,
      );
      if (res.statusCode != 201 && res.statusCode != 200) {
        return Left(AppFailure.server());
      }
      return const Right(null);
    } catch (_) {
      return Left(AppFailure.network());
    }
  }

  Future<Either<AppFailure, void>> removeFavorite(int productId) async {
    try {
      final res = await http.delete(
        Uri.parse('${ServerConstant.serverURL}/favorites/$productId'),
        headers: _authHeaders,
      );
      if (res.statusCode != 204) {
        return Left(AppFailure.server());
      }
      return const Right(null);
    } catch (_) {
      return Left(AppFailure.network());
    }
  }
}

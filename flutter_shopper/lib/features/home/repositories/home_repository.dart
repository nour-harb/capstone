import 'dart:convert';
import 'package:flutter_shopper/core/constants/server_constant.dart';
import 'package:flutter_shopper/core/failure.dart';
import 'package:flutter_shopper/features/home/models/category_model.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_repository.g.dart';

@Riverpod(keepAlive: true)
HomeRepository homeRepository(Ref ref) {
  return HomeRepository();
}

class HomeRepository {
  Future<Either<AppFailure, List<CategoryModel>>> getAllCategories() async {
    try {
      final res = await http.get(
        Uri.parse('${ServerConstant.serverURL}/categories/list'),
        headers: {'Content-Type': 'application/json'},
      );

      if (res.statusCode != 200) {
        // treat server error
        return Left(AppFailure.server());
      }

      final resBodyMap = jsonDecode(res.body) as List;

      List<CategoryModel> categories = resBodyMap
          .map((map) => CategoryModel.fromMap(map))
          .toList();

      return Right(categories);
    } catch (_) {
      return Left(AppFailure.network());
    }
  }
}

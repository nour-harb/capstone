import 'dart:convert';
import 'package:flutter_shopper/core/constants/server_constant.dart';
import 'package:flutter_shopper/core/failure.dart';
import 'package:flutter_shopper/features/auth/model/user_model.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_repository.g.dart';

@Riverpod(keepAlive: true)
ProfileRepository profileRepository(Ref ref) => ProfileRepository();

class ProfileRepository {
  String _extractMessage(dynamic body) {
    try {
      final res = body is String ? jsonDecode(body) : body;

      if (res is Map<String, dynamic>) {
        final detail = res['detail'];
        if (detail is String) return detail;
        if (detail is List &&
            detail.isNotEmpty &&
            detail.first['msg'] != null) {
          return detail.first['msg'];
        }
      }

      return 'Unknown error';
    } catch (_) {
      return 'Unknown error';
    }
  }

  Future<Either<AppFailure, UserModel>> updateName({
    required String token,
    required String newName,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('${ServerConstant.serverURL}/profile/update-name'),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
        body: jsonEncode({'new_name': newName}),
      );

      if (response.statusCode != 200) {
        return Left(AppFailure.server(message: _extractMessage(response.body)));
      }

      final resBodyMap = jsonDecode(response.body) as Map<String, dynamic>;
      return Right(UserModel.fromMap(resBodyMap).copyWith(token: token));
    } catch (_) {
      return Left(AppFailure.network());
    }
  }

  Future<Either<AppFailure, UserModel>> updateEmail({
    required String token,
    required String newEmail,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('${ServerConstant.serverURL}/profile/update-email'),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
        body: jsonEncode({'new_email': newEmail}),
      );

      if (response.statusCode != 200) {
        return Left(AppFailure.server(message: _extractMessage(response.body)));
      }

      final resBodyMap = jsonDecode(response.body) as Map<String, dynamic>;
      return Right(UserModel.fromMap(resBodyMap).copyWith(token: token));
    } catch (_) {
      return Left(AppFailure.network());
    }
  }

  Future<Either<AppFailure, void>> changePassword({
    required String token,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ServerConstant.serverURL}/profile/change-password'),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
        body: jsonEncode({
          'old_password': oldPassword,
          'new_password': newPassword,
        }),
      );

      if (response.statusCode != 200) {
        return Left(AppFailure.server(message: _extractMessage(response.body)));
      }

      return const Right(null);
    } catch (_) {
      return Left(AppFailure.network());
    }
  }

  Future<Either<AppFailure, void>> deleteAccount({
    required String token,
    required String password,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('${ServerConstant.serverURL}/profile/delete'),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
        body: jsonEncode({'password': password}),
      );

      if (response.statusCode != 200) {
        return Left(AppFailure.server(message: _extractMessage(response.body)));
      }

      return const Right(null);
    } catch (_) {
      return Left(AppFailure.network());
    }
  }
}

import 'dart:convert';
import 'package:flutter_shopper/core/constants/server_constant.dart';
import 'package:flutter_shopper/core/failure.dart';
import 'package:flutter_shopper/features/auth/model/user_model.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_remote_repository.g.dart';

@Riverpod(keepAlive: true)
AuthRemoteRepository authRemoteRepository(Ref ref) {
  return AuthRemoteRepository();
}

class AuthRemoteRepository {
  Future<Either<AppFailure, UserModel>> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ServerConstant.serverURL}/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );

      final resBodyMap = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode != 201) {
        // validation error: extract details from response
        final errorDetail = resBodyMap['detail'];
        String message;

        if (errorDetail is List) {
          // usually a list of errors
          message = errorDetail.map((e) => e['msg']).join('\n');
        } else {
          message = errorDetail.toString();
        }

        return Left(AppFailure(type: FailureType.server, message: message));
      }

      return Right(
        UserModel.fromMap(
          resBodyMap['user'] as Map<String, dynamic>,
        ).copyWith(token: resBodyMap['token'] as String),
      );
    } catch (_) {
      return Left(AppFailure.network());
    }
  }

  Future<Either<AppFailure, UserModel>> signin({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ServerConstant.serverURL}/auth/signin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      final resBodyMap = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode != 200) {
        // validation error: extract details from response
        final errorDetail = resBodyMap['detail'];
        String message;

        if (errorDetail is List) {
          // usually a list of errors
          message = errorDetail.map((e) => e['msg']).join('\n');
        } else {
          message = errorDetail.toString();
        }

        return Left(AppFailure(type: FailureType.server, message: message));
      }

      return Right(
        UserModel.fromMap(
          resBodyMap['user'],
        ).copyWith(token: resBodyMap['token']),
      );
    } catch (_) {
      return Left(AppFailure.network());
    }
  }

  Future<Either<AppFailure, UserModel>> getCurrentUserData({
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('${ServerConstant.serverURL}/auth/'),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
      );

      final resBodyMap = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode != 200) {
        // validation error: extract details from response
        final errorDetail = resBodyMap['detail'];
        String message;

        if (errorDetail is List) {
          // usually a list of errors
          message = errorDetail.map((e) => e['msg']).join('\n');
        } else {
          message = errorDetail.toString();
        }

        return Left(AppFailure(type: FailureType.server, message: message));
      }

      return Right(UserModel.fromMap(resBodyMap).copyWith(token: token));
    } catch (_) {
      return Left(AppFailure.network());
    }
  }
}

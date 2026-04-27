import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'auth_local_repository.g.dart';

@Riverpod(keepAlive: true)
AuthLocalRepository authLocalRepository(Ref ref) {
  return AuthLocalRepository();
}

class AuthLocalRepository {
  late SharedPreferences _sharedPreferences;

  Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  Future<void> setToken(String? token) async {
    if (token != null) {
      await _sharedPreferences.setString('x-auth-token', token);
    } else {
      await _sharedPreferences.remove('x-auth-token');
    }
  }

  String? getToken() {
    return _sharedPreferences.getString('x-auth-token');
  }
}

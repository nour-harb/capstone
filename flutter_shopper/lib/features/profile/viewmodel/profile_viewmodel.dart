import 'package:flutter_shopper/core/providers/current_user_notifier.dart';
import 'package:flutter_shopper/features/profile/repositories/profile_repository.dart';
import 'package:flutter_shopper/features/auth/repositories/auth_local_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_viewmodel.g.dart';

@Riverpod(keepAlive: true)
class ProfileViewModel extends _$ProfileViewModel {
  late ProfileRepository _profileRepository;
  late AuthLocalRepository _authLocalRepository;
  late CurrentUserNotifier _currentUserNotifier;

  @override
  AsyncValue<void> build() {
    _profileRepository = ref.watch(profileRepositoryProvider);
    _authLocalRepository = ref.watch(authLocalRepositoryProvider);
    _currentUserNotifier = ref.watch(currentUserProvider.notifier);
    return const AsyncValue.data(null);
  }

  Future<void> updateName(String newName) async {
    final token = _authLocalRepository.getToken();
    if (token == null) return;

    state = const AsyncValue.loading();

    final response = await _profileRepository.updateName(
      token: token,
      newName: newName,
    );

    switch (response) {
      case Left(value: final l):
        state = AsyncValue.error(l.message, StackTrace.current);
      case Right(value: final user):
        _currentUserNotifier.setUser(user);
        state = const AsyncValue.data(null);
    }
  }

  Future<void> updateEmail(String newEmail) async {
    final token = _authLocalRepository.getToken();
    if (token == null) return;

    state = const AsyncValue.loading();

    final response = await _profileRepository.updateEmail(
      token: token,
      newEmail: newEmail,
    );

    switch (response) {
      case Left(value: final l):
        state = AsyncValue.error(l.message, StackTrace.current);
      case Right(value: final user):
        _currentUserNotifier.setUser(user);
        state = const AsyncValue.data(null);
    }
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final token = _authLocalRepository.getToken();
    if (token == null) return;

    state = const AsyncValue.loading();

    final response = await _profileRepository.changePassword(
      token: token,
      oldPassword: oldPassword,
      newPassword: newPassword,
    );

    switch (response) {
      case Left(value: final l):
        state = AsyncValue.error(l.message, StackTrace.current);
      case Right():
        state = const AsyncValue.data(null);
    }
  }

  Future<void> deleteAccount({required String password}) async {
    final token = _authLocalRepository.getToken();
    if (token == null) return;

    state = const AsyncValue.loading();

    final response = await _profileRepository.deleteAccount(
      token: token,
      password: password,
    );

    switch (response) {
      case Left(value: final l):
        state = AsyncValue.error(l.message, StackTrace.current);
      case Right():
        _authLocalRepository.setToken(null);
        _currentUserNotifier.setUser(null);
        state = const AsyncValue.data(null);
    }
  }
}

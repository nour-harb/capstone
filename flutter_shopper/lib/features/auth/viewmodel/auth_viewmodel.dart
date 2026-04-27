import 'package:flutter_shopper/core/providers/current_user_notifier.dart';
import 'package:flutter_shopper/features/auth/repositories/auth_local_repository.dart';
import 'package:flutter_shopper/features/auth/repositories/auth_remote_repository.dart';
import 'package:flutter_shopper/features/chat/viewmodel/chat_thread_viewmodel.dart';
import 'package:flutter_shopper/features/favorites/viewmodel/favorites_list_viewmodel.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_viewmodel.g.dart';

@Riverpod(keepAlive: true)
class AuthViewModel extends _$AuthViewModel {
  late AuthRemoteRepository _authRemoteRepository;
  late AuthLocalRepository _authLocalRepository;
  late CurrentUserNotifier _currentUserNotifier;

  @override
  AsyncValue<void> build() {
    _authRemoteRepository = ref.watch(authRemoteRepositoryProvider);
    _authLocalRepository = ref.watch(authLocalRepositoryProvider);
    _currentUserNotifier = ref.watch(currentUserProvider.notifier);
    return const AsyncValue.data(null);
  }

  // initialize shared preferences
  Future<void> initSharedPreferences() async {
    await _authLocalRepository.init();
  }

  // sign up a new user
  Future<void> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();

    final response = await _authRemoteRepository.signup(
      name: name,
      email: email,
      password: password,
    );

    switch (response) {
      case Left(value: final l):
        state = AsyncValue.error(l.message, StackTrace.current);
      case Right(value: final user):
        _authLocalRepository.setToken(user.token);
        ref.invalidate(chatThreadProvider(userId: user.id));
        ref.invalidate(favoritesListProvider);
        _currentUserNotifier.setUser(user);
        state = const AsyncValue.data(null);
    }
  }

  // sign in an existing user
  Future<void> signin({required String email, required String password}) async {
    state = const AsyncValue.loading();

    final response = await _authRemoteRepository.signin(
      email: email,
      password: password,
    );

    switch (response) {
      case Left(value: final l):
        state = AsyncValue.error(l.message, StackTrace.current);
      case Right(value: final user):
        _authLocalRepository.setToken(user.token);
        ref.invalidate(chatThreadProvider(userId: user.id));
        ref.invalidate(favoritesListProvider);
        _currentUserNotifier.setUser(user);
        state = const AsyncValue.data(null);
    }
  }

  // fetch user data if a token exists
  Future<void> getData() async {
    state = const AsyncValue.loading();
    final token = _authLocalRepository.getToken();
    if (token == null) {
      state = const AsyncValue.data(null);
      return;
    }

    final response = await _authRemoteRepository.getCurrentUserData(
      token: token,
    );

    switch (response) {
      case Left(value: final l):
        state = AsyncValue.error(l.message, StackTrace.current);
      case Right(value: final user):
        _currentUserNotifier.setUser(user);
        state = const AsyncValue.data(null);
    }
  }

  // log out the user
  void logout() {
    final u = ref.read(currentUserProvider);
    _authLocalRepository.setToken(null);
    if (u != null) {
      ref.invalidate(chatThreadProvider(userId: u.id));
    }
    ref.invalidate(favoritesListProvider);
    _currentUserNotifier.setUser(null);
    state = const AsyncValue.data(null);
  }
}

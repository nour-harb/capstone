import 'package:flutter_shopper/core/product/models/product_model.dart';
import 'package:flutter_shopper/features/favorites/repositories/favorites_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'favorites_list_viewmodel.g.dart';

@Riverpod(keepAlive: true)
class FavoritesList extends _$FavoritesList {
  @override
  FutureOr<List<ProductModel>> build() async {
    final result = await ref.read(favoritesRepositoryProvider).getFavorites();
    return result.fold(
      (f) => throw Exception(f.message),
      (r) => r.products,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final result = await ref.read(favoritesRepositoryProvider).getFavorites();
      return result.fold(
        (f) => throw Exception(f.message),
        (r) => r.products,
      );
    });
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorites_list_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FavoritesList)
const favoritesListProvider = FavoritesListProvider._();

final class FavoritesListProvider
    extends $AsyncNotifierProvider<FavoritesList, List<ProductModel>> {
  const FavoritesListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'favoritesListProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$favoritesListHash();

  @$internal
  @override
  FavoritesList create() => FavoritesList();
}

String _$favoritesListHash() => r'ece45f0042f2b24c6b56f1e3078727174a1885d2';

abstract class _$FavoritesList extends $AsyncNotifier<List<ProductModel>> {
  FutureOr<List<ProductModel>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<List<ProductModel>>, List<ProductModel>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<ProductModel>>, List<ProductModel>>,
              AsyncValue<List<ProductModel>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

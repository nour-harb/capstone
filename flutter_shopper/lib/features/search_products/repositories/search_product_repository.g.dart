// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_product_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(searchProductRepository)
const searchProductRepositoryProvider = SearchProductRepositoryProvider._();

final class SearchProductRepositoryProvider
    extends
        $FunctionalProvider<
          SearchProductRepository,
          SearchProductRepository,
          SearchProductRepository
        >
    with $Provider<SearchProductRepository> {
  const SearchProductRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchProductRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchProductRepositoryHash();

  @$internal
  @override
  $ProviderElement<SearchProductRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SearchProductRepository create(Ref ref) {
    return searchProductRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SearchProductRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchProductRepository>(value),
    );
  }
}

String _$searchProductRepositoryHash() =>
    r'05fb40236b49c81d4943dce313cde7608f83eb9b';

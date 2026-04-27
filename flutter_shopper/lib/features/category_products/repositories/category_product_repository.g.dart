// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_product_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(categoryProductRepository)
const categoryProductRepositoryProvider = CategoryProductRepositoryProvider._();

final class CategoryProductRepositoryProvider
    extends
        $FunctionalProvider<
          CategoryProductRepository,
          CategoryProductRepository,
          CategoryProductRepository
        >
    with $Provider<CategoryProductRepository> {
  const CategoryProductRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoryProductRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoryProductRepositoryHash();

  @$internal
  @override
  $ProviderElement<CategoryProductRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CategoryProductRepository create(Ref ref) {
    return categoryProductRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CategoryProductRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CategoryProductRepository>(value),
    );
  }
}

String _$categoryProductRepositoryHash() =>
    r'44772678af460eeb130a2f7b3b5fa6b40fae6ebc';

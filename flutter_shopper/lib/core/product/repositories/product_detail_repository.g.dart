// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_detail_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(productDetailRepository)
const productDetailRepositoryProvider = ProductDetailRepositoryProvider._();

final class ProductDetailRepositoryProvider
    extends
        $FunctionalProvider<
          ProductDetailRepository,
          ProductDetailRepository,
          ProductDetailRepository
        >
    with $Provider<ProductDetailRepository> {
  const ProductDetailRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'productDetailRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$productDetailRepositoryHash();

  @$internal
  @override
  $ProviderElement<ProductDetailRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProductDetailRepository create(Ref ref) {
    return productDetailRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProductDetailRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProductDetailRepository>(value),
    );
  }
}

String _$productDetailRepositoryHash() =>
    r'19a8ad3928ddf976aa0a6ea1bcc12cabe32743f5';

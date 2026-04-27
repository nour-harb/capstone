// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_product_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CategoryProductViewModel)
const categoryProductViewModelProvider = CategoryProductViewModelFamily._();

final class CategoryProductViewModelProvider
    extends $NotifierProvider<CategoryProductViewModel, CategoryProductState> {
  const CategoryProductViewModelProvider._({
    required CategoryProductViewModelFamily super.from,
    required ({int menuCategoryId, int initialPageSize}) super.argument,
  }) : super(
         retry: null,
         name: r'categoryProductViewModelProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$categoryProductViewModelHash();

  @override
  String toString() {
    return r'categoryProductViewModelProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  CategoryProductViewModel create() => CategoryProductViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CategoryProductState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CategoryProductState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CategoryProductViewModelProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$categoryProductViewModelHash() =>
    r'388ca5297b0f90adaafc654ef4b427536208bf8b';

final class CategoryProductViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          CategoryProductViewModel,
          CategoryProductState,
          CategoryProductState,
          CategoryProductState,
          ({int menuCategoryId, int initialPageSize})
        > {
  const CategoryProductViewModelFamily._()
    : super(
        retry: null,
        name: r'categoryProductViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  CategoryProductViewModelProvider call({
    required int menuCategoryId,
    int initialPageSize = 20,
  }) => CategoryProductViewModelProvider._(
    argument: (
      menuCategoryId: menuCategoryId,
      initialPageSize: initialPageSize,
    ),
    from: this,
  );

  @override
  String toString() => r'categoryProductViewModelProvider';
}

abstract class _$CategoryProductViewModel
    extends $Notifier<CategoryProductState> {
  late final _$args = ref.$arg as ({int menuCategoryId, int initialPageSize});
  int get menuCategoryId => _$args.menuCategoryId;
  int get initialPageSize => _$args.initialPageSize;

  CategoryProductState build({
    required int menuCategoryId,
    int initialPageSize = 20,
  });
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(
      menuCategoryId: _$args.menuCategoryId,
      initialPageSize: _$args.initialPageSize,
    );
    final ref = this.ref as $Ref<CategoryProductState, CategoryProductState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CategoryProductState, CategoryProductState>,
              CategoryProductState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

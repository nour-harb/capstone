// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_product_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SearchProductViewModel)
const searchProductViewModelProvider = SearchProductViewModelFamily._();

final class SearchProductViewModelProvider
    extends $NotifierProvider<SearchProductViewModel, SearchProductState> {
  const SearchProductViewModelProvider._({
    required SearchProductViewModelFamily super.from,
    required ({String? queryText, String gender, int? menuCategoryId})
    super.argument,
  }) : super(
         retry: null,
         name: r'searchProductViewModelProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$searchProductViewModelHash();

  @override
  String toString() {
    return r'searchProductViewModelProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  SearchProductViewModel create() => SearchProductViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SearchProductState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchProductState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SearchProductViewModelProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$searchProductViewModelHash() =>
    r'c2491c18dad884c96cbf077aa0f648cfcaac7d0e';

final class SearchProductViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          SearchProductViewModel,
          SearchProductState,
          SearchProductState,
          SearchProductState,
          ({String? queryText, String gender, int? menuCategoryId})
        > {
  const SearchProductViewModelFamily._()
    : super(
        retry: null,
        name: r'searchProductViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  SearchProductViewModelProvider call({
    String? queryText,
    required String gender,
    int? menuCategoryId,
  }) => SearchProductViewModelProvider._(
    argument: (
      queryText: queryText,
      gender: gender,
      menuCategoryId: menuCategoryId,
    ),
    from: this,
  );

  @override
  String toString() => r'searchProductViewModelProvider';
}

abstract class _$SearchProductViewModel extends $Notifier<SearchProductState> {
  late final _$args =
      ref.$arg as ({String? queryText, String gender, int? menuCategoryId});
  String? get queryText => _$args.queryText;
  String get gender => _$args.gender;
  int? get menuCategoryId => _$args.menuCategoryId;

  SearchProductState build({
    String? queryText,
    required String gender,
    int? menuCategoryId,
  });
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(
      queryText: _$args.queryText,
      gender: _$args.gender,
      menuCategoryId: _$args.menuCategoryId,
    );
    final ref = this.ref as $Ref<SearchProductState, SearchProductState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SearchProductState, SearchProductState>,
              SearchProductState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

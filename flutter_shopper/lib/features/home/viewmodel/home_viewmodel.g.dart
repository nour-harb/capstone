// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(HomeViewmodel)
const homeViewmodelProvider = HomeViewmodelProvider._();

final class HomeViewmodelProvider
    extends $NotifierProvider<HomeViewmodel, AsyncValue<List<CategoryModel>>> {
  const HomeViewmodelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeViewmodelProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeViewmodelHash();

  @$internal
  @override
  HomeViewmodel create() => HomeViewmodel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<CategoryModel>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<CategoryModel>>>(
        value,
      ),
    );
  }
}

String _$homeViewmodelHash() => r'23e7665ca9ad8a42a2dfa3d7c7adcbd15c7a3a4f';

abstract class _$HomeViewmodel
    extends $Notifier<AsyncValue<List<CategoryModel>>> {
  AsyncValue<List<CategoryModel>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<CategoryModel>>,
              AsyncValue<List<CategoryModel>>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<CategoryModel>>,
                AsyncValue<List<CategoryModel>>
              >,
              AsyncValue<List<CategoryModel>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

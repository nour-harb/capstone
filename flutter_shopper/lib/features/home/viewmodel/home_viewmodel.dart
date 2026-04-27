import 'package:flutter_shopper/features/home/models/category_model.dart';
import 'package:flutter_shopper/features/home/repositories/home_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_viewmodel.g.dart';

@Riverpod(keepAlive: true)
class HomeViewmodel extends _$HomeViewmodel {
  String selectedGender = 'woman';
  List<CategoryModel> _allCategories = [];

  @override
  AsyncValue<List<CategoryModel>> build() {
    return const AsyncValue.loading();
  }

  Future<void> loadCategories() async {
    if (_allCategories.isEmpty) {
      state = const AsyncValue.loading();
    }

    final repo = ref.read(homeRepositoryProvider);
    final response = await repo.getAllCategories();

    switch (response) {
      case Left(value: final failure):
        state = AsyncValue.error(failure.message, StackTrace.current);
        break;

      case Right(value: final categories):
        _allCategories = categories;
        final filtered = _filterByGender();
        state = AsyncValue.data(filtered);
        break;
    }
  }

  void selectGender(String gender) {
    if (selectedGender == gender) return;
    selectedGender = gender;
    final filtered = _filterByGender();
    state = AsyncValue.data(filtered);
  }

  List<CategoryModel> _filterByGender() {
    return _allCategories
        .where((c) => c.gender.toLowerCase() == selectedGender.toLowerCase())
        .toList();
  }
}

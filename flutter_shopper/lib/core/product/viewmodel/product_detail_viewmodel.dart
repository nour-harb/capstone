import 'package:flutter_shopper/core/product/models/product_detail_state.dart';
import 'package:flutter_shopper/core/product/repositories/product_detail_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'product_detail_viewmodel.g.dart';

@riverpod
class ProductDetailViewModel extends _$ProductDetailViewModel {
  @override
  ProductDetailState build({required int productId}) {
    Future.microtask(() => _fetchProductDetail());

    return const ProductDetailState(isLoading: true);
  }

  Future<void> _fetchProductDetail() async {
    final result = await ref
        .read(productDetailRepositoryProvider)
        .getProductById(productId);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (product) {
        final firstColor = product.colors.isNotEmpty
            ? product.colors.first
            : null;

        state = state.copyWith(
          isLoading: false,
          product: product,
          selectedColorId: firstColor?.id,
        );
      },
    );
  }

  void selectColor(int colorId) {
    if (state.selectedColorId == colorId) return;

    state = state.copyWith(
      selectedColorId: colorId,
      selectedSizeId: () => null,
      currentImageIndex: 0,
    );
  }

  void selectSize(int sizeId) {
    state = state.copyWith(selectedSizeId: () => sizeId);
  }

  void updateImageIndex(int index) {
    state = state.copyWith(currentImageIndex: index);
  }
}

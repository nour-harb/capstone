import 'package:flutter_shopper/core/product/models/product_detail_model.dart';
import 'package:flutter_shopper/core/product/models/color_variant_model.dart';
import 'package:flutter_shopper/core/product/models/variant_detail_model.dart';

class ProductDetailState {
  final ProductDetailModel? product;
  final bool isLoading;
  final String? errorMessage;

  final int? selectedSizeId;
  final int? selectedColorId;
  final int currentImageIndex;

  const ProductDetailState({
    this.product,
    this.isLoading = false,
    this.errorMessage,
    this.selectedSizeId,
    this.selectedColorId,
    this.currentImageIndex = 0,
  });

  ColorVariantModel? get selectedColor {
    if (product == null || selectedColorId == null) return null;
    return product!.colors.firstWhere(
      (c) => c.id == selectedColorId,
      orElse: () => product!.colors.first,
    );
  }

  List<String> get currentImages => selectedColor?.images ?? [];

  List<VariantDetailModel> get availableVariants =>
      selectedColor?.variants ?? [];

  VariantDetailModel? get selectedVariant {
    if (selectedColor == null || selectedSizeId == null) return null;
    try {
      return selectedColor!.variants.firstWhere(
        (v) => v.size.id == selectedSizeId,
      );
    } catch (_) {
      return null;
    }
  }

  double get displayPrice => selectedVariant?.price ?? product?.price ?? 0.0;

  ProductDetailState copyWith({
    ProductDetailModel? product,
    bool? isLoading,
    String? errorMessage,
    int? Function()? selectedSizeId,
    int? selectedColorId,
    int? currentImageIndex,
  }) {
    return ProductDetailState(
      product: product ?? this.product,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      // explicitly set selectedSizeId to null
      selectedSizeId: selectedSizeId != null
          ? selectedSizeId()
          : this.selectedSizeId,
      selectedColorId: selectedColorId ?? this.selectedColorId,
      currentImageIndex: currentImageIndex ?? this.currentImageIndex,
    );
  }
}

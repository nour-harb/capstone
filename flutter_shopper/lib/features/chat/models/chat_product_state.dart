import 'package:flutter_shopper/core/product/models/base_product_state.dart';
import 'package:flutter_shopper/core/product/models/product_model.dart';
import 'package:flutter_shopper/features/chat/models/chat_product_query.dart';

class ChatProductsState extends BaseProductState<ChatProductsQuery> {
  const ChatProductsState({
    required super.currentFilter,
    super.products,
    super.isLoading,
    super.isPaginationLoading,
    super.errorMessage,
    super.availableSizes,
    super.availableColors,
    super.availableBrands,
    super.isLastPage,
    super.isInitial,
  });

  @override
  ChatProductsState copyWith({
    List<ProductModel>? products,
    bool? isLoading,
    bool? isPaginationLoading,
    String? errorMessage,
    ChatProductsQuery? currentFilter,
    dynamic availableSizes,
    dynamic availableColors,
    dynamic availableBrands,
    bool? isLastPage,
    bool? isInitial,
  }) {
    return ChatProductsState(
      currentFilter: currentFilter ?? this.currentFilter,
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      isPaginationLoading: isPaginationLoading ?? this.isPaginationLoading,
      errorMessage: errorMessage,
      availableSizes: availableSizes ?? this.availableSizes,
      availableColors: availableColors ?? this.availableColors,
      availableBrands: availableBrands ?? this.availableBrands,
      isLastPage: isLastPage ?? this.isLastPage,
      isInitial: isInitial ?? this.isInitial,
    );
  }
}

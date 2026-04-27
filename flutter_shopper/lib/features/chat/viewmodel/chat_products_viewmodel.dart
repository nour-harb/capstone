import 'package:flutter/material.dart';
import 'package:flutter_shopper/core/product/viewmodel/product_filter_mixin.dart';
import 'package:flutter_shopper/features/chat/models/chat_product_query.dart';
import 'package:flutter_shopper/features/chat/models/chat_product_state.dart';
import 'package:flutter_shopper/features/chat/repositories/chat_product_repository.dart';

class ChatProductsViewModel
    with ProductFilterMixin<ChatProductsQuery, ChatProductsState> {
  final ChatProductsRepository _repo;
  final ValueNotifier<ChatProductsState> _stateNotifier;
  bool _isLoadingRequest = false;

  ChatProductsViewModel({
    required List<int> productIds,
    ChatProductsRepository? repository,
  }) : _repo = repository ?? ChatProductsRepository(),
       _stateNotifier = ValueNotifier(
         ChatProductsState(
           currentFilter: ChatProductsQuery(
             productIds: productIds,
             page: 1,
             pageSize: 20,
             sortBy: 'chat_order',
           ),
           isInitial: true,
         ),
       );

  ValueNotifier<ChatProductsState> get stateNotifier => _stateNotifier;

  @override
  ChatProductsState get state => _stateNotifier.value;

  @override
  set state(ChatProductsState value) => _stateNotifier.value = value;

  @override
  Future<void> loadProducts(
    ChatProductsQuery filter, {
    bool reset = false,
  }) async {
    if (_isLoadingRequest) return;
    _isLoadingRequest = true;

    try {
      state = state.copyWith(
        isLoading: reset,
        isPaginationLoading: !reset,
        products: reset ? [] : state.products,
        isLastPage: reset ? false : state.isLastPage,
        currentFilter: filter,
        isInitial: false,
        errorMessage: null,
      );

      final response = await _repo.fetchByIds(params: filter);

      state = state.copyWith(
        products: reset
            ? response.products
            : [...state.products, ...response.products],
        availableSizes: response.sizes,
        availableColors: response.colors,
        availableBrands: response.brands,
        isLoading: false,
        isPaginationLoading: false,
        errorMessage: null,
        isLastPage: response.products.length < filter.pageSize,
        currentFilter: filter,
        isInitial: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isPaginationLoading: false,
        errorMessage: e.toString(),
        isInitial: false,
      );
    } finally {
      _isLoadingRequest = false;
    }
  }
}

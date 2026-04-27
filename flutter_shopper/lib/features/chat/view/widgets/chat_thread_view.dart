import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_shopper/core/product/models/product_model.dart';
import 'package:flutter_shopper/core/theme/app_pallete.dart';
import 'package:flutter_shopper/core/widgets/loader.dart';
import 'package:flutter_shopper/features/chat/models/chat_ui_message.dart';
import 'package:flutter_shopper/features/chat/services/chat_attachment_service.dart';
import 'package:flutter_shopper/features/chat/view/widgets/chat_message_bubble.dart';
import 'package:flutter_shopper/features/chat/view/widgets/chat_thread_input_bar.dart';

class ChatThreadView extends StatefulWidget {
  final List<ChatUiMessage> messages;
  final bool isLoadingHistory;
  final bool isLoadingSend;
  final Future<bool> Function(
    String text, {
    Uint8List? imageBytes,
    String? imageFilename,
  })
  onSend;
  final Future<ChatPickedImage?> Function(ChatImagePickSource source)
      onPickImage;
  final void Function(ProductModel product) onProductTap;
  final void Function(List<int> productIds) onShowRecommendedProducts;

  const ChatThreadView({
    super.key,
    required this.messages,
    required this.isLoadingHistory,
    required this.isLoadingSend,
    required this.onSend,
    required this.onPickImage,
    required this.onProductTap,
    required this.onShowRecommendedProducts,
  });

  @override
  State<ChatThreadView> createState() => _ChatThreadViewState();
}

class _ChatThreadViewState extends State<ChatThreadView> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    if (widget.isLoadingHistory) {
      return const Center(child: Loader());
    }

    return Column(
      children: [
        Expanded(
          child: widget.messages.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Type a message or attach a photo to get started.',
                      style: theme.bodyMedium?.copyWith(
                        color: Pallete.subtitleText,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  itemCount: widget.messages.length,
                  itemBuilder: (context, index) {
                    final msg = widget.messages[index];
                    return ChatMessageBubble(
                      message: msg,
                      theme: theme,
                      onProductTap: widget.onProductTap,
                      onShowAllProducts: msg.products.length > 6
                          ? () => widget.onShowRecommendedProducts(
                                msg.products
                                    .map((p) => p.id)
                                    .toList(growable: false),
                              )
                          : null,
                    );
                  },
                ),
        ),
        const Divider(height: 1),
        ChatThreadInputBar(
          isLoadingSend: widget.isLoadingSend,
          onSend: widget.onSend,
          onPickImage: widget.onPickImage,
          onSendSuccess: _scrollToEnd,
        ),
      ],
    );
  }
}

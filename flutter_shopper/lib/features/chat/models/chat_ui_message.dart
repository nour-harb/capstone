import 'dart:typed_data';

import 'package:flutter_shopper/core/product/models/product_model.dart';

class ChatUiMessage {
  final String role; // 'user' or 'assistant'
  final String content;
  final List<ProductModel> products;
  final String? imageAttachmentId;
  // local preview bytes before the server returns an image ID
  final Uint8List? localImageBytes;

  const ChatUiMessage({
    required this.role,
    required this.content,
    this.products = const [],
    this.imageAttachmentId,
    this.localImageBytes,
  });
}

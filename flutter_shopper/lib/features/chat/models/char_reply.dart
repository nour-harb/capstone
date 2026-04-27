import 'package:flutter_shopper/core/product/models/product_model.dart';

class ChatReply {
  final String reply;
  final List<ProductModel> products;
  final String? imageAttachmentId;

  ChatReply({
    required this.reply,
    required this.products,
    this.imageAttachmentId,
  });
}

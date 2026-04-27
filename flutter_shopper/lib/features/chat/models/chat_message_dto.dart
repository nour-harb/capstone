import 'package:flutter_shopper/core/product/models/product_model.dart';

class ChatMessageDto {
  final int id;
  final String role;
  final String content;
  final List<ProductModel> products;

  final String? imageAttachmentId;

  ChatMessageDto({
    required this.id,
    required this.role,
    required this.content,
    this.products = const [],
    this.imageAttachmentId,
  });

  factory ChatMessageDto.fromMap(Map<String, dynamic> map) {
    final productsList = map['products'] as List<dynamic>? ?? [];
    return ChatMessageDto(
      id: (map['id'] as num).toInt(),
      role: map['role'] as String,
      content: map['content'] as String? ?? '',
      products: productsList
          .map((e) => ProductModel.fromMap(e as Map<String, dynamic>))
          .toList(),
      imageAttachmentId:
          (map['image_attachment_id'] ?? map['imageAttachmentId']) as String?,
    );
  }
}

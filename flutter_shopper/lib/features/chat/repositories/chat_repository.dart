import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_shopper/core/constants/server_constant.dart';
import 'package:flutter_shopper/core/failure.dart';
import 'package:flutter_shopper/core/product/models/product_model.dart';
import 'package:flutter_shopper/features/auth/repositories/auth_local_repository.dart';
import 'package:flutter_shopper/features/chat/models/char_reply.dart';
import 'package:flutter_shopper/features/chat/models/chat_message_dto.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chat_repository.g.dart';

@Riverpod(keepAlive: true)
ChatRepository chatRepository(Ref ref) {
  final token = ref.watch(authLocalRepositoryProvider).getToken();
  return ChatRepository(token);
}

class ChatRepository {
  final String? token;
  ChatRepository(this.token);

  Future<Either<AppFailure, ChatReply>> sendMessage({
    required String message,
    Uint8List? imageBytes,
    String? imageFilename,
  }) async {
    try {
      http.Response response;
      if (imageBytes != null && imageBytes.isNotEmpty) {
        String? fileName = '';
        MediaType mimeType;
        final req = http.MultipartRequest(
          'POST',
          Uri.parse('${ServerConstant.serverURL}/chat/'),
        );
        req.headers['x-auth-token'] = token ?? '';
        req.fields['message'] = message;

        if ((imageFilename ?? '').trim().toLowerCase().endsWith('.png')) {
          fileName = imageFilename;
          mimeType = MediaType('image', 'png');
        } else {
          fileName = (imageFilename ?? '').trim().isEmpty
              ? 'upload.jpg'
              : imageFilename;
          mimeType = MediaType('image', 'jpeg');
        }

        req.files.add(
          http.MultipartFile.fromBytes(
            'image',
            imageBytes,
            filename: fileName,
            contentType: mimeType,
          ),
        );
        final streamed = await req.send();
        response = await http.Response.fromStream(streamed);
      } else {
        response = await http.post(
          Uri.parse('${ServerConstant.serverURL}/chat/'),
          headers: {
            'Content-Type': 'application/json',
            'x-auth-token': token ?? '',
          },
          body: jsonEncode({'message': message}),
        );
      }

      if (response.statusCode != 200) {
        return Left(AppFailure.server());
      }

      final res = jsonDecode(response.body) as Map<String, dynamic>;
      final reply = res['reply'] as String? ?? '';
      final productsList = res['products'] as List<dynamic>? ?? [];
      final products = productsList
          .map((e) => ProductModel.fromMap(e as Map<String, dynamic>))
          .toList();
      final attachmentId = res['image_attachment_id'] as String?;

      return Right(
        ChatReply(
          reply: reply,
          products: products,
          imageAttachmentId: attachmentId,
        ),
      );
    } catch (_) {
      return Left(AppFailure.network());
    }
  }

  Future<Either<AppFailure, List<ChatMessageDto>>> getHistory() async {
    try {
      final response = await http.get(
        Uri.parse('${ServerConstant.serverURL}/chat/history'),
        headers: {'x-auth-token': token ?? ''},
      );

      if (response.statusCode != 200) {
        return Left(AppFailure.server());
      }

      final list = jsonDecode(response.body) as List<dynamic>;
      final messages = list
          .map((e) => ChatMessageDto.fromMap(e as Map<String, dynamic>))
          .toList();
      return Right(messages);
    } catch (_) {
      return Left(AppFailure.network());
    }
  }

  Future<Either<AppFailure, void>> clearChat() async {
    try {
      final response = await http.delete(
        Uri.parse('${ServerConstant.serverURL}/chat/'),
        headers: {'x-auth-token': token ?? ''},
      );

      if (response.statusCode != 200) {
        return Left(AppFailure.server());
      }
      return const Right(null);
    } catch (_) {
      return Left(AppFailure.network());
    }
  }
}

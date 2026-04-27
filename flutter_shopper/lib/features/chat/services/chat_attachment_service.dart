import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chat_attachment_service.g.dart';

enum ChatImagePickSource { gallery, camera }

@Riverpod(keepAlive: true)
ChatAttachmentService chatAttachmentService(Ref ref) => ChatAttachmentService();

class ChatPickedImage {
  const ChatPickedImage({required this.bytes, required this.filename});

  final Uint8List bytes;
  final String filename;
}

class ChatAttachmentService {
  ChatAttachmentService({ImagePicker? picker})
    : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  static const double _maxWidth = 1600;
  static const int _imageQuality = 85;

  Future<ChatPickedImage?> pickImage(ChatImagePickSource source) async {
    final x = await _picker.pickImage(
      source: source == ChatImagePickSource.gallery
          ? ImageSource.gallery
          : ImageSource.camera,
      maxWidth: _maxWidth,
      imageQuality: _imageQuality,
      requestFullMetadata: false,
    );
    if (x == null) return null;
    final bytes = await x.readAsBytes();
    final filename = x.name;
    return ChatPickedImage(bytes: bytes, filename: filename);
  }
}

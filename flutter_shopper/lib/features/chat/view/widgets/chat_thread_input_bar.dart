import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_shopper/core/theme/app_pallete.dart';
import 'package:flutter_shopper/core/utils.dart';
import 'package:flutter_shopper/features/chat/services/chat_attachment_service.dart';

class ChatThreadInputBar extends StatefulWidget {
  final bool isLoadingSend;
  final Future<bool> Function(
    String text, {
    Uint8List? imageBytes,
    String? imageFilename,
  })
  onSend;
  final Future<ChatPickedImage?> Function(ChatImagePickSource source)
  onPickImage;
  final VoidCallback onSendSuccess;

  const ChatThreadInputBar({
    super.key,
    required this.isLoadingSend,
    required this.onSend,
    required this.onPickImage,
    required this.onSendSuccess,
  });

  @override
  State<ChatThreadInputBar> createState() => _ChatThreadInputBarState();
}

class _ChatThreadInputBarState extends State<ChatThreadInputBar> {
  final _controller = TextEditingController();
  Uint8List? _pickedBytes;
  String _pickedFilename = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickImage(
    ChatImagePickSource source,
    String sourceLabel,
  ) async {
    // small delay to ensure the popup menu is fully dismissed
    await Future<void>.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;

    try {
      final picked = await widget.onPickImage(source);
      if (!mounted) return;
      if (picked == null) return;

      setState(() {
        _pickedBytes = picked.bytes;
        _pickedFilename = picked.filename;
      });
    } catch (e) {
      if (mounted) {
        showSnackBar(context, 'Could not open $sourceLabel: $e');
      }
    }
  }

  Future<void> _submit() async {
    if (widget.isLoadingSend) return;
    final text = _controller.text;
    final bytes = _pickedBytes;
    final filename = _pickedFilename;

    if (text.trim().isEmpty && (bytes == null || bytes.isEmpty)) return;

    _controller.clear();
    setState(() {
      _pickedBytes = null;
      _pickedFilename = '';
    });

    final ok = await widget.onSend(
      text,
      imageBytes: bytes,
      imageFilename: filename,
    );
    if (ok) widget.onSendSuccess();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_pickedBytes != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: InputChip(
                avatar: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.memory(
                    _pickedBytes!,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                ),
                label: const Text('Image attached'),
                onDeleted: () => setState(() {
                  _pickedBytes = null;
                  _pickedFilename = '';
                }),
              ),
            ),
          ),
        Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
            bottom:
                12 +
                MediaQuery.of(context).padding.bottom +
                kBottomNavigationBarHeight,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // use PopupMenuButton to handle the attachment menu automatically
              PopupMenuButton<String>(
                offset: const Offset(0, -120),
                position: PopupMenuPosition.over,
                icon: const Icon(Icons.image_outlined),
                tooltip: 'Attach photo',
                enabled: !widget.isLoadingSend,
                color: Pallete.whiteColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (choice) {
                  if (choice == 'gallery') {
                    _pickImage(ChatImagePickSource.gallery, 'gallery');
                  } else if (choice == 'camera') {
                    _pickImage(ChatImagePickSource.camera, 'camera');
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem<String>(
                    value: 'gallery',
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.photo_library_outlined),
                      title: Text('Choose from gallery'),
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'camera',
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.photo_camera_outlined),
                      title: Text('Take a photo'),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Message...',
                    filled: true,
                    fillColor: Pallete.whiteColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(color: Pallete.borderColor),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  maxLines: 3,
                  minLines: 1,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _submit(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _submit(),
                style: IconButton.styleFrom(
                  backgroundColor: Pallete.blackColor,
                  foregroundColor: Pallete.whiteColor,
                ),
                icon: widget.isLoadingSend
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator.adaptive(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(
                            Pallete.whiteColor,
                          ),
                        ),
                      )
                    : const Icon(Icons.send_rounded),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

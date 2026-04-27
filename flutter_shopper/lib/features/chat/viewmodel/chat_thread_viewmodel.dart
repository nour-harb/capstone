import 'dart:typed_data';
import 'package:flutter_shopper/features/auth/repositories/auth_local_repository.dart';
import 'package:flutter_shopper/features/chat/models/chat_thread_state.dart';
import 'package:flutter_shopper/features/chat/models/chat_ui_message.dart';
import 'package:flutter_shopper/features/chat/repositories/chat_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chat_thread_viewmodel.g.dart';

@Riverpod(keepAlive: true)
class ChatThread extends _$ChatThread {
  late ChatRepository _repo;
  late AuthLocalRepository _authLocal;

  @override
  ChatThreadState build({required String userId}) {
    _repo = ref.watch(chatRepositoryProvider);
    _authLocal = ref.watch(authLocalRepositoryProvider);
    return const ChatThreadState();
  }

  Future<void> loadHistory() async {
    final token = _authLocal.getToken();
    if (token == null) return;

    state = state.copyWith(isLoadingHistory: true, errorMessage: null);
    final result = await _repo.getHistory();
    switch (result) {
      case Left(value: final f):
        state = state.copyWith(
          isLoadingHistory: false,
          errorMessage: f.message,
        );
      case Right(value: final list):
        final messages = list
            .map(
              (m) => ChatUiMessage(
                role: m.role,
                content: m.content,
                products: m.products,
                imageAttachmentId: m.imageAttachmentId,
              ),
            )
            .toList();
        state = state.copyWith(
          messages: messages,
          isLoadingHistory: false,
          errorMessage: null,
        );
    }
  }

  Future<bool> sendMessage(
    String text, {
    Uint8List? imageBytes,
    String? imageFilename,
  }) async {
    final token = _authLocal.getToken();
    if (token == null) return false;

    final trimmed = text.trim();
    final hasImage = imageBytes != null && imageBytes.isNotEmpty;
    if (trimmed.isEmpty && !hasImage) return false;

    state = state.copyWith(
      isLoadingSend: true,
      errorMessage: null,
      messages: [
        ...state.messages,
        ChatUiMessage(
          role: 'user',
          content: trimmed,
          localImageBytes: hasImage ? imageBytes : null,
        ),
      ],
    );

    final result = await _repo.sendMessage(
      message: trimmed,
      imageBytes: imageBytes,
      imageFilename: imageFilename,
    );

    switch (result) {
      case Left(value: final f):
        state = state.copyWith(
          isLoadingSend: false,
          errorMessage: f.message,
          messages: state.messages.isNotEmpty
              ? state.messages.sublist(0, state.messages.length - 1)
              : [],
        );
        return false;
      case Right(value: final sendResult):
        final reply = sendResult.reply.trim();
        final msgs = List<ChatUiMessage>.from(state.messages);
        if (msgs.isNotEmpty && msgs.last.role == 'user') {
          final u = msgs.removeLast();
          final attachmentId =
              sendResult.imageAttachmentId ?? u.imageAttachmentId;
          msgs.add(
            ChatUiMessage(
              role: 'user',
              content: u.content,
              imageAttachmentId: attachmentId,
              localImageBytes: attachmentId != null ? null : u.localImageBytes,
              products: u.products,
            ),
          );
        }
        msgs.add(
          ChatUiMessage(
            role: 'assistant',
            content: reply.isEmpty
                ? 'I couldn\'t generate a reply. Please try again.'
                : reply,
            products: sendResult.products,
          ),
        );
        state = state.copyWith(
          isLoadingSend: false,
          errorMessage: null,
          messages: msgs,
        );
        return true;
    }
  }

  Future<bool> clearChat() async {
    final token = _authLocal.getToken();
    if (token == null) return false;
    state = state.copyWith(errorMessage: null);
    final result = await _repo.clearChat();
    switch (result) {
      case Left(value: final f):
        state = state.copyWith(errorMessage: f.message);
        return false;
      case Right():
        state = state.copyWith(messages: const []);
        return true;
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

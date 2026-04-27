import 'package:flutter_shopper/features/chat/models/chat_ui_message.dart';

class ChatThreadState {
  final List<ChatUiMessage> messages;
  final bool isLoadingSend;
  final bool isLoadingHistory;
  final String? errorMessage;

  const ChatThreadState({
    this.messages = const [],
    this.isLoadingSend = false,
    this.isLoadingHistory = false,
    this.errorMessage,
  });

  ChatThreadState copyWith({
    List<ChatUiMessage>? messages,
    bool? isLoadingSend,
    bool? isLoadingHistory,
    String? errorMessage,
  }) {
    return ChatThreadState(
      messages: messages ?? this.messages,
      isLoadingSend: isLoadingSend ?? this.isLoadingSend,
      isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
      errorMessage: errorMessage,
    );
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_attachment_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(chatAttachmentService)
const chatAttachmentServiceProvider = ChatAttachmentServiceProvider._();

final class ChatAttachmentServiceProvider
    extends
        $FunctionalProvider<
          ChatAttachmentService,
          ChatAttachmentService,
          ChatAttachmentService
        >
    with $Provider<ChatAttachmentService> {
  const ChatAttachmentServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chatAttachmentServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chatAttachmentServiceHash();

  @$internal
  @override
  $ProviderElement<ChatAttachmentService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ChatAttachmentService create(Ref ref) {
    return chatAttachmentService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChatAttachmentService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChatAttachmentService>(value),
    );
  }
}

String _$chatAttachmentServiceHash() =>
    r'c9d7445d44b919627dd5f7b30f09c6ce8fbd8b30';

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_thread_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Per-user thread; keyed by userId to avoid cross-account cache on logout.

@ProviderFor(ChatThread)
const chatThreadProvider = ChatThreadFamily._();

/// Per-user thread; keyed by userId to avoid cross-account cache on logout.
final class ChatThreadProvider
    extends $NotifierProvider<ChatThread, ChatThreadState> {
  /// Per-user thread; keyed by userId to avoid cross-account cache on logout.
  const ChatThreadProvider._({
    required ChatThreadFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'chatThreadProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$chatThreadHash();

  @override
  String toString() {
    return r'chatThreadProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ChatThread create() => ChatThread();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChatThreadState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChatThreadState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ChatThreadProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chatThreadHash() => r'81a9f576cf9c08df0ed7d4dce1a4c6f3b4fd2ec4';

/// Per-user thread; keyed by userId to avoid cross-account cache on logout.

final class ChatThreadFamily extends $Family
    with
        $ClassFamilyOverride<
          ChatThread,
          ChatThreadState,
          ChatThreadState,
          ChatThreadState,
          String
        > {
  const ChatThreadFamily._()
    : super(
        retry: null,
        name: r'chatThreadProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Per-user thread; keyed by userId to avoid cross-account cache on logout.

  ChatThreadProvider call({required String userId}) =>
      ChatThreadProvider._(argument: userId, from: this);

  @override
  String toString() => r'chatThreadProvider';
}

/// Per-user thread; keyed by userId to avoid cross-account cache on logout.

abstract class _$ChatThread extends $Notifier<ChatThreadState> {
  late final _$args = ref.$arg as String;
  String get userId => _$args;

  ChatThreadState build({required String userId});
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(userId: _$args);
    final ref = this.ref as $Ref<ChatThreadState, ChatThreadState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ChatThreadState, ChatThreadState>,
              ChatThreadState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

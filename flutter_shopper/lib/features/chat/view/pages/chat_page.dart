import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_shopper/core/product/view/pages/product_detail_page.dart';
import 'package:flutter_shopper/core/providers/current_user_notifier.dart';
import 'package:flutter_shopper/core/providers/navigation_notifier.dart';
import 'package:flutter_shopper/core/theme/app_pallete.dart';
import 'package:flutter_shopper/core/utils.dart';
import 'package:flutter_shopper/features/chat/services/chat_attachment_service.dart';
import 'package:flutter_shopper/features/chat/view/pages/chat_products_page.dart';
import 'package:flutter_shopper/features/chat/view/widgets/chat_thread_view.dart';
import 'package:flutter_shopper/features/chat/viewmodel/chat_thread_viewmodel.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  @override
  void initState() {
    super.initState();
    _scheduleLoad();
  }

  void _scheduleLoad() {
    final user = ref.read(currentUserProvider);
    if (user != null) {
      Future.microtask(
        () => ref
            .read(chatThreadProvider(userId: user.id).notifier)
            .loadHistory(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    if (user != null) {
      final uid = user.id;
      ref.listen(
        chatThreadProvider(userId: uid),
        (_, state) {
          final msg = state.errorMessage;
          if (msg != null && msg.isNotEmpty) {
            showSnackBar(context, msg);
            ref.read(chatThreadProvider(userId: uid).notifier).clearError();
          }
        },
      );
    }

    ref.listen(currentUserProvider, (prev, next) {
      if (next != null && (prev == null || prev.id != next.id)) {
        Future.microtask(
          () => ref
              .read(chatThreadProvider(userId: next.id).notifier)
              .loadHistory(),
        );
      }
    });

    if (user == null) {
      return Scaffold(
        backgroundColor: Pallete.backgroundColor,
        appBar: AppBar(
          title: const Text('CHAT'),
          centerTitle: true,
          backgroundColor: Pallete.transparentColor,
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 64,
                  color: Pallete.greyColor,
                ),
                const SizedBox(height: 24),
                Text(
                  'Sign in to use chat',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Pallete.subtitleText),
                ),
                const SizedBox(height: 12),
                Text(
                  'Only logged-in users can chat with the fashion assistant.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Pallete.subtitleText,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(navigationProvider.notifier).setSelectedIndex(3);
                    },
                    child: const Text('SIGN IN'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final u = user;
    final threadState = ref.watch(chatThreadProvider(userId: u.id));

    return Scaffold(
      backgroundColor: Pallete.backgroundColor,
      appBar: AppBar(
        title: const Text('CHAT'),
        centerTitle: true,
        backgroundColor: Pallete.transparentColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear chat',
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Clear chat?'),
                  content: const Text(
                    'This removes all messages in this chat for your account.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('CANCEL'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text('CLEAR'),
                    ),
                  ],
                ),
              );
              if (ok == true && context.mounted) {
                final cleared = await ref
                    .read(chatThreadProvider(userId: u.id).notifier)
                    .clearChat();
                if (cleared && context.mounted) {
                  showSnackBar(context, 'Chat cleared');
                }
              }
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ChatThreadView(
              messages: threadState.messages,
              isLoadingHistory: threadState.isLoadingHistory,
              isLoadingSend: threadState.isLoadingSend,
              onSend: (text, {imageBytes, String? imageFilename}) {
                return ref
                    .read(chatThreadProvider(userId: u.id).notifier)
                    .sendMessage(
                      text,
                      imageBytes: imageBytes,
                      imageFilename: imageFilename,
                    );
              },
              onPickImage: (source) =>
                  ref.read(chatAttachmentServiceProvider).pickImage(source),
              onProductTap: (product) {
                ref
                    .read(navigationProvider.notifier)
                    .setBottomBarVisible(true);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ProductDetailPage(productId: product.id),
                  ),
                );
              },
              onShowRecommendedProducts: (productIds) {
                ref
                    .read(navigationProvider.notifier)
                    .setBottomBarVisible(true);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ChatProductsPage(
                      title: 'Recommended products',
                      productIds: productIds,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


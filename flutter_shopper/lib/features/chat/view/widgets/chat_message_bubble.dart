import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_shopper/core/constants/server_constant.dart';
import 'package:flutter_shopper/core/product/models/product_model.dart';
import 'package:flutter_shopper/core/product/view/widgets/product_grid_item.dart';
import 'package:flutter_shopper/core/theme/app_pallete.dart';
import 'package:flutter_shopper/features/auth/repositories/auth_local_repository.dart';
import 'package:flutter_shopper/features/chat/models/chat_ui_message.dart';

class ChatMessageBubble extends ConsumerWidget {
  final ChatUiMessage message;
  final TextTheme theme;
  final void Function(ProductModel) onProductTap;
  final VoidCallback? onShowAllProducts;

  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.theme,
    required this.onProductTap,
    this.onShowAllProducts,
  });

  static int productCount(int totalProducts) {
    if (totalProducts <= 6) return totalProducts;
    return 7;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUser = message.role == 'user';
    final token = ref.read(authLocalRepositoryProvider).getToken();
    final hasLocal = message.localImageBytes != null;
    final hasRemote =
        message.imageAttachmentId != null &&
        message.imageAttachmentId!.isNotEmpty;
    final showThumb = isUser && (hasLocal || hasRemote);
    final trimmedContent = message.content.trim();
    final isLegacyPhotoLabel = trimmedContent.toLowerCase() == '(photo)';
    final isImageOnlyUser = isUser &&
        showThumb &&
        (trimmedContent.isEmpty || isLegacyPhotoLabel);
    final bubbleText = isImageOnlyUser ? '' : message.content;
    final showTextBubble = bubbleText.trim().isNotEmpty;

    Widget? thumb;
    if (isUser && hasLocal && message.localImageBytes != null) {
      thumb = ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(
          message.localImageBytes!,
          width: 160,
          height: 160,
          fit: BoxFit.cover,
        ),
      );
    } else if (isUser && hasRemote && token != null) {
      final url =
          '${ServerConstant.serverURL}/chat/attachments/${message.imageAttachmentId}';
      thumb = ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: url,
          width: 160,
          height: 160,
          fit: BoxFit.cover,
          httpHeaders: {'x-auth-token': token},
          placeholder: (_, __) => Container(
            width: 160,
            height: 160,
            color: Pallete.backgroundColor,
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          errorWidget: (_, __, ___) => Container(
            width: 160,
            height: 80,
            alignment: Alignment.center,
            color: Pallete.backgroundColor,
            child: const Icon(Icons.broken_image_outlined),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser)
            CircleAvatar(
              radius: 16,
              backgroundColor: Pallete.backgroundColor,
              child: Icon(
                Icons.smart_toy_rounded,
                size: 18,
                color: Pallete.greyColor,
              ),
            ),
          if (!isUser) const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (showThumb && thumb != null) ...[
                  thumb,
                  if (showTextBubble) const SizedBox(height: 8),
                ],
                if (showTextBubble)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isUser ? Pallete.blackColor : Pallete.cardColor,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isUser ? 16 : 4),
                        bottomRight: Radius.circular(isUser ? 4 : 16),
                      ),
                      border: isUser
                          ? null
                          : Border.all(color: Pallete.borderColor),
                    ),
                    child: Text(
                      bubbleText,
                      style: theme.bodyMedium?.copyWith(
                        color: isUser ? Pallete.whiteColor : Pallete.blackColor,
                        fontSize: 14,
                      ),
                    ),
                  ),
                if (message.products.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 320,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: productCount(message.products.length),
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final products = message.products;
                        final visibleCount = products.length > 6
                            ? 6
                            : products.length;
                        final showAll = products.length > 6;
                        if (index < visibleCount) {
                          final product = products[index];
                          return SizedBox(
                            width: 180,
                            child: ProductGridItem(
                              product: product,
                              onTap: () => onProductTap(product),
                            ),
                          );
                        }

                        if (!showAll) {
                          return const SizedBox.shrink();
                        }

                        return SizedBox(
                          width: 72,
                          child: InkWell(
                            onTap: onShowAllProducts,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Pallete.cardColor,
                                border: Border.all(color: Pallete.borderColor),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 22,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '+${products.length - 6}',
                                    style: theme.labelSmall?.copyWith(
                                      color: Pallete.subtitleText,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_shopper/core/theme/app_pallete.dart';
import 'package:flutter_shopper/features/favorites/repositories/favorites_repository.dart';

class PriceDropBanner extends ConsumerStatefulWidget {
  const PriceDropBanner({super.key});

  @override
  ConsumerState<PriceDropBanner> createState() => _PriceDropBannerState();
}

class _PriceDropBannerState extends ConsumerState<PriceDropBanner> {
  int? _affectedCount;
  bool _visible = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    final result = await ref
        .read(favoritesRepositoryProvider)
        .fetchPriceDropAlertCount();
    if (!mounted) return;
    result.fold((_) {}, (count) {
      setState(() => _affectedCount = count);
    });
  }

  void _dismiss() {
    if (mounted) {
      setState(() => _visible = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) {
      return const SizedBox.shrink();
    }
    final n = _affectedCount;
    if (n == null || n <= 0) {
      return const SizedBox.shrink();
    }

    final bodyStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Pallete.blackColor,
          height: 1.4,
        );

    return Material(
      color: Pallete.cardColor,
      elevation: 0,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Pallete.borderColor.withValues(alpha: 0.4),
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Icon(
                Icons.trending_down,
                color: Pallete.blackColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Price drop on favorites',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Pallete.blackColor,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    n == 1
                        ? '1 item you favorited has a lower price. Check it out in Favorites in your profile.'
                        : "$n items you've favorited have lower prices. Check them out in Favorites in your profile.",
                    style: bodyStyle,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 20, color: Pallete.greyColor),
              onPressed: _dismiss,
            ),
          ],
        ),
      ),
    );
  }
}

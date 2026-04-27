import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_shopper/core/product/view/pages/product_detail_page.dart';
import 'package:flutter_shopper/core/product/view/widgets/product_grid_item.dart';
import 'package:flutter_shopper/core/product/models/product_model.dart';
import 'package:flutter_shopper/core/providers/navigation_notifier.dart';
import 'package:flutter_shopper/core/theme/app_pallete.dart';
import 'package:flutter_shopper/core/widgets/loader.dart';
import 'package:flutter_shopper/features/favorites/viewmodel/favorites_list_viewmodel.dart';

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(favoritesListProvider);

    return async.when(
      data: (products) => _FavoritesBody(products: products),
      loading: () => const Scaffold(body: Center(child: Loader())),
      error: (e, _) => Scaffold(
        appBar: AppBar(backgroundColor: Pallete.transparentColor, elevation: 0),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(e.toString(), textAlign: TextAlign.center),
          ),
        ),
      ),
    );
  }
}

class _FavoritesBody extends ConsumerWidget {
  const _FavoritesBody({required this.products});

  final List<ProductModel> products;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nav = ref.read(navigationProvider.notifier);

    return Scaffold(
      backgroundColor: Pallete.backgroundColor,
      appBar: AppBar(
        title: const Text('FAVORITES'),
        centerTitle: true,
        backgroundColor: Pallete.transparentColor,
        elevation: 0,
        leading: const BackButton(color: Pallete.blackColor),
      ),
      body: products.isEmpty
          ? Center(
              child: Text(
                'No favorites yet.',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Pallete.subtitleText),
              ),
            )
          : RefreshIndicator(
              onRefresh: () =>
                  ref.read(favoritesListProvider.notifier).refresh(),
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.55,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 12,
                ),
                itemCount: products.length,
                itemBuilder: (context, i) {
                  final p = products[i];
                  return ProductGridItem(
                    product: p,
                    onTap: () {
                      nav.setBottomBarVisible(true);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ProductDetailPage(productId: p.id),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
    );
  }
}

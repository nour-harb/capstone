import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_shopper/core/providers/current_user_notifier.dart';
import 'package:flutter_shopper/core/product/models/product_detail_state.dart';
import 'package:flutter_shopper/core/product/viewmodel/product_detail_viewmodel.dart';
import 'package:flutter_shopper/core/theme/app_pallete.dart';
import 'package:flutter_shopper/core/widgets/loader.dart';
import 'package:flutter_shopper/core/utils.dart';
import 'package:flutter_shopper/features/favorites/repositories/favorites_repository.dart';
import 'package:flutter_shopper/features/favorites/viewmodel/favorites_list_viewmodel.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductDetailPage extends ConsumerStatefulWidget {
  final int productId;
  const ProductDetailPage({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends ConsumerState<ProductDetailPage> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(
      productDetailViewModelProvider(productId: widget.productId),
    );
    final viewModel = ref.read(
      productDetailViewModelProvider(productId: widget.productId).notifier,
    );

    if (state.isLoading) return const Scaffold(body: Center(child: Loader()));

    if (state.errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Text(
            state.errorMessage!,
            style: const TextStyle(color: Pallete.greyColor),
          ),
        ),
      );
    }

    final product = state.product!;
    final user = ref.watch(currentUserProvider);
    final favoriteIcon = (product.favorited == true)
        ? const Icon(Icons.favorite, color: Colors.red)
        : const Icon(Icons.favorite_border, color: Pallete.blackColor);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildImageHeader(
            state,
            viewModel,
            _pageController,
            actions: user == null
                ? const <Widget>[]
                : <Widget>[
                    IconButton(
                      icon: favoriteIcon,
                      onPressed: () =>
                          _onFavoriteToggle(context, product.favorited == true),
                    ),
                  ],
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  product.brand.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  product.name,
                  style: Theme.of(
                    context,
                  ).textTheme.headlineMedium?.copyWith(fontSize: 22),
                ),
                const SizedBox(height: 8),
                Text(
                  formatLBP(state.displayPrice.toInt()),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (product.url != null && product.url!.trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.open_in_new, size: 22),
                    title: Text(
                      'View on brand site',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    onTap: () async {
                      final uri = Uri.tryParse(product.url!.trim());
                      if (uri == null || !uri.hasScheme) {
                        if (context.mounted) {
                          showSnackBar(context, 'Invalid link');
                        }
                        return;
                      }
                      final ok = await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                      if (context.mounted && !ok) {
                        showSnackBar(context, 'Could not open link');
                      }
                    },
                  ),
                ],
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(),
                ),

                Text(
                  'COLOR: ${state.selectedColor?.name.toUpperCase() ?? ""}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 10),
                _buildColorSelector(product, state, viewModel),

                const SizedBox(height: 20),
                const Text(
                  'SELECT SIZE',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const SizedBox(height: 10),
                _buildSizeSelector(state, viewModel),

                if (product.description != null &&
                    product.description!.trim().isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'DESCRIPTION',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product.description!,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Pallete.subtitleText,
                      height: 1.4,
                      fontSize: 14,
                    ),
                  ),
                ],
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onFavoriteToggle(BuildContext context, bool isFavorited) async {
    final repo = ref.read(favoritesRepositoryProvider);
    final result = isFavorited
        ? await repo.removeFavorite(widget.productId)
        : await repo.addFavorite(widget.productId);
    if (!context.mounted) return;
    result.fold((f) => showSnackBar(context, f.message), (_) {
      ref.invalidate(
        productDetailViewModelProvider(productId: widget.productId),
      );
      ref.invalidate(favoritesListProvider);
    });
  }

  Widget _buildImageHeader(
    ProductDetailState state,
    ProductDetailViewModel viewModel,
    PageController controller, {
    List<Widget> actions = const [],
  }) {
    return SliverAppBar(
      expandedHeight: 400,
      pinned: true,
      leading: const BackButton(color: Pallete.blackColor),
      actions: actions,
      backgroundColor: Pallete.backgroundColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          alignment: Alignment.center,
          children: [
            PageView.builder(
              controller: controller,
              onPageChanged: viewModel.updateImageIndex,
              itemCount: state.currentImages.length,
              itemBuilder: (context, index) =>
                  Image.network(state.currentImages[index], fit: BoxFit.cover),
            ),

            if (state.currentImageIndex > 0)
              Positioned(
                left: 8,
                child: CircleAvatar(
                  backgroundColor: Colors.white.withValues(alpha: 0.7),
                  child: IconButton(
                    icon: const Icon(Icons.chevron_left, color: Colors.black),
                    onPressed: () => controller.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    ),
                  ),
                ),
              ),

            if (state.currentImageIndex < state.currentImages.length - 1)
              Positioned(
                right: 8,
                child: CircleAvatar(
                  backgroundColor: Colors.white.withValues(alpha: 0.7),
                  child: IconButton(
                    icon: const Icon(Icons.chevron_right, color: Colors.black),
                    onPressed: () => controller.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    ),
                  ),
                ),
              ),

            if (state.currentImages.length > 1)
              Positioned(
                bottom: 12,
                child: Row(
                  children: List.generate(
                    state.currentImages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      height: 3,
                      width: state.currentImageIndex == index ? 16 : 4,
                      decoration: BoxDecoration(
                        color: state.currentImageIndex == index
                            ? Pallete.blackColor
                            : Pallete.greyColor.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorSelector(
    dynamic product,
    ProductDetailState state,
    ProductDetailViewModel viewModel,
  ) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: product.colors.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final color = product.colors[index];
          return ChoiceChip(
            label: Text(color.name, style: const TextStyle(fontSize: 12)),
            selected: state.selectedColorId == color.id,
            onSelected: (_) => viewModel.selectColor(color.id),
          );
        },
      ),
    );
  }

  Widget _buildSizeSelector(
    ProductDetailState state,
    ProductDetailViewModel viewModel,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: state.availableVariants.map((variant) {
        final bool isAvailable =
            variant.availability.toLowerCase() != 'out_of_stock';
        final bool isSelected = state.selectedSizeId == variant.size.id;

        return ChoiceChip(
          label: Text(
            variant.size.name,
            style: TextStyle(
              fontSize: 12,
              decoration: isAvailable ? null : TextDecoration.lineThrough,
              color: isAvailable ? null : Pallete.greyColor,
            ),
          ),
          selected: isSelected,
          onSelected: isAvailable
              ? (_) => viewModel.selectSize(variant.size.id)
              : null,
          disabledColor: Pallete.backgroundColor,
          selectedColor: Pallete.blackColor,
          side: BorderSide(
            color: isAvailable
                ? (isSelected ? Pallete.blackColor : Pallete.borderColor)
                : Pallete.borderColor.withValues(alpha: 0.3),
            width: isAvailable ? 1 : 0.5,
          ),
        );
      }).toList(),
    );
  }
}

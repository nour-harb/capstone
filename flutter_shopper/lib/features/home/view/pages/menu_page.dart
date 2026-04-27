import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_shopper/core/providers/current_user_notifier.dart';
import 'package:flutter_shopper/core/theme/app_pallete.dart';
import 'package:flutter_shopper/features/favorites/view/widgets/price_drop_banner.dart';
import 'package:flutter_shopper/features/home/viewmodel/home_viewmodel.dart';
import 'package:flutter_shopper/core/widgets/loader.dart';
import 'package:flutter_shopper/features/category_products/view/pages/products_screen.dart';

class MenuPage extends ConsumerStatefulWidget {
  const MenuPage({super.key});

  @override
  ConsumerState<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends ConsumerState<MenuPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(homeViewmodelProvider.notifier).loadCategories(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeViewmodelProvider);
    final homeNotifier = ref.read(homeViewmodelProvider.notifier);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (user != null) PriceDropBanner(key: ValueKey(user.id)),
          Expanded(
            child: homeState.when(
              loading: () => const Center(child: Loader()),
              error: (err, _) => Center(
                child: TextButton(
                  onPressed: () => homeNotifier.loadCategories(),
                  child: const Text('RETRY'),
                ),
              ),
              data: (categories) => Column(
                children: [
                  _buildGenderToggle(homeNotifier),
                  const Divider(),
                  Expanded(
                    child: ListView.separated(
                      itemCount: categories.length,
                      separatorBuilder: (_, __) =>
                          const Divider(indent: 24, endIndent: 24),
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return ListTile(
                          title: Text(category.name.toUpperCase()),
                          trailing: const Icon(Icons.chevron_right, size: 16),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ProductsScreen(
                                  menuCategoryId: category.id,
                                  menuCategoryName: category.name,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderToggle(HomeViewmodel homeNotifier) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: ['MAN', 'WOMAN'].map((gender) {
          final isSelected =
              homeNotifier.selectedGender == gender.toLowerCase();
          return GestureDetector(
            onTap: () => homeNotifier.selectGender(gender.toLowerCase()),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                gender,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w400,
                  color: isSelected ? Pallete.blackColor : Pallete.greyColor,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

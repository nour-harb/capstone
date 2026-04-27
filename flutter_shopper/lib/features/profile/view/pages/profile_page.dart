import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_shopper/core/providers/current_user_notifier.dart';
import 'package:flutter_shopper/core/providers/navigation_notifier.dart';
import 'package:flutter_shopper/core/theme/app_pallete.dart';
import 'package:flutter_shopper/core/utils.dart';
import 'package:flutter_shopper/core/widgets/loader.dart';
import 'package:flutter_shopper/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:flutter_shopper/features/profile/view/pages/delete_account_page.dart';
import 'package:flutter_shopper/features/profile/view/widgets/profile_field.dart';
import 'package:flutter_shopper/features/favorites/view/pages/favorites_page.dart';
import 'package:flutter_shopper/features/profile/viewmodel/profile_viewmodel.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final profileState = ref.watch(profileViewModelProvider);
    final isLoading = profileState.isLoading;
    final theme = Theme.of(context);

    ref.listen(
      profileViewModelProvider,
      (_, state) => state.whenOrNull(
        error: (error, _) => showSnackBar(context, error.toString()),
      ),
    );

    if (user == null) {
      return const Center(child: Text('No user logged in'));
    }

    final media = MediaQuery.of(context);
    final barOverlap = 1.0 + kBottomNavigationBarHeight + media.padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ACCOUNT'),
        centerTitle: true,
        backgroundColor: Pallete.transparentColor,
        elevation: 0,
      ),
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + barOverlap),
            children: [
              Text("PERSONAL DETAILS", style: theme.textTheme.labelSmall),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Pallete.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Pallete.shadowColor,
                      blurRadius: 6,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    ProfileField(label: "Full Name", value: user.name),
                    ProfileField(label: "Email Address", value: user.email),
                    ProfileField(
                      label: "Password",
                      value: "••••••••",
                      isPassword: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              Text('SAVED', style: theme.textTheme.labelSmall),
              const SizedBox(height: 12),
              Material(
                color: Pallete.cardColor,
                borderRadius: BorderRadius.circular(16),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 4,
                  ),
                  title: const Text('Favorites'),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: Pallete.greyColor,
                  ),
                  onTap: () {
                    ref
                        .read(navigationProvider.notifier)
                        .setBottomBarVisible(true);
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const FavoritesPage()),
                    );
                  },
                ),
              ),

              const SizedBox(height: 48),

              // logout Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          ref
                              .read(navigationProvider.notifier)
                              .setSelectedIndex(0);
                          ref.read(authViewModelProvider.notifier).logout();
                        },
                  child: const Text('LOG OUT'),
                ),
              ),
              const SizedBox(height: 16),

              // delete Account Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: isLoading
                      ? null
                      : () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DeleteAccountPage(),
                          ),
                        ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Pallete.errorColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'DELETE ACCOUNT',
                    style: TextStyle(
                      color: Pallete.errorColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // loader Overlay
          if (isLoading) const Loader(),
        ],
      ),
    );
  }
}

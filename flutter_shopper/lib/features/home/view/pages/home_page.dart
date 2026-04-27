import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_shopper/core/providers/current_user_notifier.dart';
import 'package:flutter_shopper/core/providers/navigation_notifier.dart';
import 'package:flutter_shopper/features/auth/view/pages/signin_page.dart';
import 'package:flutter_shopper/features/chat/view/pages/chat_page.dart';
import 'package:flutter_shopper/features/home/view/pages/menu_page.dart';
import 'package:flutter_shopper/features/profile/view/pages/profile_page.dart';
import 'package:flutter_shopper/features/search_products/views/pages/search_page.dart';

// globalKey to manage the navigator's state
final menuNavigatorKey = GlobalKey<NavigatorState>();
final searchNavigatorKey = GlobalKey<NavigatorState>();
final chatNavigatorKey = GlobalKey<NavigatorState>();
final profileNavigatorKey = GlobalKey<NavigatorState>();
final authNavigatorKey = GlobalKey<NavigatorState>();

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navState = ref.watch(navigationProvider);
    final user = ref.watch(currentUserProvider);

    final pages = [
      Navigator(
        key: menuNavigatorKey,
        onGenerateRoute: (_) =>
            MaterialPageRoute(builder: (_) => const MenuPage()),
      ),
      Navigator(
        key: searchNavigatorKey,
        onGenerateRoute: (_) =>
            MaterialPageRoute(builder: (_) => const SearchPage()),
      ),
      Navigator(
        key: chatNavigatorKey,
        onGenerateRoute: (_) =>
            MaterialPageRoute(builder: (_) => const ChatPage()),
      ),
      Navigator(
        key: user == null ? authNavigatorKey : profileNavigatorKey,
        onGenerateRoute: (_) => MaterialPageRoute(
          builder: (_) =>
              user != null ? const ProfilePage() : const SigninPage(),
        ),
      ),
    ];

    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    final double barHeight = kBottomNavigationBarHeight + bottomPadding;

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(index: navState.selectedIndex, children: pages),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOutCubic,
            left: 0,
            right: 0,
            bottom: navState.isBottomBarVisible ? 0 : -barHeight,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Divider(height: 1),
                BottomNavigationBar(
                  currentIndex: navState.selectedIndex,
                  onTap: (index) {
                    final navNotifier = ref.read(navigationProvider.notifier);

                    if (index == navState.selectedIndex) {
                      if (index == 0) {
                        menuNavigatorKey.currentState?.popUntil(
                          (r) => r.isFirst,
                        );
                      } else if (index == 1) {
                        searchNavigatorKey.currentState?.popUntil(
                          (r) => r.isFirst,
                        );
                      } else if (index == 2) {
                        chatNavigatorKey.currentState?.popUntil(
                          (r) => r.isFirst,
                        );
                      } else if (index == 3) {
                        if (user != null) {
                          profileNavigatorKey.currentState?.popUntil(
                            (r) => r.isFirst,
                          );
                        } else {
                          authNavigatorKey.currentState?.popUntil(
                            (r) => r.isFirst,
                          );
                        }
                      }
                    } else {
                      navNotifier.setSelectedIndex(index);
                    }
                  },
                  items: [
                    BottomNavigationBarItem(
                      icon: Icon(
                        navState.selectedIndex == 0
                            ? Icons.grid_view_rounded
                            : Icons.grid_view,
                      ),
                      label: 'Menu',
                    ),
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.search),
                      label: 'Search',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(
                        navState.selectedIndex == 2
                            ? Icons.chat_bubble_rounded
                            : Icons.chat_bubble_outline_rounded,
                      ),
                      label: 'Chat',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(
                        navState.selectedIndex == 3
                            ? Icons.person_rounded
                            : Icons.person_outline_rounded,
                      ),
                      label: user != null ? 'Profile' : 'Sign In',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

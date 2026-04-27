import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_shopper/core/providers/current_user_notifier.dart';
import 'package:flutter_shopper/core/theme/theme.dart';
import 'package:flutter_shopper/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:flutter_shopper/features/home/view/pages/home_page.dart';

void main() async {
  // ensures Flutter is fully initialized before running async operations.
  WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer();
  // create the authViewModel controller and initialize sharedPrefrences
  await container.read(authViewModelProvider.notifier).initSharedPreferences();
  // fetch user data if available
  await container.read(authViewModelProvider.notifier).getData();
  // run the app with the provider scope
  runApp(UncontrolledProviderScope(container: container, child: const MyApp()));
}

// extends ConsumerWidget to access Riverpod providers using WidgetRef
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // watches the currentUserProvider so the UI rebuilds when user data changes
    ref.watch(currentUserProvider);
    return MaterialApp(
      title: 'AI Shopper',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightThemeMode,
      home: const HomePage(),
    );
  }
}

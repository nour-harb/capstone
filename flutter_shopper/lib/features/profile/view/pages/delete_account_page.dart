import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_shopper/core/theme/app_pallete.dart';
import 'package:flutter_shopper/features/home/view/pages/home_page.dart';
import 'package:flutter_shopper/features/profile/viewmodel/profile_viewmodel.dart';
import 'package:flutter_shopper/core/widgets/custom_field.dart';
import 'package:flutter_shopper/core/utils.dart';
import 'package:flutter_shopper/core/widgets/loader.dart';

class DeleteAccountPage extends ConsumerStatefulWidget {
  const DeleteAccountPage({super.key});

  @override
  ConsumerState<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends ConsumerState<DeleteAccountPage> {
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileViewModelProvider);
    final isLoading = profileState.isLoading;
    final theme = Theme.of(context);

    ref.listen(profileViewModelProvider, (_, next) {
      if (!next.isLoading && !mounted) return;

      // account deletion completed successfully
      if (!isLoading && mounted) {
        showSnackBar(context, 'Account deleted successfully');

        // redirect to Home
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
          (_) => false,
        );
      }

      next.whenOrNull(error: (err, _) => showSnackBar(context, err.toString()));
    });

    return Scaffold(
      backgroundColor: Pallete.backgroundColor,
      appBar: AppBar(
        title: const Text('DELETE ACCOUNT'),
        centerTitle: true,
        backgroundColor: Pallete.transparentColor,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'WARNING',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Pallete.errorColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This action is permanent and cannot be undone. All your data will be removed. Please enter your password to confirm.',
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 32),
                  CustomField(
                    hintText: 'Password',
                    controller: passwordController,
                    isObscure: true,
                  ),
                  const SizedBox(height: 40),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isLoading
                              ? null
                              : () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Pallete.borderColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text('CANCEL'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () async {
                                  if (!formKey.currentState!.validate()) return;

                                  await ref
                                      .read(profileViewModelProvider.notifier)
                                      .deleteAccount(
                                        password: passwordController.text
                                            .trim(),
                                      );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Pallete.errorColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text('DELETE'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isLoading) const Loader(),
        ],
      ),
    );
  }
}

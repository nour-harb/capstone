import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_shopper/core/utils.dart' show showSnackBar;
import 'package:flutter_shopper/core/widgets/loader.dart';
import 'package:flutter_shopper/features/auth/view/pages/signin_page.dart';
import 'package:flutter_shopper/core/widgets/custom_field.dart';
import 'package:flutter_shopper/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:flutter_shopper/core/providers/current_user_notifier.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final isLoading = ref.watch(
      authViewModelProvider.select((state) => state.isLoading),
    );

    ref.listen(authViewModelProvider, (_, state) {
      state.whenOrNull(
        error: (error, stackTrace) => showSnackBar(context, error.toString()),
      );
    });

    ref.listen(currentUserProvider, (_, user) {
      if (user != null) {
        showSnackBar(context, 'Account created successfully! Please Sign In.');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SigninPage()),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Text('SIGN UP', style: textTheme.headlineMedium),
                    const SizedBox(height: 12),
                    Text(
                      'Create an account to get started.',
                      style: textTheme.bodyLarge?.copyWith(
                        color: textTheme.labelSmall?.color,
                      ),
                    ),
                    const SizedBox(height: 48),

                    CustomField(hintText: 'Name', controller: nameController),
                    const SizedBox(height: 16),
                    CustomField(
                      hintText: 'Email',
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    CustomField(
                      hintText: 'Password',
                      controller: passwordController,
                      isObscure: true,
                    ),
                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                if (formKey.currentState!.validate()) {
                                  ref
                                      .read(authViewModelProvider.notifier)
                                      .signup(
                                        name: nameController.text,
                                        email: emailController.text,
                                        password: passwordController.text,
                                      );
                                }
                              },
                        child: const Text('SIGN UP'),
                      ),
                    ),
                    const SizedBox(height: 24),

                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text.rich(
                        TextSpan(
                          text: 'Already have an account? ',
                          style: textTheme.bodyLarge?.copyWith(
                            fontSize: 14,
                            color: textTheme.labelSmall?.color,
                          ),
                          children: [
                            TextSpan(
                              text: 'Sign In',
                              style: TextStyle(
                                color: textTheme.bodyLarge?.color,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isLoading) const Loader(),
        ],
      ),
    );
  }
}

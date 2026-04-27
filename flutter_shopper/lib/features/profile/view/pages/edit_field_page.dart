import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_shopper/core/theme/app_pallete.dart';
import 'package:flutter_shopper/core/widgets/custom_field.dart';
import 'package:flutter_shopper/core/widgets/loader.dart';
import 'package:flutter_shopper/core/utils.dart';
import 'package:flutter_shopper/features/profile/viewmodel/profile_viewmodel.dart';

class EditFieldPage extends ConsumerStatefulWidget {
  final String label;
  final String value;
  final bool isPassword;

  const EditFieldPage({
    super.key,
    required this.label,
    required this.value,
    this.isPassword = false,
  });

  @override
  ConsumerState<EditFieldPage> createState() => _EditFieldPageState();
}

class _EditFieldPageState extends ConsumerState<EditFieldPage> {
  final oldController = TextEditingController();
  final newController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    oldController.dispose();
    newController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPassword = widget.isPassword;
    final state = ref.watch(profileViewModelProvider);
    final theme = Theme.of(context);
    final isLoading = state.isLoading;

    // listen for changes and show snackbars on success/error
    ref.listen(profileViewModelProvider, (previous, next) {
      // success: loading went from true -> false
      if (previous?.isLoading == true && !next.isLoading) {
        showSnackBar(context, '${widget.label} updated successfully!');
        Navigator.pop(context);
      }

      next.whenOrNull(error: (err, _) => showSnackBar(context, err.toString()));
    });

    return Scaffold(
      backgroundColor: Pallete.backgroundColor,
      appBar: AppBar(
        title: Text("EDIT ${widget.label.toUpperCase()}"),
        centerTitle: true,
        backgroundColor: Pallete.transparentColor,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // current value (if not password)
                  if (!isPassword) ...[
                    Text(
                      "CURRENT ${widget.label.toUpperCase()}",
                      style: theme.textTheme.labelSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.value,
                      style: theme.textTheme.bodyMedium?.copyWith(fontSize: 20),
                    ),
                    const SizedBox(height: 32),
                  ] else ...[
                    CustomField(
                      hintText: 'Current Password',
                      controller: oldController,
                      isObscure: true,
                    ),
                    const SizedBox(height: 20),
                  ],

                  // new value field
                  CustomField(
                    hintText: isPassword
                        ? 'New Password'
                        : 'New ${widget.label}',
                    controller: newController,
                    isObscure: isPassword,
                  ),
                  const SizedBox(height: 40),

                  // save changes button
                  ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            if (!formKey.currentState!.validate()) return;

                            final notifier = ref.read(
                              profileViewModelProvider.notifier,
                            );
                            final newVal = newController.text.trim();

                            if (isPassword) {
                              await notifier.changePassword(
                                oldPassword: oldController.text.trim(),
                                newPassword: newVal,
                              );
                            } else if (widget.label.toLowerCase().contains(
                              'name',
                            )) {
                              await notifier.updateName(newVal);
                            } else if (widget.label.toLowerCase().contains(
                              'email',
                            )) {
                              await notifier.updateEmail(newVal);
                            }
                          },
                    style: Theme.of(context).elevatedButtonTheme.style,
                    child: const Text('SAVE CHANGES'),
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

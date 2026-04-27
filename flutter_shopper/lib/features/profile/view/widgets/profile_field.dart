import 'package:flutter/material.dart';
import 'package:flutter_shopper/core/theme/app_pallete.dart';
import 'package:flutter_shopper/features/profile/view/pages/edit_field_page.dart';

class ProfileField extends StatelessWidget {
  final String label;
  final String value;
  final bool isPassword;

  const ProfileField({
    super.key,
    required this.label,
    required this.value,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Pallete.whiteColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Pallete.shadowColor,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EditFieldPage(
                  label: label,
                  value: value,
                  isPassword: isPassword,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label.toUpperCase(), style: textTheme.labelSmall),
                    const SizedBox(height: 4),
                    Text(
                      isPassword ? '••••••••' : value,
                      style: textTheme.bodyMedium,
                    ),
                  ],
                ),

                // Chevron icon
                const Icon(
                  Icons.chevron_right,
                  color: Pallete.inactiveBottomBarItemColor,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

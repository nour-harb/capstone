import 'package:flutter/material.dart';

class CustomField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final bool isObscure;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const CustomField({
    super.key,
    required this.hintText,
    required this.controller,
    this.isObscure = false,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(hintText: hintText),
      obscureText: isObscure,
      keyboardType: keyboardType,
      validator:
          validator ??
          (val) {
            if (val == null || val.trim().isEmpty) {
              return '$hintText is required';
            }
            return null;
          },
    );
  }
}

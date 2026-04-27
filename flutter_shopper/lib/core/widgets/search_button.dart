import 'package:flutter/material.dart';

class SearchButton extends StatelessWidget {
  final VoidCallback onTap;

  const SearchButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(icon: const Icon(Icons.search), onPressed: onTap);
  }
}

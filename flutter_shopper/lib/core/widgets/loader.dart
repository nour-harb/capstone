import 'package:flutter/material.dart';
import 'package:flutter_shopper/core/theme/app_pallete.dart';

class Loader extends StatelessWidget {
  const Loader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator.adaptive(
        valueColor: AlwaysStoppedAnimation<Color>(Pallete.blackColor),
      ),
    );
  }
}

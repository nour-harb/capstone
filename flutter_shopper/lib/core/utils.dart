import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shopper/core/theme/app_pallete.dart';

void showSnackBar(BuildContext context, String content) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          content,
          style: const TextStyle(
            color: Pallete.whiteColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Pallete.blackColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
}

String formatLBP(int price) {
  String priceStr = price.toString();
  String result = '';
  int count = 0;

  // iterate backwards to insert commas every three digits
  for (int i = priceStr.length - 1; i >= 0; i--) {
    result = priceStr[i] + result;
    count++;
    if (count % 3 == 0 && i != 0) {
      result = ',$result';
    }
  }
  return 'LBP $result';
}

Future<Uint8List?> compressImage(Uint8List bytes) async {
  final compressed = await FlutterImageCompress.compressWithList(
    bytes,
    minHeight: 1024,
    minWidth: 1024,
    quality: 80,
    format: CompressFormat.jpeg,
  );
  return compressed;
}

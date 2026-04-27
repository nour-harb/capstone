import 'package:flutter/material.dart';
import 'package:flutter_shopper/core/theme/app_pallete.dart';

class AppTheme {
  static OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderSide: BorderSide(color: color, width: 1),
    borderRadius: BorderRadius.circular(12),
  );

  static final lightThemeMode =
      ThemeData(
        scaffoldBackgroundColor: Pallete.backgroundColor,
        colorScheme: ColorScheme.fromSeed(seedColor: Pallete.blackColor),
        useMaterial3: true,
      ).copyWith(
        // Typography
        textTheme: _textTheme,

        // Buttons
        elevatedButtonTheme: _buttonTheme,

        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Pallete.whiteColor,
          elevation: 0,
          dragHandleColor: Pallete.borderColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
        ),

        dividerTheme: const DividerThemeData(
          color: Pallete.borderColor,
          thickness: 1,
          space: 0,
        ),

        chipTheme: ChipThemeData(
          backgroundColor: Pallete.whiteColor,
          selectedColor: Pallete.blackColor,
          side: const BorderSide(color: Pallete.borderColor),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          showCheckmark: false,
          labelStyle: const TextStyle(fontSize: 13, color: Pallete.blackColor),
          secondaryLabelStyle: const TextStyle(
            fontSize: 13,
            color: Pallete.whiteColor,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),

        inputDecorationTheme: InputDecorationTheme(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          fillColor: Pallete.whiteColor,
          filled: true,
          enabledBorder: _border(Pallete.borderColor),
          focusedBorder: _border(Pallete.blackColor),
          errorBorder: _border(Pallete.errorColor.withValues(alpha: 0.5)),
          focusedErrorBorder: _border(Pallete.errorColor),
          labelStyle: const TextStyle(color: Pallete.greyColor, fontSize: 14),
          hintStyle: const TextStyle(color: Pallete.subtitleText, fontSize: 14),
        ),

        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Pallete.whiteColor,
          selectedItemColor: Pallete.blackColor,
          unselectedItemColor: Pallete.greyColor,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
        ),

        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Pallete.blackColor,
          foregroundColor: Pallete.whiteColor,
          elevation: 2,
        ),
      );

  static final _textTheme = TextTheme(
    headlineMedium: const TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w900,
      color: Pallete.blackColor,
      letterSpacing: -0.5,
    ),
    bodyLarge: const TextStyle(
      fontSize: 16,
      color: Pallete.blackColor,
      fontWeight: FontWeight.w500,
    ),
    labelSmall: const TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.bold,
      color: Pallete.subtitleText,
      letterSpacing: 0.5,
    ),
    bodyMedium: const TextStyle(
      // <-- new
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Pallete.blackColor,
    ),
  );

  static final _buttonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Pallete.blackColor,
      foregroundColor: Pallete.whiteColor,
      minimumSize: const Size(double.infinity, 56),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
    ),
  );
}

import 'package:flutter/material.dart';

class AppFonts {
  AppFonts._();

  static const String primaryFontFamily = 'Roboto';

  static const List<String> fontFallbacks = [
    'Manjari',
    'Gayathri',
    'Noto Sans Malayalam',
    'sans-serif',
  ];

  static TextStyle displayLarge({required Color color}) {
    return TextStyle(
      fontFamily: primaryFontFamily,
      fontFamilyFallback: fontFallbacks,
      fontSize: 32,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.5,
      color: color,
    );
  }

  static TextStyle displayMedium({required Color color}) {
    return TextStyle(
      fontFamily: primaryFontFamily,
      fontFamilyFallback: fontFallbacks,
      fontSize: 26,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.4,
      color: color,
    );
  }

  static TextStyle titleLarge({required Color color}) {
    return TextStyle(
      fontFamily: primaryFontFamily,
      fontFamilyFallback: fontFallbacks,
      fontSize: 20,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.2,
      color: color,
    );
  }

  static TextStyle titleMedium({required Color color}) {
    return TextStyle(
      fontFamily: primaryFontFamily,
      fontFamilyFallback: fontFallbacks,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: color,
    );
  }

  static TextStyle bodyLarge({required Color color}) {
    return TextStyle(
      fontFamily: primaryFontFamily,
      fontFamilyFallback: fontFallbacks,
      fontSize: 15,
      fontWeight: FontWeight.w400,
      color: color,
    );
  }

  static TextStyle bodyMedium({required Color color}) {
    return TextStyle(
      fontFamily: primaryFontFamily,
      fontFamilyFallback: fontFallbacks,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: color,
    );
  }

  static TextStyle labelLarge({required Color color}) {
    return TextStyle(
      fontFamily: primaryFontFamily,
      fontFamilyFallback: fontFallbacks,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      color: color,
    );
  }

  static TextStyle labelSmall({required Color color}) {
    return TextStyle(
      fontFamily: primaryFontFamily,
      fontFamilyFallback: fontFallbacks,
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: color,
    );
  }

  static TextStyle numberLarge({required Color color}) {
    return TextStyle(
      fontFamily: primaryFontFamily,
      fontSize: 24,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
      color: color,
    );
  }
}

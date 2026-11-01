import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppFonts {
  AppFonts._();

  static const List<String> fontFallbacks = [
    'Manjari',
    'Gayathri',
    'Noto Sans Malayalam',
    'sans-serif',
  ];

  static TextStyle displayLarge({required Color color}) {
    return GoogleFonts.manrope(
      fontSize: 32,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.5,
      color: color,
    );
  }

  static TextStyle displayMedium({required Color color}) {
    return GoogleFonts.manrope(
      fontSize: 26,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.4,
      color: color,
    );
  }

  static TextStyle displaySmall({required Color color}) {
    return GoogleFonts.manrope(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.3,
      color: color,
    );
  }

  static TextStyle titleLarge({required Color color}) {
    return GoogleFonts.manrope(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.2,
      color: color,
    );
  }

  static TextStyle titleMedium({required Color color}) {
    return GoogleFonts.manrope(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: color,
    );
  }

  static TextStyle titleSmall({required Color color}) {
    return GoogleFonts.manrope(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: color,
    );
  }

  static TextStyle bodyLarge({required Color color}) {
    return GoogleFonts.manrope(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      color: color,
    );
  }

  static TextStyle bodyMedium({required Color color}) {
    return GoogleFonts.manrope(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: color,
    );
  }

  static TextStyle labelLarge({required Color color}) {
    return GoogleFonts.manrope(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      color: color,
    );
  }

  static TextStyle labelSmall({required Color color}) {
    return GoogleFonts.manrope(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: color,
    );
  }

  static TextStyle headlineSmall({required Color color}) {
    return GoogleFonts.manrope(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: color,
    );
  }

  static TextStyle labelMedium({required Color color}) {
    return GoogleFonts.manrope(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: color,
    );
  }

  static TextStyle bodySmall({required Color color}) {
    return GoogleFonts.manrope(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: color,
    );
  }

  static TextStyle numberLarge({required Color color}) {
    return GoogleFonts.manrope(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
      color: color,
    );
  }

  static TextTheme textTheme(Brightness brightness) {
    final baseTheme = brightness == Brightness.dark
        ? ThemeData.dark().textTheme
        : ThemeData.light().textTheme;
    final primaryTheme = GoogleFonts.manropeTextTheme(baseTheme);
    return primaryTheme.copyWith(
      displayLarge: GoogleFonts.manrope(textStyle: primaryTheme.displayLarge),
      displayMedium: GoogleFonts.manrope(textStyle: primaryTheme.displayMedium),
      displaySmall: GoogleFonts.manrope(textStyle: primaryTheme.displaySmall),
      headlineLarge: GoogleFonts.manrope(textStyle: primaryTheme.headlineLarge),
      headlineMedium: GoogleFonts.manrope(
        textStyle: primaryTheme.headlineMedium,
      ),
      headlineSmall: GoogleFonts.manrope(textStyle: primaryTheme.headlineSmall),
      titleLarge: GoogleFonts.manrope(textStyle: primaryTheme.titleLarge),
      titleMedium: GoogleFonts.manrope(textStyle: primaryTheme.titleMedium),
    );
  }
}

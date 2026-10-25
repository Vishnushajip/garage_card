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
    return GoogleFonts.outfit(
      fontSize: 32,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.5,
      color: color,
    );
  }

  static TextStyle displayMedium({required Color color}) {
    return GoogleFonts.outfit(
      fontSize: 26,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.4,
      color: color,
    );
  }

  static TextStyle titleLarge({required Color color}) {
    return GoogleFonts.outfit(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.2,
      color: color,
    );
  }

  static TextStyle titleMedium({required Color color}) {
    return GoogleFonts.outfit(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: color,
    );
  }

  static TextStyle bodyLarge({required Color color}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      color: color,
    );
  }

  static TextStyle bodyMedium({required Color color}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: color,
    );
  }

  static TextStyle labelLarge({required Color color}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      color: color,
    );
  }

  static TextStyle labelSmall({required Color color}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: color,
    );
  }

  static TextStyle numberLarge({required Color color}) {
    return GoogleFonts.outfit(
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
    final primaryTheme = GoogleFonts.plusJakartaSansTextTheme(baseTheme);
    return primaryTheme.copyWith(
      displayLarge: GoogleFonts.outfit(textStyle: primaryTheme.displayLarge),
      displayMedium: GoogleFonts.outfit(textStyle: primaryTheme.displayMedium),
      displaySmall: GoogleFonts.outfit(textStyle: primaryTheme.displaySmall),
      headlineLarge: GoogleFonts.outfit(textStyle: primaryTheme.headlineLarge),
      headlineMedium: GoogleFonts.outfit(
        textStyle: primaryTheme.headlineMedium,
      ),
      headlineSmall: GoogleFonts.outfit(textStyle: primaryTheme.headlineSmall),
      titleLarge: GoogleFonts.outfit(textStyle: primaryTheme.titleLarge),
      titleMedium: GoogleFonts.outfit(textStyle: primaryTheme.titleMedium),
    );
  }
}

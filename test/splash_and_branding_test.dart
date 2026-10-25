import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garage_card/core/branding/app_branding.dart';
import 'package:garage_card/core/branding/app_logo.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/features/splash/Widgets/splash_reveal_painter.dart';
import 'package:garage_card/features/splash/Widgets/splash_tachometer_painter.dart';

void main() {
  group('WeFix Branding & Logo Tests', () {
    test('AppBranding constants reflect WeFix brand identity', () {
      expect(AppBranding.appName, equals('WeFix'));
      expect(
        AppBranding.appTagline,
        equals('Vehicle Service & Garage Management Platform'),
      );
      expect(AppBranding.defaultSupportEmail, equals('support@wefix.app'));
    });

    testWidgets('AppLogo renders with default badge', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: AppLogo(size: 64, showBadge: true)),
          ),
        ),
      );

      expect(find.byType(AppLogo), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('AppLogo renders with wordmark', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: AppLogo(size: 80, showBadge: true, showWordmark: true),
            ),
          ),
        ),
      );

      expect(find.byType(AppLogo), findsOneWidget);
      expect(find.text('VEHICLE SERVICE PLATFORM'), findsOneWidget);
    });

    testWidgets('AppLogo renders in white variant for dark backgrounds', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            backgroundColor: AppColors.primaryRed,
            body: Center(
              child: AppLogo(
                size: 80,
                showBadge: false,
                isWhiteVariant: true,
                showWordmark: true,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(AppLogo), findsOneWidget);
      expect(find.text('VEHICLE SERVICE PLATFORM'), findsOneWidget);
    });
  });

  group('SplashRevealPainter Tests', () {
    test('SplashRevealPainter initializes and reports repaint correctly', () {
      const painter1 = SplashRevealPainter(progress: 0.25);
      const painter2 = SplashRevealPainter(progress: 0.5);
      const painter3 = SplashRevealPainter(progress: 0.25);

      expect(painter1.shouldRepaint(painter2), isTrue);
      expect(painter1.shouldRepaint(painter3), isFalse);
    });

    testWidgets(
      'SplashRevealPainter renders smoothly at different progress levels',
      (tester) async {
        for (final progress in [0.0, 0.25, 0.5, 0.75, 1.0]) {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: CustomPaint(
                  size: const Size(400, 800),
                  painter: SplashRevealPainter(
                    progress: progress,
                    revealColor: AppColors.primaryRed,
                  ),
                ),
              ),
            ),
          );
          expect(find.byType(CustomPaint), findsWidgets);
        }
      },
    );
  });

  group('SplashTachometerPainter Tests', () {
    test('SplashTachometerPainter handles repaint logic', () {
      const p1 = SplashTachometerPainter(
        arcProgress: 0.5,
        pulseValue: 1.0,
        sparkRippleProgress: 0.2,
      );
      const p2 = SplashTachometerPainter(
        arcProgress: 0.6,
        pulseValue: 1.0,
        sparkRippleProgress: 0.2,
      );
      const p3 = SplashTachometerPainter(
        arcProgress: 0.5,
        pulseValue: 1.0,
        sparkRippleProgress: 0.2,
      );

      expect(p1.shouldRepaint(p2), isTrue);
      expect(p1.shouldRepaint(p3), isFalse);
    });

    testWidgets('SplashTachometerPainter renders gauge ticks and arc', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: CustomPaint(
                size: Size(150, 150),
                painter: SplashTachometerPainter(
                  arcProgress: 0.75,
                  pulseValue: 1.02,
                  sparkRippleProgress: 0.5,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CustomPaint), findsWidgets);
    });
  });
}

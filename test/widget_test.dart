import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garage_card/app.dart';
import 'package:garage_card/core/branding/app_branding.dart';
import 'package:garage_card/features/splash/View/splash_screen.dart';

void main() {
  testWidgets(
    'App launches with WeFix splash screen and transitions to auth screen',
    (tester) async {
      await tester.pumpWidget(const ProviderScope(child: GarageCardApp()));

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.text('VEHICLE SERVICE PLATFORM'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 3500));
      await tester.pumpAndSettle();

      expect(find.text(AppBranding.appName), findsWidgets);
      expect(find.text('Continue with Google'), findsOneWidget);
    },
  );
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garage_card/app.dart';
import 'package:garage_card/core/branding/app_branding.dart';

void main() {
  testWidgets('App launches with authentication screen', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: GarageCardApp(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text(AppBranding.appName), findsWidgets);
    expect(find.text('Sign In to Account'), findsOneWidget);
  });
}

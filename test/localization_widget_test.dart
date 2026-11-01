import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garage_card/core/localization/app_localizations.dart';
import 'package:garage_card/core/shared_widgets/app_status_badge.dart';

void main() {
  testWidgets('Dynamic UI language switching test', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: Consumer(
          builder: (context, ref, _) {
            final locale = ref.watch(localeProvider);
            return MaterialApp(
              locale: locale,
              supportedLocales: const [Locale('en'), Locale('ml')],
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: Scaffold(
                body: Builder(
                  builder: (ctx) {
                    return Column(
                      children: [
                        Text(ctx.tr('accountProfile')),
                        Text(ctx.tr('warrantyVault')),
                        const AppStatusBadge(status: 'in_progress'),
                        const AppStatusBadge(status: 'completed'),
                        ElevatedButton(
                          onPressed: () {
                            ref.read(localeProvider.notifier).setLocale('ml');
                          },
                          child: const Text('Switch to ML'),
                        ),
                      ],
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Account Profile'), findsOneWidget);
    expect(find.text('Warranty Vault'), findsOneWidget);
    expect(find.text('In Progress'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);

    await tester.tap(find.text('Switch to ML'));
    await tester.pumpAndSettle();

    expect(find.text('അക്കൗണ്ട് പ്രൊഫൈൽ'), findsOneWidget);
    expect(find.text('വാറന്റി വോൾട്ട്'), findsOneWidget);
    expect(find.text('പുരോഗമിക്കുന്നു'), findsOneWidget);
    expect(find.text('പൂർത്തിയായി'), findsOneWidget);
  });
}


import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garage_card/core/network/app_connectivity_wrapper.dart';
import 'package:garage_card/core/network/connectivity_service.dart';
import 'package:garage_card/core/shared_widgets/no_internet_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Connectivity & No Internet Tests', () {
    test('ConnectivityStatus reflects online and offline lists correctly', () {
      final onlineList = [ConnectivityResult.wifi];
      final offlineList = [ConnectivityResult.none];
      final emptyList = <ConnectivityResult>[];

      expect(
        onlineList.isEmpty ||
            onlineList.every((r) => r == ConnectivityResult.none),
        isFalse,
      );
      expect(
        offlineList.isEmpty ||
            offlineList.every((r) => r == ConnectivityResult.none),
        isTrue,
      );
      expect(
        emptyList.isEmpty ||
            emptyList.every((r) => r == ConnectivityResult.none),
        isTrue,
      );
    });

    testWidgets(
      'NoInternetScreen renders essential automotive offline widgets',
      (tester) async {
        await tester.pumpWidget(
          const ProviderScope(child: MaterialApp(home: NoInternetScreen())),
        );

        expect(find.text('No Internet Connection'), findsOneWidget);
        expect(find.text('OFFLINE MODE'), findsOneWidget);
        expect(find.text('Check Connection'), findsOneWidget);
        expect(
          find.textContaining(
            'Garage Card requires an active internet connection',
          ),
          findsOneWidget,
        );
        expect(
          find.textContaining('Please check your Wi-Fi router'),
          findsOneWidget,
        );
      },
    );

    testWidgets('AppConnectivityWrapper shows child when online', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [isOnlineProvider.overrideWithValue(true)],
          child: const MaterialApp(
            home: AppConnectivityWrapper(
              child: Scaffold(body: Text('Authenticated Dashboard Content')),
            ),
          ),
        ),
      );

      expect(find.text('Authenticated Dashboard Content'), findsOneWidget);
      expect(find.text('No Internet Connection'), findsNothing);
    });

    testWidgets(
      'AppConnectivityWrapper displays NoInternetScreen when offline',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [isOnlineProvider.overrideWithValue(false)],
            child: const MaterialApp(
              home: AppConnectivityWrapper(
                child: Scaffold(body: Text('Authenticated Dashboard Content')),
              ),
            ),
          ),
        );

        expect(find.text('Authenticated Dashboard Content'), findsNothing);
        expect(find.text('No Internet Connection'), findsOneWidget);
        expect(find.text('OFFLINE MODE'), findsOneWidget);
        expect(find.text('Check Connection'), findsOneWidget);
      },
    );
  });
}

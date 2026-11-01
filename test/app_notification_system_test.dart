import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garage_card/core/notifications/app_notification_host.dart';
import 'package:garage_card/core/notifications/app_notification_model.dart';
import 'package:garage_card/core/notifications/app_notification_service.dart';
import 'package:garage_card/core/notifications/app_notification_toast.dart';

void main() {
  group('AppNotificationItem & Notifier Unit Tests', () {
    test('notifier manages show, update, and dismiss correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(appNotificationListProvider.notifier);

      final id = notifier.show(
        message: 'Test success',
        type: AppNotificationType.success,
      );

      var list = container.read(appNotificationListProvider);
      expect(list.length, equals(1));
      expect(list.first.message, equals('Test success'));
      expect(list.first.type, equals(AppNotificationType.success));

      notifier.update(
        id,
        message: 'Updated message',
        type: AppNotificationType.info,
      );

      list = container.read(appNotificationListProvider);
      expect(list.first.message, equals('Updated message'));
      expect(list.first.type, equals(AppNotificationType.info));

      notifier.dismiss(id);
      list = container.read(appNotificationListProvider);
      expect(list.isEmpty, isTrue);
    });

    test('notifier caps stack at 3 notifications', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(appNotificationListProvider.notifier);

      notifier.show(message: '1', type: AppNotificationType.info);
      notifier.show(message: '2', type: AppNotificationType.info);
      notifier.show(message: '3', type: AppNotificationType.info);
      notifier.show(message: '4', type: AppNotificationType.info);

      final list = container.read(appNotificationListProvider);
      expect(list.length, equals(3));
      expect(list.map((n) => n.message).toList(), equals(['2', '3', '4']));
    });
  });

  group('AppNotification UI Widget Tests', () {
    testWidgets('AppNotificationToast renders all notification variants', (
      tester,
    ) async {
      final item = AppNotificationItem(
        id: 'test_1',
        title: 'Operation Complete',
        message: 'Garage details saved successfully.',
        type: AppNotificationType.success,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppNotificationToast(item: item, onDismiss: () {}),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Operation Complete'), findsOneWidget);
      expect(find.text('Garage details saved successfully.'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });

    testWidgets(
      'AppNotificationToast renders action button and fires callback',
      (tester) async {
        bool actionFired = false;
        final item = AppNotificationItem(
          id: 'test_action',
          message: 'Failed to sync with cloud.',
          type: AppNotificationType.error,
          actionLabel: 'Retry Sync',
          onAction: () {
            actionFired = true;
          },
          createdAt: DateTime.now(),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppNotificationToast(item: item, onDismiss: () {}),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Retry Sync'), findsOneWidget);
        await tester.tap(find.text('Retry Sync'));
        await tester.pump();

        expect(actionFired, isTrue);
      },
    );

    testWidgets(
      'AppNotificationHost renders floating notification above child',
      (tester) async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              home: AppNotificationHost(
                child: Scaffold(body: Text('Underlying App Screen Content')),
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Underlying App Screen Content'), findsOneWidget);

        AppNotificationService.success(
          'Profile updated via centralized system',
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(
          find.text('Profile updated via centralized system'),
          findsOneWidget,
        );
        await tester.pump(const Duration(seconds: 5));
      },
    );

    testWidgets('AppNotificationToast renders loading state and progress', (
      tester,
    ) async {
      final item = AppNotificationItem(
        id: 'test_loading',
        title: 'Uploading',
        message: 'Uploading package image...',
        type: AppNotificationType.loading,
        progress: 0.65,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppNotificationToast(item: item, onDismiss: () {}),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Uploading'), findsOneWidget);
      expect(find.text('Uploading package image...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('AppNotificationToast invokes onDismiss when close tapped', (
      tester,
    ) async {
      bool dismissed = false;
      final item = AppNotificationItem(
        id: 'test_dismiss',
        message: 'Dismissable alert',
        type: AppNotificationType.info,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppNotificationToast(
              item: item,
              onDismiss: () => dismissed = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      expect(dismissed, isTrue);
    });

    testWidgets('renders Malayalam notification text without overflow', (
      tester,
    ) async {
      final item = AppNotificationItem(
        id: 'test_ml',
        title: 'വിജയകരം',
        message: 'ഗാരേജ് വിവരങ്ങൾ വിജയകരമായി സേവ് ചെയ്തു.',
        type: AppNotificationType.success,
        createdAt: DateTime.now(),
      );

      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppNotificationToast(item: item, onDismiss: () {}),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('വിജയകരം'), findsOneWidget);
      expect(
        find.text('ഗാരേജ് വിവരങ്ങൾ വിജയകരമായി സേവ് ചെയ്തു.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  });
}

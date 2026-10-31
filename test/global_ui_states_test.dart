import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garage_card/core/shared_widgets/app_empty_state.dart';
import 'package:garage_card/core/shared_widgets/app_error_state.dart';
import 'package:garage_card/core/shared_widgets/app_loading_overlay.dart';
import 'package:garage_card/core/shared_widgets/app_loading_state.dart';
import 'package:garage_card/core/shared_widgets/app_offline_state.dart';
import 'package:garage_card/core/shared_widgets/app_permission_state.dart';
import 'package:garage_card/core/shared_widgets/app_retry_button.dart';
import 'package:garage_card/core/shared_widgets/app_search_empty_state.dart';
import 'package:garage_card/core/shared_widgets/app_skeleton_loader.dart';
import 'package:garage_card/core/shared_widgets/app_unauthorized_state.dart';

void main() {
  group('AppEmptyState Widget Tests', () {
    testWidgets('renders title, description and triggers actions', (
      tester,
    ) async {
      bool primaryClicked = false;
      bool secondaryClicked = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppEmptyState(
              title: 'No Repair Jobs Found',
              description: 'You have not registered any repair jobs yet.',
              icon: Icons.car_repair_rounded,
              actionLabel: 'Create New Job',
              onAction: () => primaryClicked = true,
              secondaryActionLabel: 'Learn More',
              onSecondaryAction: () => secondaryClicked = true,
            ),
          ),
        ),
      );

      expect(find.text('No Repair Jobs Found'), findsOneWidget);
      expect(
        find.text('You have not registered any repair jobs yet.'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.car_repair_rounded), findsOneWidget);

      await tester.tap(find.text('Create New Job'));
      expect(primaryClicked, isTrue);

      await tester.tap(find.text('Learn More'));
      expect(secondaryClicked, isTrue);
    });

    testWidgets('renders zero overflow across 320px to 1440px viewports', (
      tester,
    ) async {
      const widths = [320.0, 375.0, 768.0, 1024.0, 1440.0];

      for (final w in widths) {
        tester.view.physicalSize = Size(w, 800);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppEmptyState(
                title: 'You haven\'t registered a garage yet',
                description: 'Set up your garage profile, trading name, and business address to start managing repair jobs, clients, and digital invoices.',
                icon: Icons.storefront_rounded,
                actionLabel: 'Add Your Garage',
                onAction: () {},
                layoutSize: AppStateLayoutSize.standard,
              ),
            ),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
      }
      tester.view.resetPhysicalSize();
    });
  });

  group('AppSearchEmptyState Widget Tests', () {
    testWidgets(
      'displays query and handles clear filters & modify query actions',
      (tester) async {
        bool filtersCleared = false;
        bool queryModified = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppSearchEmptyState(
                searchQuery: 'Brake Disc',
                hasActiveFilters: true,
                onClearFilters: () => filtersCleared = true,
                onModifyQuery: () => queryModified = true,
              ),
            ),
          ),
        );

        expect(find.text('No matches for "Brake Disc"'), findsOneWidget);
        expect(find.text('Clear All Filters'), findsOneWidget);
        expect(find.text('Change Search Query'), findsOneWidget);

        await tester.tap(find.text('Clear All Filters'));
        expect(filtersCleared, isTrue);

        await tester.tap(find.text('Change Search Query'));
        expect(queryModified, isTrue);
      },
    );
  });

  group('AppErrorState Widget Tests', () {
    testWidgets(
      'renders error details, toggles technical details and triggers retry',
      (tester) async {
        bool retried = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppErrorState(
                title: 'Server Connection Timeout',
                message: 'Unable to reach the garage service. Please check your network.',
                errorType: AppErrorType.timeout,
                technicalDetails: 'Status: 504 Gateway Timeout on /api/garages',
                onRetry: () => retried = true,
              ),
            ),
          ),
        );

        expect(find.text('Server Connection Timeout'), findsOneWidget);
        expect(find.byIcon(Icons.timer_off_outlined), findsOneWidget);
        expect(find.text('Show details'), findsOneWidget);
        expect(
          find.text('Status: 504 Gateway Timeout on /api/garages'),
          findsNothing,
        );

        await tester.tap(find.text('Show details'));
        await tester.pump();
        expect(
          find.text('Status: 504 Gateway Timeout on /api/garages'),
          findsOneWidget,
        );
        expect(find.text('Hide details'), findsOneWidget);

        await tester.tap(find.text('Try Again'));
        await tester.pump();
        expect(retried, isTrue);
      },
    );
  });

  group('AppOfflineState Widget Tests', () {
    testWidgets('renders inline banner when isCachedData is true', (
      tester,
    ) async {
      bool syncRetried = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppOfflineState(
              isCachedData: true,
              lastSyncedAt: DateTime.now().subtract(const Duration(minutes: 5)),
              onRetry: () => syncRetried = true,
            ),
          ),
        ),
      );

      expect(find.text('Offline — Showing cached data'), findsOneWidget);
      expect(find.text('Last updated 5 mins ago'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.refresh_rounded));
      expect(syncRetried, isTrue);
    });

    testWidgets('renders full offline view when isCachedData is false', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AppOfflineState(isCachedData: false)),
        ),
      );

      expect(find.text('No Internet Connection'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
    });
  });

  group('AppPermissionState & AppUnauthorizedState Widget Tests', () {
    testWidgets('renders location permission details and actions', (
      tester,
    ) async {
      bool primaryClicked = false;
      bool manualClicked = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppPermissionState(
              permissionType: AppPermissionType.location,
              onPrimaryAction: () => primaryClicked = true,
              secondaryActionLabel: 'Select Manually',
              onSecondaryAction: () => manualClicked = true,
            ),
          ),
        ),
      );

      expect(find.text('Location Permission Needed'), findsOneWidget);
      expect(find.text('Enable Location'), findsOneWidget);
      expect(find.text('Select Manually'), findsOneWidget);

      await tester.tap(find.text('Enable Location'));
      expect(primaryClicked, isTrue);

      await tester.tap(find.text('Select Manually'));
      expect(manualClicked, isTrue);
    });

    testWidgets('renders unauthorized and session expired states', (
      tester,
    ) async {
      bool actionTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppUnauthorizedState(
              isSessionExpired: true,
              onAction: () => actionTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Session Expired'), findsOneWidget);
      expect(find.text('Sign In Again'), findsOneWidget);

      await tester.tap(find.text('Sign In Again'));
      expect(actionTapped, isTrue);
    });
  });

  group('AppSkeletonLoader & AppLoadingOverlay Tests', () {
    testWidgets('skeleton card and list render smoothly without throwing', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                AppSkeletonLoader.card(height: 100),
                Expanded(child: AppSkeletonLoader.list(itemCount: 2)),
              ],
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(AppSkeletonLoader), findsWidgets);
    });

    testWidgets('loading overlay absorbs pointer events when active', (
      tester,
    ) async {
      bool childTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppLoadingOverlay(
              isLoading: true,
              message: 'Processing Payment...',
              child: ElevatedButton(
                onPressed: () => childTapped = true,
                child: const Text('Submit Payment'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Processing Payment...'), findsOneWidget);
      expect(
        find.byWidgetPredicate((w) => w is AbsorbPointer && w.absorbing),
        findsOneWidget,
      );

      await tester.tap(find.text('Submit Payment'), warnIfMissed: false);
      expect(childTapped, isFalse);
    });

    testWidgets(
      'AppRetryButton handles async operation with loading feedback',
      (tester) async {
        int calls = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppRetryButton(
                onRetry: () async {
                  calls++;
                  await Future.delayed(const Duration(milliseconds: 50));
                },
              ),
            ),
          ),
        );

        expect(find.text('Try Again'), findsOneWidget);
        await tester.tap(find.text('Try Again'));
        await tester.pump();

        expect(calls, 1);
        await tester.pump(const Duration(milliseconds: 100));
      },
    );

    testWidgets(
      'AppLoadingState renders title, description, and cancel action',
      (tester) async {
        bool cancelled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppLoadingState(
                title: 'Locating nearby garages...',
                description: 'Searching within a 10 km radius',
                onCancel: () => cancelled = true,
                cancelLabel: 'Stop Search',
              ),
            ),
          ),
        );

        expect(find.text('Locating nearby garages...'), findsOneWidget);
        expect(find.text('Searching within a 10 km radius'), findsOneWidget);
        expect(find.text('Stop Search'), findsOneWidget);

        await tester.tap(find.text('Stop Search'));
        expect(cancelled, isTrue);
      },
    );
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garage_card/features/merchant/dashboard/Model/merchant_dashboard_state.dart';
import 'package:garage_card/features/merchant/dashboard/View/merchant_dashboard_screen.dart';
import 'package:garage_card/features/merchant/dashboard/ViewModel/merchant_dashboard_view_model.dart';
import 'package:garage_card/features/shared/models/garage_model.dart';

class _TestDashboardViewModel extends MerchantDashboardViewModel {
  @override
  MerchantDashboardState build() {
    return const MerchantDashboardState(
      isLoading: false,
      garage: GarageModel(
        id: 'g_test',
        name: 'Test Garage',
        address: 'MG Road, Kochi',
        phone: '+91 98460 12345',
        email: 'test@garage.com',
        ownerUid: 'uid_test',
      ),
      recentJobs: [],
    );
  }
}

void main() {
  group('Merchant Dashboard Daily Pipeline Layout Tests', () {
    testWidgets(
      'Daily pipeline renders 3 cards with identical height and single-line labels',
      (tester) async {
        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          MaterialApp(
            home: ProviderScope(
              overrides: [
                merchantDashboardViewModelProvider.overrideWith(
                  () => _TestDashboardViewModel(),
                ),
              ],
              child: MerchantDashboardScreen(
                onNavigateToJobs: () {},
                onNavigateToCustomers: () {},
                onNavigateToEstimates: () {},
                onNavigateToInvoices: () {},
                onNavigateToAppointments: () {},
                onNavigateToAnalytics: () {},
                onJobSelected: (_) {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Daily Pipeline'), findsOneWidget);
        expect(find.text('Due Today'), findsOneWidget);
        expect(find.text('Completed'), findsOneWidget);
        expect(find.text('Payment Due'), findsOneWidget);
        expect(find.text('Vehicles'), findsOneWidget);
        expect(find.text('Yesterday'), findsOneWidget);
        expect(find.text('Invoices'), findsWidgets);
        expect(find.text('Outstanding Receivables'), findsOneWidget);

        final dueTodayContainer = find
            .ancestor(
              of: find.text('Due Today'),
              matching: find.byType(Container),
            )
            .first;
        final completedContainer = find
            .ancestor(
              of: find.text('Completed'),
              matching: find.byType(Container),
            )
            .first;
        final paymentDueContainer = find
            .ancestor(
              of: find.text('Payment Due'),
              matching: find.byType(Container),
            )
            .first;

        final dueTodaySize = tester.getSize(dueTodayContainer);
        final completedSize = tester.getSize(completedContainer);
        final paymentDueSize = tester.getSize(paymentDueContainer);

        expect(dueTodaySize.height, equals(completedSize.height));
        expect(completedSize.height, equals(paymentDueSize.height));
        expect(tester.takeException(), isNull);
      },
    );
  });
}

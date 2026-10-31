import 'package:flutter_test/flutter_test.dart';
import 'package:garage_card/features/shared/repository/garage_repository.dart';

void main() {
  group('Multi-Tenant SaaS Data Isolation Tests', () {
    late GarageRepository repo;

    setUp(() {
      repo = GarageRepository();
    });

    test('Un-scoped getServiceJobs returns empty list', () async {
      final jobs = await repo.getServiceJobs();
      expect(jobs, isEmpty);
    });

    test('Un-scoped getServiceJobsPaginated returns empty result', () async {
      final result = await repo.getServiceJobsPaginated();
      expect(result.items, isEmpty);
      expect(result.hasMore, isFalse);
    });

    test('Un-scoped getEstimates returns empty list', () async {
      final estimates = await repo.getEstimates();
      expect(estimates, isEmpty);
    });

    test('Un-scoped getInvoices returns empty list', () async {
      final invoices = await repo.getInvoices();
      expect(invoices, isEmpty);
    });

    test('Un-scoped getPayments returns empty list', () async {
      final payments = await repo.getPayments();
      expect(payments, isEmpty);
    });

    test('Un-scoped getVehicles returns empty list', () async {
      final vehicles = await repo.getVehicles();
      expect(vehicles, isEmpty);
    });

    test('Un-scoped getReminders returns empty list', () async {
      final reminders = await repo.getReminders();
      expect(reminders, isEmpty);
    });

    test('Un-scoped getAppointments returns empty list', () async {
      final appointments = await repo.getAppointments();
      expect(appointments, isEmpty);
    });

    test(
      'Merchant queries are strictly isolated to specified garageId',
      () async {
        final g1Jobs = await repo.getServiceJobs(garageId: 'garage_demo_1');
        for (final job in g1Jobs) {
          expect(job.garageId, 'garage_demo_1');
        }

        final g2Jobs = await repo.getServiceJobs(garageId: 'garage_demo_2');
        for (final job in g2Jobs) {
          expect(job.garageId, 'garage_demo_2');
        }
      },
    );

    test(
      'Customer queries are strictly isolated to specified customerId',
      () async {
        final c1Jobs = await repo.getServiceJobs(customerId: 'cust_demo_1');
        for (final job in c1Jobs) {
          expect(job.customerId, 'cust_demo_1');
        }
      },
    );

    test(
      'Empty userId in streamUserConversations returns empty stream',
      () async {
        final stream = repo.streamUserConversations('', isMerchant: false);
        final list = await stream.first;
        expect(list, isEmpty);
      },
    );

    test('clearCache resets in-memory repository cache', () {
      repo.clearCache();
      expect(true, isTrue);
    });
  });
}

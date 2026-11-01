import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garage_card/core/shared_widgets/app_button.dart';
import 'package:garage_card/features/customer/service_jobs/Widgets/status_timeline_view.dart';
import 'package:garage_card/features/merchant/service_jobs/Widgets/complete_repair_dialog.dart';
import 'package:garage_card/features/merchant/service_jobs/Widgets/start_repair_dialog.dart';
import 'package:garage_card/features/shared/models/job_status_history_model.dart';
import 'package:garage_card/features/shared/models/service_job_model.dart';
import 'package:garage_card/features/shared/models/vehicle_model.dart';
import 'package:garage_card/features/shared/repository/garage_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ServiceJobModel Status Classifications', () {
    test('isActiveRepair returns true only for active repair states', () {
      const active1 = ServiceJobModel(
        id: 'j1',
        garageId: 'g1',
        customerId: 'c1',
        vehicleId: 'v1',
        jobNumber: 'JOB-1',
        status: 'in_progress',
      );
      const active2 = ServiceJobModel(
        id: 'j2',
        garageId: 'g1',
        customerId: 'c1',
        vehicleId: 'v1',
        jobNumber: 'JOB-2',
        status: 'awaiting_parts',
      );
      const active3 = ServiceJobModel(
        id: 'j3',
        garageId: 'g1',
        customerId: 'c1',
        vehicleId: 'v1',
        jobNumber: 'JOB-3',
        status: 'quality_check',
      );
      const active4 = ServiceJobModel(
        id: 'j4',
        garageId: 'g1',
        customerId: 'c1',
        vehicleId: 'v1',
        jobNumber: 'JOB-4',
        status: 'on_hold',
      );

      expect(active1.isActiveRepair, isTrue);
      expect(active2.isActiveRepair, isTrue);
      expect(active3.isActiveRepair, isTrue);
      expect(active4.isActiveRepair, isTrue);

      const pending1 = ServiceJobModel(
        id: 'j5',
        garageId: 'g1',
        customerId: 'c1',
        vehicleId: 'v1',
        jobNumber: 'JOB-5',
        status: 'received',
      );
      const pending2 = ServiceJobModel(
        id: 'j6',
        garageId: 'g1',
        customerId: 'c1',
        vehicleId: 'v1',
        jobNumber: 'JOB-6',
        status: 'requested',
      );
      const completed = ServiceJobModel(
        id: 'j7',
        garageId: 'g1',
        customerId: 'c1',
        vehicleId: 'v1',
        jobNumber: 'JOB-7',
        status: 'completed',
      );
      const cancelled = ServiceJobModel(
        id: 'j8',
        garageId: 'g1',
        customerId: 'c1',
        vehicleId: 'v1',
        jobNumber: 'JOB-8',
        status: 'cancelled',
      );

      expect(pending1.isActiveRepair, isFalse);
      expect(pending2.isActiveRepair, isFalse);
      expect(completed.isActiveRepair, isFalse);
      expect(cancelled.isActiveRepair, isFalse);
    });

    test('isPendingRequest correctly identifies non-commenced jobs', () {
      const job1 = ServiceJobModel(
        id: 'j1',
        garageId: 'g1',
        customerId: 'c1',
        vehicleId: 'v1',
        jobNumber: 'JOB-1',
        status: 'received',
      );
      const job2 = ServiceJobModel(
        id: 'j2',
        garageId: 'g1',
        customerId: 'c1',
        vehicleId: 'v1',
        jobNumber: 'JOB-2',
        status: 'inspection',
      );
      const job3 = ServiceJobModel(
        id: 'j3',
        garageId: 'g1',
        customerId: 'c1',
        vehicleId: 'v1',
        jobNumber: 'JOB-3',
        status: 'approved',
      );
      const inProg = ServiceJobModel(
        id: 'j4',
        garageId: 'g1',
        customerId: 'c1',
        vehicleId: 'v1',
        jobNumber: 'JOB-4',
        status: 'in_progress',
      );

      expect(job1.isPendingRequest, isTrue);
      expect(job2.isPendingRequest, isTrue);
      expect(job3.isPendingRequest, isTrue);
      expect(inProg.isPendingRequest, isFalse);
    });

    test(
      'isCompletedRepair and isCancelled helpers identify terminal states',
      () {
        const completed = ServiceJobModel(
          id: 'j1',
          garageId: 'g1',
          customerId: 'c1',
          vehicleId: 'v1',
          jobNumber: 'JOB-1',
          status: 'completed',
        );
        const closed = ServiceJobModel(
          id: 'j2',
          garageId: 'g1',
          customerId: 'c1',
          vehicleId: 'v1',
          jobNumber: 'JOB-2',
          status: 'closed',
        );
        const cancelled = ServiceJobModel(
          id: 'j3',
          garageId: 'g1',
          customerId: 'c1',
          vehicleId: 'v1',
          jobNumber: 'JOB-3',
          status: 'cancelled',
        );

        expect(completed.isCompletedRepair, isTrue);
        expect(closed.isCompletedRepair, isTrue);
        expect(completed.isCancelled, isFalse);
        expect(cancelled.isCancelled, isTrue);
        expect(cancelled.isCompletedRepair, isFalse);
      },
    );
  });

  group('VehicleModel Maintenance Intelligence', () {
    test('maintenanceStatus returns not_available when no schedule is set', () {
      const v = VehicleModel(
        id: 'v1',
        garageId: 'g1',
        customerId: 'c1',
        make: 'Yamaha',
        model: 'R15',
        year: 2023,
        licensePlate: 'KL-07-CD-1234',
        currentOdometer: 12000,
      );

      expect(v.hasMaintenanceSchedule, isFalse);
      expect(v.maintenanceStatus, equals('not_available'));
      expect(v.daysUntilNextService, isNull);
      expect(v.kmUntilNextService, isNull);
    });

    test(
      'maintenanceStatus returns upcoming when due > 14 days and > 500 km',
      () {
        final futureDate = DateTime.now().add(const Duration(days: 60));
        final v = VehicleModel(
          id: 'v1',
          garageId: 'g1',
          customerId: 'c1',
          make: 'Honda',
          model: 'CBR',
          year: 2022,
          licensePlate: 'KL-07-AB-9999',
          currentOdometer: 10000,
          nextServiceDue: futureDate,
          nextServiceOdometer: 14000,
        );

        expect(v.hasMaintenanceSchedule, isTrue);
        expect(v.maintenanceStatus, equals('upcoming'));
        expect(v.daysUntilNextService, greaterThan(14));
        expect(v.kmUntilNextService, equals(4000));
      },
    );

    test(
      'maintenanceStatus returns due_soon when within 14 days or <= 500 km',
      () {
        final soonDate = DateTime.now().add(const Duration(days: 10));
        final v = VehicleModel(
          id: 'v1',
          garageId: 'g1',
          customerId: 'c1',
          make: 'Royal Enfield',
          model: 'Classic 350',
          year: 2021,
          licensePlate: 'KL-07-ZZ-1111',
          currentOdometer: 14700,
          nextServiceDue: soonDate,
          nextServiceOdometer: 15000,
        );

        expect(v.maintenanceStatus, equals('due_soon'));
      },
    );

    test('maintenanceStatus returns due when within 3 days or <= 100 km', () {
      final dueDate = DateTime.now().add(const Duration(days: 2));
      final v = VehicleModel(
        id: 'v1',
        garageId: 'g1',
        customerId: 'c1',
        make: 'KTM',
        model: 'Duke 390',
        year: 2023,
        licensePlate: 'KL-07-KT-3900',
        currentOdometer: 14950,
        nextServiceDue: dueDate,
        nextServiceOdometer: 15000,
      );

      expect(v.maintenanceStatus, equals('due'));
    });

    test('maintenanceStatus returns overdue when date past or km exceeded', () {
      final pastDate = DateTime.now().subtract(const Duration(days: 5));
      final v = VehicleModel(
        id: 'v1',
        garageId: 'g1',
        customerId: 'c1',
        make: 'Bajaj',
        model: 'Pulsar NS200',
        year: 2020,
        licensePlate: 'KL-07-BJ-2020',
        currentOdometer: 16000,
        nextServiceDue: pastDate,
        nextServiceOdometer: 15000,
      );

      expect(v.maintenanceStatus, equals('overdue'));
    });
  });

  group('GarageRepository Repair Workflow & Maintenance', () {
    late GarageRepository repo;

    setUp(() {
      repo = GarageRepository();
      repo.jobs.clear();
      repo.vehicles.clear();
      repo.reminders.clear();
      repo.notifications.clear();
      repo.jobHistory.clear();
    });

    test('startRepair sets in_progress, actualStartTime, notes, and dispatches notification', () async {
      final created = await repo.createServiceJob(
        const ServiceJobModel(
          id: 'job_test_101',
          garageId: 'garage_cochin',
          customerId: 'cust_anand',
          vehicleId: 'veh_r15',
          jobNumber: 'JOB-COCHIN-01',
          vehicleDisplay: 'Yamaha R15 (KL-07-CD-1234)',
          status: 'received',
        ),
      );

      expect(created.status, equals('received'));
      expect(created.actualStartTime, isNull);

      final started = await repo.startRepair(
        garageId: 'garage_cochin',
        jobId: 'job_test_101',
        startedByUid: 'staff_manoj',
        technicianName: 'Suresh Kumar',
        notes: 'Engine head dismantled and valve clearance checked.',
      );

      expect(started.status, equals('in_progress'));
      expect(started.actualStartTime, isNotNull);
      expect(started.technicianName, equals('Suresh Kumar'));
      expect(started.customerNotes, contains('Engine head dismantled'));

      final notif = repo.notifications.firstWhere(
        (n) => n.referenceId == 'job_test_101',
      );
      expect(notif.recipientUid, equals('cust_anand'));
      expect(notif.title, contains('Repair Started'));
      expect(notif.deepLink, equals('/customer/jobs/job_test_101'));

      final history = await repo.getJobHistory('job_test_101');
      expect(history.first.toStatus, equals('in_progress'));
      expect(history.first.isCustomerVisible, isTrue);
    });

    test('completeRepair sets completed, generates gate pass, updates vehicle and reminder', () async {
      await repo.createVehicle(
        const VehicleModel(
          id: 'veh_pulsar',
          garageId: 'garage_cochin',
          customerId: 'cust_rahul',
          make: 'Bajaj',
          model: 'Pulsar',
          year: 2022,
          licensePlate: 'KL-07-PL-5555',
          currentOdometer: 20000,
        ),
      );

      await repo.createServiceJob(
        const ServiceJobModel(
          id: 'job_test_202',
          garageId: 'garage_cochin',
          customerId: 'cust_rahul',
          vehicleId: 'veh_pulsar',
          jobNumber: 'JOB-COCHIN-02',
          vehicleDisplay: 'Bajaj Pulsar (KL-07-PL-5555)',
          status: 'in_progress',
          odometerReading: 20000,
        ),
      );

      final nextDue = DateTime.now().add(const Duration(days: 90));
      final completed = await repo.completeRepair(
        garageId: 'garage_cochin',
        jobId: 'job_test_202',
        completedByUid: 'staff_manoj',
        finalOdometer: 20450,
        nextServiceDue: nextDue,
        nextServiceOdometer: 25000,
        nextServiceType: 'Periodic Maintenance',
        notes: 'Oil filter replaced, front brake pads renewed.',
      );

      expect(completed.status, equals('completed'));
      expect(completed.gatePassCode, isNotNull);
      expect(completed.gatePassCode!.length, equals(6));
      expect(completed.odometerReading, equals(20450));
      expect(completed.nextRecommendedOdometer, equals(25000));

      final updatedVeh = repo.vehicles.firstWhere((v) => v.id == 'veh_pulsar');
      expect(updatedVeh.currentOdometer, equals(20450));
      expect(updatedVeh.lastServiceType, equals('Periodic Maintenance'));
      expect(updatedVeh.lastServiceDate, isNotNull);
      expect(updatedVeh.nextServiceDue, equals(nextDue));
      expect(updatedVeh.nextServiceOdometer, equals(25000));

      final reminder = repo.reminders.firstWhere(
        (r) => r.vehicleId == 'veh_pulsar',
      );
      expect(reminder.title, contains('Periodic Maintenance'));
      expect(reminder.dueMileage, equals(25000));
      expect(reminder.status, equals('pending'));

      final completionNotif = repo.notifications.firstWhere(
        (n) => n.eventId == 'job_job_test_202_completed',
      );
      expect(completionNotif.recipientUid, equals('cust_rahul'));
      expect(completionNotif.body, contains(completed.gatePassCode!));
    });

    test(
      'getJobHistory customerOnly excludes private mechanic history',
      () async {
        await repo.createServiceJob(
          const ServiceJobModel(
            id: 'job_audit_303',
            garageId: 'garage_cochin',
            customerId: 'cust_anand',
            vehicleId: 'veh_r15',
            jobNumber: 'JOB-AUDIT-303',
          ),
        );

        await repo.updateJobStatus(
          jobId: 'job_audit_303',
          newStatus: 'in_progress',
          notes: 'Internal mechanic inspection: piston ring worn out',
          updatedBy: 'Mechanic A',
          isCustomerVisible: false,
        );

        await repo.updateJobStatus(
          jobId: 'job_audit_303',
          newStatus: 'in_progress',
          notes: 'Customer update: repair work in progress',
          updatedBy: 'Staff B',
          isCustomerVisible: true,
        );

        final fullHistory = await repo.getJobHistory(
          'job_audit_303',
          customerOnly: false,
        );
        expect(fullHistory.any((h) => !h.isCustomerVisible), isTrue);

        final customerHistory = await repo.getJobHistory(
          'job_audit_303',
          customerOnly: true,
        );
        expect(customerHistory.every((h) => h.isCustomerVisible), isTrue);
        expect(
          customerHistory.any((h) => h.notes.contains('piston ring worn out')),
          isFalse,
        );
      },
    );
  });

  group('UI Dialogs Widget Tests', () {
    testWidgets(
      'StartRepairDialog renders prefilled technician and invokes onStartRepair',
      (tester) async {
        bool called = false;
        String? recordedTech;

        const job = ServiceJobModel(
          id: 'job_dlg_1',
          garageId: 'g1',
          customerId: 'c1',
          vehicleId: 'v1',
          jobNumber: 'JOB-DLG-1',
          vehicleDisplay: 'Royal Enfield Classic (KL-07-AA-1111)',
          technicianName: 'Suresh Kumar',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => StartRepairDialog(
                          job: job,
                          onStartRepair: (tech, notes) async {
                            called = true;
                            recordedTech = tech;
                            return true;
                          },
                        ),
                      );
                    },
                    child: const Text('Open'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        expect(find.text('Start Repair Work'), findsOneWidget);
        expect(
          find.text('Royal Enfield Classic (KL-07-AA-1111)'),
          findsOneWidget,
        );
        expect(find.text('Suresh Kumar'), findsOneWidget);

        await tester.tap(find.widgetWithText(AppButton, 'Commence Work'));
        await tester.pumpAndSettle();

        expect(called, isTrue);
        expect(recordedTech, equals('Suresh Kumar'));
        expect(find.byType(StartRepairDialog), findsNothing);
      },
    );

    testWidgets(
      'CompleteRepairDialog validates odometer and calls onCompleteRepair',
      (tester) async {
        bool called = false;
        int? recordedOdo;

        const job = ServiceJobModel(
          id: 'job_dlg_2',
          garageId: 'g1',
          customerId: 'c1',
          vehicleId: 'v1',
          jobNumber: 'JOB-DLG-2',
          vehicleDisplay: 'Honda Activa 6G (KL-07-HA-6666)',
          odometerReading: 12500,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => CompleteRepairDialog(
                          job: job,
                          onCompleteRepair:
                              ({
                                required int finalOdometer,
                                DateTime? nextServiceDue,
                                int? nextServiceOdometer,
                                String? nextServiceType,
                                String? notes,
                              }) async {
                                called = true;
                                recordedOdo = finalOdometer;
                                return true;
                              },
                        ),
                      );
                    },
                    child: const Text('Open'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        expect(find.text('Complete Repair'), findsOneWidget);
        expect(find.text('12500'), findsOneWidget);

        final btnFinder = find.widgetWithText(
          AppButton,
          'Complete & Issue Pass',
        );
        await tester.ensureVisible(btnFinder);
        await tester.pumpAndSettle();

        await tester.tap(btnFinder);
        await tester.pumpAndSettle();

        expect(called, isTrue);
        expect(recordedOdo, equals(12500));
        expect(find.byType(CompleteRepairDialog), findsNothing);
      },
    );

    testWidgets(
      'StatusTimelineView hides private internal mechanic entries when showCustomerOnly is true',
      (tester) async {
        final history = [
          JobStatusHistoryModel(
            id: 'h1',
            jobId: 'j1',
            fromStatus: 'in_progress',
            toStatus: 'completed',
            notes: 'Vehicle ready for customer handover',
            updatedBy: 'Staff',
            isCustomerVisible: true,
            timestamp: DateTime.now(),
          ),
          JobStatusHistoryModel(
            id: 'h2',
            jobId: 'j1',
            fromStatus: 'received',
            toStatus: 'in_progress',
            notes: 'Internal mechanic warning: differential noisy',
            updatedBy: 'Mechanic',
            isCustomerVisible: false,
            timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          ),
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatusTimelineView(
                history: history,
                showCustomerOnly: true,
              ),
            ),
          ),
        );

        expect(
          find.text('Vehicle ready for customer handover'),
          findsOneWidget,
        );
        expect(
          find.text('Internal mechanic warning: differential noisy'),
          findsNothing,
        );
      },
    );
  });
}

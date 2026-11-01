import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garage_card/features/customer/service_jobs/Widgets/digital_gate_pass_dialog.dart';
import 'package:garage_card/features/merchant/analytics/Services/tax_export_service.dart';
import 'package:garage_card/features/merchant/inventory/View/merchant_inventory_screen.dart';
import 'package:garage_card/features/merchant/inventory/Widgets/inventory_item_dialog.dart';
import 'package:garage_card/features/merchant/service_jobs/Widgets/add_supplemental_work_dialog.dart';
import 'package:garage_card/features/merchant/service_jobs/Widgets/gate_pass_verification_dialog.dart';
import 'package:garage_card/features/merchant/service_jobs/Widgets/qc_checklist_dialog.dart';
import 'package:garage_card/features/shared/models/inventory_item_model.dart';
import 'package:garage_card/features/shared/models/invoice_model.dart';
import 'package:garage_card/features/shared/models/line_item_model.dart';
import 'package:garage_card/features/shared/models/payment_record_model.dart';
import 'package:garage_card/features/shared/models/qc_checklist_model.dart';
import 'package:garage_card/features/shared/models/service_job_model.dart';
import 'package:garage_card/features/shared/models/supplemental_work_model.dart';
import 'package:garage_card/features/shared/models/warranty_item_model.dart';
import 'package:garage_card/features/shared/repository/garage_repository.dart';

void main() {
  group('TaxExportService Unit Tests', () {
    test('generateTaxCsv formats CSV header and data rows properly', () {
      final now = DateTime(2026, 3, 15, 10, 30);
      final invoice = InvoiceModel(
        id: 'inv_tax_1',
        garageId: 'garage_demo_1',
        jobId: 'job_1',
        customerId: 'cust_1',
        invoiceNumber: 'INV-2026-999',
        items: const [
          LineItemModel(
            id: 'li_1',
            description: 'Synthetic Oil Change',
            type: 'part',
            quantity: 1,
            unitPrice: 2000.0,
          ),
        ],
        subtotal: 2000.0,
        taxRate: 18.0,
        taxAmount: 360.0,
        discountAmount: 100.0,
        totalAmount: 2260.0,
        paidAmount: 2260.0,
        balanceDue: 0.0,
        status: 'paid',
        issuedAt: now,
        createdAt: now,
        paymentRecords: [
          PaymentRecordModel(
            id: 'pr_1',
            invoiceId: 'inv_tax_1',
            amount: 2260.0,
            method: 'upi',
            reference: 'UPI12345',
            recordedAt: now,
          ),
        ],
      );

      final csv = TaxExportService.generateTaxCsv([
        invoice,
      ], taxNumber: '32AAACH7890Q1ZS');

      expect(csv, contains('Invoice Number,Invoice Date,Customer ID'));
      expect(csv, contains('INV-2026-999'));
      expect(csv, contains('32AAACH7890Q1ZS'));
      expect(csv, contains('2000.00'));
      expect(csv, contains('9.0,180.00,9.0,180.00'));
      expect(csv, contains('2260.00'));
      expect(csv, contains('PAID'));
    });
  });

  group('GarageRepository Inventory & Workflow Tests', () {
    late GarageRepository repo;

    setUp(() async {
      repo = GarageRepository();

      final initialItem = InventoryItemModel(
        id: 'initial_part_1',
        garageId: 'garage_test_1',
        sku: 'PART-001',
        name: 'Brake Pad Set',
        category: 'Brakes & Suspension',
        unitCost: 800.0,
        sellingPrice: 1200.0,
        currentStock: 2,
        minStockAlert: 5,
        unit: 'Sets',
      );
      await repo.saveInventoryItem('garage_test_1', initialItem);

      await repo.createServiceJob(
        ServiceJobModel(
          id: 'job_test_1',
          jobNumber: 'JOB-2026-001',
          garageId: 'garage_test_1',
          customerId: 'cust_test_1',
          vehicleId: 'veh_test_1',
          vehicleDisplay: 'Hyundai i20',
          status: 'inProgress',
        ),
      );

      await repo.createServiceJob(
        ServiceJobModel(
          id: 'job_test_5',
          jobNumber: 'JOB-2026-005',
          garageId: 'garage_test_1',
          customerId: 'cust_test_1',
          vehicleId: 'veh_test_1',
          vehicleDisplay: 'Honda City',
          status: 'qcInProgress',
        ),
      );
    });

    test('Inventory CRUD and stock adjustments work as expected', () async {
      final initial = await repo.getInventory('garage_test_1');
      expect(initial.isNotEmpty, isTrue);

      final lowStock = await repo.getLowStockItems('garage_test_1');
      expect(lowStock.any((i) => i.isLowStock), isTrue);

      final newItem = InventoryItemModel(
        id: 'test_item_1',
        garageId: 'garage_test_1',
        sku: 'TEST-SKU-99',
        name: 'Test Synthetic Fluid',
        category: 'Fluids & Lubricants',
        unitCost: 200.0,
        sellingPrice: 350.0,
        currentStock: 10,
        minStockAlert: 4,
        unit: 'Bottles',
      );

      final saved = await repo.saveInventoryItem('garage_test_1', newItem);
      expect(saved.sku, equals('TEST-SKU-99'));

      await repo.adjustInventoryStock('garage_test_1', 'test_item_1', 5);
      var updatedList = await repo.getInventory(
        'garage_test_1',
        query: 'TEST-SKU-99',
      );
      expect(updatedList.first.currentStock, equals(15));

      await repo.deleteInventoryItem('garage_test_1', 'test_item_1');
      updatedList = await repo.getInventory(
        'garage_test_1',
        query: 'TEST-SKU-99',
      );
      expect(updatedList.isEmpty, isTrue);
    });

    test('Supplemental work request and decision lifecycle', () async {
      const jobId = 'job_test_1';
      final item = SupplementalWorkItem(
        id: 'supp_test_1',
        jobId: jobId,
        title: 'Front Strut Mount Replacement',
        reason: 'Cracked rubber bushing found during inspection',
        partsCost: 1500.0,
        laborCost: 500.0,
        status: 'pending',
      );

      await repo.addSupplementalWork('garage_test_1', jobId, item);
      var jobs = await repo.getServiceJobs(garageId: 'garage_test_1');
      var job = jobs.firstWhere((j) => j.id == jobId);
      expect(job.supplementalItems.any((s) => s.id == 'supp_test_1'), isTrue);

      await repo.decideSupplementalWork(
        'garage_test_1',
        jobId,
        'supp_test_1',
        true,
      );
      jobs = await repo.getServiceJobs(garageId: 'garage_test_1');
      job = jobs.firstWhere((j) => j.id == jobId);
      final approvedItem = job.supplementalItems.firstWhere(
        (s) => s.id == 'supp_test_1',
      );
      expect(approvedItem.isApproved, isTrue);
      expect(approvedItem.totalAmount, equals(2000.0));
    });

    test(
      'QC Checklist sign-off validation and Gate Pass OTP lifecycle',
      () async {
        const jobId = 'job_test_5';
        final fullChecklist = {
          for (final k in QCChecklistModel.standardChecklistItems) k: true,
        };

        await repo.updateQcChecklist(
          'garage_test_1',
          jobId,
          fullChecklist,
          inspectorName: 'Suresh Kumar',
        );

        var jobs = await repo.getServiceJobs(garageId: 'garage_test_1');
        var job = jobs.firstWhere((j) => j.id == jobId);
        expect(job.isQcPassed, isTrue);
        expect(job.qcInspectorName, equals('Suresh Kumar'));

        final otp = await repo.generateGatePass('garage_test_1', jobId);
        expect(otp.length, equals(6));

        final wrongOtpResult = await repo.verifyGatePass(
          'garage_test_1',
          jobId,
          '000000',
        );
        expect(wrongOtpResult, isFalse);

        final correctOtpResult = await repo.verifyGatePass(
          'garage_test_1',
          jobId,
          otp,
        );
        expect(correctOtpResult, isTrue);

        jobs = await repo.getServiceJobs(garageId: 'garage_test_1');
        job = jobs.firstWhere((j) => j.id == jobId);
        expect(job.isGatePassVerified, isTrue);
        expect(job.status, equals('completed'));
      },
    );

    test(
      'Split payments update invoice records and customer warranties',
      () async {
        const invId = 'inv_test_3';
        final initialInv = InvoiceModel(
          id: invId,
          garageId: 'garage_test_1',
          jobId: 'job_test_1',
          customerId: 'cust_test_1',
          invoiceNumber: 'INV-1003',
          subtotal: 5000.0,
          totalAmount: 5000.0,
          balanceDue: 5000.0,
          currencyCode: 'INR',
          warrantyItems: [
            WarrantyItemModel(
              id: 'war_1',
              invoiceId: invId,
              partName: 'Front Strut',
              durationMonths: 12,
              startDate: DateTime.now(),
              expiryDate: DateTime.now().add(const Duration(days: 365)),
              status: 'active',
            ),
          ],
        );
        await repo.createInvoice(initialInv);

        await repo.recordPayment(
          invoiceId: invId,
          amount: 2500.0,
          paymentMethod: 'cash',
          referenceNumber: 'CASH1',
          notes: 'Advance deposit',
          recordedByUid: 'staff_1',
        );

        final payment = await repo.recordPayment(
          invoiceId: invId,
          amount: 2500.0,
          paymentMethod: 'upi',
          referenceNumber: 'UPI987654321',
          notes: 'Final settlement via UPI',
          recordedByUid: 'staff_1',
        );

        expect(payment.amount, equals(2500.0));
        final invoices = await repo.getInvoices(garageId: 'garage_test_1');
        final inv = invoices.firstWhere((i) => i.id == invId);
        expect(inv.balanceDue, equals(0.0));
        expect(inv.isPaid, isTrue);
        expect(inv.paymentRecords.length, greaterThanOrEqualTo(2));

        final warranties = await repo.getCustomerWarranties('cust_test_1');
        expect(warranties.isNotEmpty, isTrue);
        expect(warranties.any((w) => w.isActive), isTrue);
      },
    );
  });

  group('UI Dialogs Widget Tests', () {
    testWidgets('DigitalGatePassDialog displays OTP code and vehicle details', (
      tester,
    ) async {
      final job = ServiceJobModel(
        id: 'job_test_otp',
        garageId: 'garage_demo_1',
        customerId: 'cust_1',
        vehicleId: 'veh_1',
        jobNumber: 'JOB-2026-888',
        status: 'readyForCollection',
        vehicleDisplay: '2023 BMW 330i (KL 07 CZ 0007)',
        gatePassCode: '654321',
        isGatePassVerified: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DigitalGatePassDialog(job: job)),
        ),
      );

      expect(find.text('Digital Gate Pass'), findsOneWidget);
      expect(find.text('JOB-2026-888'), findsOneWidget);
      expect(find.text('654321'), findsOneWidget);
      expect(find.text('2023 BMW 330i (KL 07 CZ 0007)'), findsOneWidget);
      expect(find.text('DELIVERY RELEASE OTP'), findsOneWidget);
    });

    testWidgets(
      'GatePassVerificationDialog triggers verification upon entering OTP',
      (tester) async {
        String enteredCode = '';
        final job = ServiceJobModel(
          id: 'job_test_verify',
          garageId: 'garage_demo_1',
          customerId: 'cust_1',
          vehicleId: 'veh_1',
          jobNumber: 'JOB-2026-777',
          status: 'readyForCollection',
          vehicleDisplay: '2022 Toyota Fortuner (KL 07 BY 4455)',
          gatePassCode: '123456',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GatePassVerificationDialog(
                job: job,
                onVerify: (otp) async {
                  enteredCode = otp;
                  return otp == '123456';
                },
              ),
            ),
          ),
        );

        expect(find.text('Gate Pass Verification'), findsOneWidget);
        expect(find.textContaining('JOB-2026-777'), findsOneWidget);

        await tester.enterText(find.byType(TextField), '123456');
        await tester.pump();

        expect(enteredCode, equals('123456'));
        expect(find.text('Delivery Authorized!'), findsOneWidget);
        await tester.pump(const Duration(milliseconds: 1300));
      },
    );

    testWidgets(
      'QCChecklistDialog renders all 9 inspection points and toggle',
      (tester) async {
        final job = ServiceJobModel(
          id: 'job_test_qc',
          garageId: 'garage_demo_1',
          customerId: 'cust_1',
          vehicleId: 'veh_1',
          jobNumber: 'JOB-2026-QC',
          status: 'inProgress',
          vehicleDisplay: '2023 Swift (KL 07 DD 1102)',
          qcChecklist: const {},
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: QCChecklistDialog(
                job: job,
                onSave: (checklist, inspector) async => true,
              ),
            ),
          ),
        );

        expect(find.text('9-Point QC Checklist'), findsOneWidget);
        expect(find.text('Mark All Passed'), findsOneWidget);
        expect(find.text('Engine Oil Level & Viscosity'), findsOneWidget);
        expect(find.text('Tire Pressure & Tread Depth'), findsOneWidget);

        await tester.tap(find.text('Mark All Passed'));
        await tester.pump();

        expect(find.text('Clear All'), findsOneWidget);
        expect(find.text('Sign-off QC'), findsOneWidget);
      },
    );

    testWidgets(
      'AddSupplementalWorkDialog validates required fields and total amount',
      (tester) async {
        SupplementalWorkItem? submitted;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AddSupplementalWorkDialog(
                jobId: 'job_test_supp',
                onAdd: (item) async {
                  submitted = item;
                  return true;
                },
              ),
            ),
          ),
        );

        expect(find.text('Supplemental Work Request'), findsOneWidget);

        final textFields = find.byType(TextField);
        await tester.enterText(textFields.at(0), 'Front Lower Arm Bushings');
        await tester.enterText(
          textFields.at(1),
          'Play detected during wheel check',
        );
        await tester.enterText(textFields.at(2), '850.00');
        await tester.enterText(textFields.at(3), '450.00');
        await tester.pump();

        await tester.tap(find.text('Send to Customer'));
        await tester.pump();

        expect(submitted, isNotNull);
        expect(submitted!.title, equals('Front Lower Arm Bushings'));
        expect(submitted!.totalAmount, equals(1300.0));
      },
    );

    testWidgets('InventoryItemDialog saves new part correctly', (tester) async {
      InventoryItemModel? savedItem;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InventoryItemDialog(
              onSave: (item) async {
                savedItem = item;
                return true;
              },
            ),
          ),
        ),
      );

      expect(find.text('New Spare Part / Consumable'), findsOneWidget);

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'OIL-001');
      await tester.enterText(fields.at(1), 'Synthetic Engine Oil 10W-40');
      await tester.enterText(fields.at(2), '350.00');
      await tester.enterText(fields.at(3), '550.00');
      await tester.enterText(fields.at(4), '20');
      await tester.pump();

      await tester.tap(find.text('Create Item'));
      await tester.pump();

      expect(savedItem, isNotNull);
      expect(savedItem!.sku, equals('OIL-001'));
      expect(savedItem!.name, equals('Synthetic Engine Oil 10W-40'));
      expect(savedItem!.unitCost, equals(350.0));
      expect(savedItem!.sellingPrice, equals(550.0));
      expect(savedItem!.currentStock, equals(20));
    });

    testWidgets(
      'MerchantInventoryScreen renders summary cards, categories, and parts',
      (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(home: MerchantInventoryScreen()),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.text('Parts & Inventory'), findsOneWidget);
        expect(find.text('Total SKUs'), findsOneWidget);
        expect(find.text('Valuation'), findsOneWidget);
        expect(find.text('Low Stock'), findsOneWidget);
        expect(find.text('Fluids & Lubricants'), findsWidgets);
        expect(find.text('Add Part'), findsOneWidget);
      },
    );
  });
}

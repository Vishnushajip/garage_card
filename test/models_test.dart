import 'package:flutter_test/flutter_test.dart';
import 'package:garage_card/features/shared/models/garage_service_model.dart';
import 'package:garage_card/features/shared/models/review_model.dart';
import 'package:garage_card/features/shared/pricing/smart_pricing_engine.dart';
import 'package:garage_card/features/shared/models/estimate_model.dart';
import 'package:garage_card/features/shared/models/garage_model.dart';
import 'package:garage_card/features/shared/models/invoice_model.dart';
import 'package:garage_card/features/shared/models/line_item_model.dart';
import 'package:garage_card/features/shared/models/service_job_model.dart';
import 'package:garage_card/features/shared/models/user_profile_model.dart';
import 'package:garage_card/features/shared/models/vehicle_model.dart';

void main() {
  group('Typed Models Serialization & Logic Tests', () {
    test('UserProfileModel serialization and role check', () {
      final user = UserProfileModel(
        uid: 'user_123',
        email: 'test@example.com',
        fullName: 'Test User',
        role: 'merchant',
        garageId: 'garage_1',
      );

      expect(user.isMerchant, isTrue);
      expect(user.isCustomer, isFalse);

      final firestoreMap = user.toFirestore();
      expect(firestoreMap['uid'], 'user_123');
      expect(firestoreMap['role'], 'merchant');

      final reconstructed = UserProfileModel.fromFirestore(
        firestoreMap,
        'user_123',
      );
      expect(reconstructed.email, 'test@example.com');
      expect(reconstructed.garageId, 'garage_1');
    });

    test('VehicleModel display name and serialization', () {
      final vehicle = VehicleModel(
        id: 'veh_1',
        garageId: 'g_1',
        customerId: 'c_1',
        make: 'Hyundai',
        model: 'Creta',
        year: 2022,
        licensePlate: 'KL 07 CD 4488',
      );

      expect(vehicle.displayName, '2022 Hyundai Creta (KL 07 CD 4488)');

      final map = vehicle.toFirestore();
      final fromMap = VehicleModel.fromFirestore(map, 'veh_1');
      expect(fromMap.make, 'Hyundai');
      expect(fromMap.licensePlate, 'KL 07 CD 4488');
    });

    test('EstimateModel and LineItemModel calculations', () {
      const item1 = LineItemModel(
        id: '1',
        description: 'Engine Oil',
        quantity: 2,
        unitPrice: 1500.0,
      );
      expect(item1.totalPrice, 3000.0);

      const item2 = LineItemModel(
        id: '2',
        description: 'Oil Filter',
        quantity: 1,
        unitPrice: 500.0,
      );

      final items = [item1, item2];
      final subtotal = items.fold<double>(0.0, (sum, i) => sum + i.totalPrice);
      expect(subtotal, 3500.0);

      final estimate = EstimateModel(
        id: 'est_1',
        garageId: 'g_1',
        jobId: 'j_1',
        customerId: 'c_1',
        estimateNumber: 'EST-001',
        items: items,
        subtotal: subtotal,
        taxRate: 18.0,
        taxAmount: 630.0,
        discountAmount: 130.0,
        totalAmount: 4000.0,
        status: 'approved',
      );

      expect(estimate.isApproved, isTrue);
      expect(estimate.totalAmount, 4000.0);

      final map = estimate.toFirestore();
      final fromMap = EstimateModel.fromFirestore(map, 'est_1');
      expect(fromMap.items.length, 2);
      expect(fromMap.totalAmount, 4000.0);
    });

    test('InvoiceModel balance and paid status', () {
      final invoice = InvoiceModel(
        id: 'inv_1',
        garageId: 'g_1',
        jobId: 'j_1',
        customerId: 'c_1',
        invoiceNumber: 'INV-100',
        totalAmount: 5000.0,
        paidAmount: 5000.0,
        balanceDue: 0.0,
        status: 'paid',
      );

      expect(invoice.isPaid, isTrue);
      expect(invoice.balanceDue, 0.0);
    });

    test('GarageModel serialization and services list', () {
      final garage = GarageModel(
        id: 'g_1',
        name: 'Apex Garage',
        address: 'MG Road',
        phone: '+91 98765 00000',
        email: 'apex@example.com',
        ownerUid: 'owner_1',
        servicesOffered: const ['Tuning', 'AC Service'],
      );

      expect(garage.servicesOffered.length, 2);
      final map = garage.toFirestore();
      final fromMap = GarageModel.fromFirestore(map, 'g_1');
      expect(fromMap.name, 'Apex Garage');
      expect(fromMap.servicesOffered.first, 'Tuning');
    });

    test('ServiceJobModel copyWith and serialization', () {
      final job = ServiceJobModel(
        id: 'j_1',
        garageId: 'g_1',
        customerId: 'c_1',
        vehicleId: 'v_1',
        jobNumber: 'JOB-001',
        status: 'received',
      );

      final updated = job.copyWith(status: 'inProgress');
      expect(updated.status, 'inProgress');
      final map = updated.toFirestore();
      final fromMap = ServiceJobModel.fromFirestore(map, 'j_1');
      expect(fromMap.status, 'inProgress');
    });

    test(
      'SmartPricingEngine resolves attribute-based pricing with exact cc match',
      () {
        const service = GarageServiceModel(
          id: 'srv_test',
          garageId: 'g_1',
          name: 'Oil Change',
          pricingMethod: 'attribute',
          attributeRules: [
            PricingAttributeRule(
              label: 'Up to 150cc',
              vehicleType: 'motorcycle',
              minCc: 0,
              maxCc: 150,
              price: 350.0,
            ),
            PricingAttributeRule(
              label: '151cc to 350cc',
              vehicleType: 'motorcycle',
              minCc: 151,
              maxCc: 350,
              price: 550.0,
            ),
            PricingAttributeRule(
              label: 'Above 350cc',
              vehicleType: 'motorcycle',
              minCc: 351,
              maxCc: 1200,
              price: 850.0,
            ),
          ],
        );

        final bike125 = VehicleModel(
          id: 'v1',
          garageId: 'g_1',
          customerId: 'c_1',
          make: 'Honda',
          model: 'Shine',
          year: 2022,
          licensePlate: 'KL 07 1234',
          vehicleType: 'motorcycle',
          engineCc: 125,
        );

        final bike350 = VehicleModel(
          id: 'v2',
          garageId: 'g_1',
          customerId: 'c_1',
          make: 'Royal Enfield',
          model: 'Classic 350',
          year: 2023,
          licensePlate: 'KL 07 5678',
          vehicleType: 'motorcycle',
          engineCc: 349,
        );

        final eval125 = SmartPricingEngine.evaluate(
          service: service,
          vehicle: bike125,
        );
        expect(eval125.type, EvaluatedPricingType.attribute);
        expect(eval125.price, 350.0);

        final eval350 = SmartPricingEngine.evaluate(
          service: service,
          vehicle: bike350,
        );
        expect(eval350.type, EvaluatedPricingType.attribute);
        expect(eval350.price, 550.0);

        final overrideEval = SmartPricingEngine.evaluate(
          service: service,
          vehicle: bike125,
          customOverridePrice: 299.0,
        );
        expect(overrideEval.type, EvaluatedPricingType.override);
        expect(overrideEval.price, 299.0);
      },
    );

    test('ReviewModel enforces customer photo and name display consent', () {
      final consentReview = ReviewModel(
        id: 'r_1',
        garageId: 'g_1',
        customerId: 'c_1',
        customerName: 'Rahul Menon',
        customerPhotoUrl: 'https://example.com/photo.jpg',
        rating: 5.0,
        reviewText: 'Great service!',
        consentShareName: true,
        consentSharePhoto: true,
      );

      expect(consentReview.displayCustomerName, 'Rahul Menon');
      expect(consentReview.publicPhotoUrl, 'https://example.com/photo.jpg');

      final privateReview = ReviewModel(
        id: 'r_2',
        garageId: 'g_1',
        customerId: 'c_2',
        customerName: 'Secret User',
        customerPhotoUrl: 'https://example.com/private.jpg',
        rating: 4.0,
        reviewText: 'Good work',
        consentShareName: false,
        consentSharePhoto: false,
      );

      expect(privateReview.displayCustomerName, 'Verified Customer');
      expect(privateReview.publicPhotoUrl, isNull);
    });
  });
}

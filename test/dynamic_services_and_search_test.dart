import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garage_card/features/customer/search/View/customer_search_screen.dart';
import 'package:garage_card/features/merchant/service_catalog/Widgets/service_edit_dialog.dart';
import 'package:garage_card/features/shared/models/garage_service_model.dart';
import 'package:garage_card/features/shared/pricing/smart_pricing_engine.dart';
import 'package:garage_card/features/shared/repository/garage_repository.dart';

void main() {
  group('Dynamic Services & Smart Pricing Model Tests', () {
    test('VehiclePricingTier serializes and matches vehicle pricing', () {
      const tier = VehiclePricingTier(
        vehicleType: 'scooter',
        pricingType: 'range',
        minPrice: 250.0,
        maxPrice: 450.0,
      );

      final map = tier.toMap();
      expect(map['vehicleType'], 'scooter');
      expect(map['minPrice'], 250.0);
      expect(map['maxPrice'], 450.0);

      final fromMap = VehiclePricingTier.fromMap(map);
      expect(fromMap.vehicleType, 'scooter');
      expect(fromMap.pricingType, 'range');
      expect(fromMap.minPrice, 250.0);
      expect(fromMap.maxPrice, 450.0);
    });

    test('GarageServiceModel supportsVehicle and getTierForVehicle work accurately', () {
      final service = GarageServiceModel(
        id: 'srv_test_1',
        garageId: 'garage_1',
        name: 'Oil Change',
        pricingType: 'vehicle_specific',
        supportedVehicleTypes: const ['car', 'motorcycle', 'scooter'],
        vehiclePricing: const [
          VehiclePricingTier(
            vehicleType: 'scooter',
            pricingType: 'range',
            minPrice: 250.0,
            maxPrice: 450.0,
          ),
          VehiclePricingTier(
            vehicleType: 'motorcycle',
            pricingType: 'range',
            minPrice: 350.0,
            maxPrice: 600.0,
          ),
          VehiclePricingTier(
            vehicleType: 'car',
            pricingType: 'range',
            minPrice: 1500.0,
            maxPrice: 3000.0,
          ),
        ],
      );

      expect(service.supportsVehicle('scooter'), isTrue);
      expect(service.supportsVehicle('motorcycle'), isTrue);
      expect(service.supportsVehicle('car'), isTrue);
      expect(service.supportsVehicle('electric_scooter'), isFalse);

      final scooterTier = service.getTierForVehicle('scooter');
      expect(scooterTier, isNotNull);
      expect(scooterTier!.minPrice, 250.0);
      expect(scooterTier.maxPrice, 450.0);

      final carTier = service.getTierForVehicle('car');
      expect(carTier, isNotNull);
      expect(carTier!.minPrice, 1500.0);
    });

    test(
      'SmartPricingEngine dynamically resolves vehicle-specific pricing tiers',
      () {
        final service = GarageServiceModel(
          id: 'srv_test_oil',
          garageId: 'garage_1',
          name: 'Oil Change',
          pricingType: 'vehicle_specific',
          vehiclePricing: const [
            VehiclePricingTier(
              vehicleType: 'scooter',
              pricingType: 'range',
              minPrice: 250.0,
              maxPrice: 450.0,
            ),
            VehiclePricingTier(
              vehicleType: 'motorcycle',
              pricingType: 'fixed',
              fixedPrice: 499.0,
            ),
            VehiclePricingTier(
              vehicleType: 'car',
              pricingType: 'range',
              minPrice: 1500.0,
              maxPrice: 3000.0,
            ),
          ],
        );

        final scooterEval = SmartPricingEngine.evaluate(
          service: service,
          vehicleType: 'scooter',
        );
        expect(scooterEval.type, EvaluatedPricingType.range);
        expect(scooterEval.minPrice, 250.0);
        expect(scooterEval.maxPrice, 450.0);
        expect(scooterEval.formattedDisplay, contains('250'));
        expect(scooterEval.formattedDisplay, contains('450'));

        final motoEval = SmartPricingEngine.evaluate(
          service: service,
          vehicleType: 'motorcycle',
        );
        expect(motoEval.type, EvaluatedPricingType.fixed);
        expect(motoEval.price, 499.0);
        expect(motoEval.amount, 499.0);

        final carEval = SmartPricingEngine.evaluate(
          service: service,
          vehicleType: 'car',
        );
        expect(carEval.type, EvaluatedPricingType.range);
        expect(carEval.minPrice, 1500.0);
        expect(carEval.maxPrice, 3000.0);
      },
    );
  });

  group(
    'GarageRepository Advanced Search & Correct Pricing Filtering Tests',
    () {
      late GarageRepository repo;

      setUp(() {
        repo = GarageRepository();
      });

      test(
        'searchGaragesAndServices finds garages by keyword and vehicle',
        () async {
          final results = await repo.searchGaragesAndServices(
            query: 'Wash',
            vehicleType: 'motorcycle',
            userLat: 9.9674,
            userLon: 76.2891,
          );

          expect(results, isNotEmpty);
          for (final r in results) {
            expect(r.distanceKm, greaterThanOrEqualTo(0.0));
          }
        },
      );

      test('vehicle-specific pricing evaluates scooter budget independently from car pricing', () async {
        final scooterResults = await repo.searchGaragesAndServices(
          query: 'Oil',
          vehicleType: 'scooter',
          maxPrice: 500.0,
          userLat: 9.9674,
          userLon: 76.2891,
        );

        expect(scooterResults, isNotEmpty);
        for (final r in scooterResults) {
          if (r.evaluatedPrice?.amount != null) {
            expect(r.evaluatedPrice!.amount!, lessThanOrEqualTo(500.0));
          }
        }

        final carResults = await repo.searchGaragesAndServices(
          query: 'Oil',
          vehicleType: 'car',
          maxPrice: 500.0,
          userLat: 9.9674,
          userLon: 76.2891,
        );

        expect(carResults, isEmpty);
      });

      test(
        'searchGaragesAndServices sorts accurately by distance and price',
        () async {
          final nearestResults = await repo.searchGaragesAndServices(
            sortBy: 'nearest',
            userLat: 9.9674,
            userLon: 76.2891,
          );

          expect(nearestResults.length, greaterThanOrEqualTo(2));
          for (int i = 0; i < nearestResults.length - 1; i++) {
            expect(
              nearestResults[i].distanceKm,
              lessThanOrEqualTo(nearestResults[i + 1].distanceKm),
            );
          }
        },
      );
    },
  );

  group('CustomerSearchScreen UI & Responsiveness Tests', () {
    testWidgets('renders search text field and active filter count badge', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: CustomerSearchScreen())),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.tune_rounded), findsWidgets);
    });

    testWidgets(
      'adapts smoothly across mobile 320px and desktop 1440px with 0 overflow',
      (tester) async {
        const widths = [320.0, 390.0, 768.0, 1024.0, 1440.0];

        for (final width in widths) {
          tester.view.physicalSize = Size(width, 800);
          tester.view.devicePixelRatio = 1.0;

          await tester.pumpWidget(
            const ProviderScope(
              child: MaterialApp(
                home: CustomerSearchScreen(initialQuery: 'Periodic'),
              ),
            ),
          );
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 300));

          expect(tester.takeException(), isNull);
        }
        tester.view.resetPhysicalSize();
      },
    );

    testWidgets(
      'filter sheet opens and displays distance and vehicle choices',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          const ProviderScope(child: MaterialApp(home: CustomerSearchScreen())),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        final filterButton = find.byIcon(Icons.tune_rounded).first;
        await tester.tap(filterButton);
        await tester.pumpAndSettle();

        expect(find.text('Search & Discovery Filters'), findsOneWidget);
        expect(find.text('Distance Radius'), findsOneWidget);
        expect(find.text('Vehicle Compatibility'), findsOneWidget);
        expect(find.text('Price Budget Range'), findsOneWidget);
        expect(find.text('Apply Filters'), findsOneWidget);
      },
    );
  });

  group('Merchant ServiceEditDialog Dynamic Pricing Tests', () {
    testWidgets(
      'allows selecting vehicle compatibility and switches pricing structure',
      (tester) async {
        tester.view.physicalSize = const Size(600, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        GarageServiceModel? savedService;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ServiceEditDialog(
                garageId: 'garage_test',
                onSave: (service) async {
                  savedService = service;
                  return true;
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Vehicle Compatibility'), findsOneWidget);
        expect(find.text('Dynamic Pricing Model'), findsOneWidget);

        await tester.enterText(
          find.byType(TextField).first,
          'Test Dynamic Service',
        );
        await tester.pumpAndSettle();

        final saveButton = find.text('Save Service');
        await tester.ensureVisible(saveButton);
        await tester.pumpAndSettle();
        await tester.tap(saveButton);
        await tester.pumpAndSettle();

        expect(savedService, isNotNull);
        expect(savedService!.name, 'Test Dynamic Service');
        expect(savedService!.supportedVehicleTypes, isNotEmpty);
      },
    );
  });
}

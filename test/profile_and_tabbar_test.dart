import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:garage_card/core/routing/route_paths.dart';
import 'package:garage_card/core/shared_widgets/account_switcher_list_view.dart';
import 'package:garage_card/core/shared_widgets/app_text_field.dart';
import 'package:garage_card/features/authentication/Model/auth_state.dart';
import 'package:garage_card/features/authentication/ViewModel/auth_view_model.dart';
import 'package:garage_card/features/customer/dashboard/View/customer_dashboard_screen.dart';
import 'package:garage_card/features/customer/invoices/View/customer_invoices_screen.dart';
import 'package:garage_card/features/customer/profile/Model/customer_profile_state.dart';
import 'package:garage_card/features/customer/profile/View/customer_profile_screen.dart';
import 'package:garage_card/features/customer/profile/ViewModel/customer_profile_view_model.dart';
import 'package:garage_card/features/customer/vehicles/View/customer_vehicles_screen.dart';
import 'package:garage_card/features/merchant/invoices/View/merchant_invoices_screen.dart';
import 'package:garage_card/features/shared/models/service_job_model.dart';
import 'package:garage_card/features/shared/models/user_profile_model.dart';
import 'package:garage_card/features/shared/models/vehicle_model.dart';
import 'package:garage_card/features/shared/repository/garage_repository.dart';
import 'package:go_router/go_router.dart';

void main() {
  setUp(() {
    HttpOverrides.global = _TestHttpOverrides();
    SharedPreferences.setMockInitialValues({});
  });

  group('Customer Profile Details State Tests', () {
    test('isEditingDetails default and toggle transitions', () {
      final container = ProviderContainer(
        overrides: [
          authViewModelProvider.overrideWith(() => _MockAuthViewModel()),
        ],
      );
      addTearDown(container.dispose);

      final vm = container.read(customerProfileViewModelProvider.notifier);
      expect(
        container.read(customerProfileViewModelProvider).isEditingDetails,
        false,
      );

      vm.startEditingDetails();
      expect(
        container.read(customerProfileViewModelProvider).isEditingDetails,
        true,
      );

      vm.cancelEditingDetails();
      expect(
        container.read(customerProfileViewModelProvider).isEditingDetails,
        false,
      );
    });

    test(
      'CustomerProfileState copyWith preserves or updates isEditingDetails',
      () {
        const state = CustomerProfileState();
        expect(state.isEditingDetails, false);

        final updated = state.copyWith(isEditingDetails: true);
        expect(updated.isEditingDetails, true);

        final reset = updated.copyWith(isEditingDetails: false);
        expect(reset.isEditingDetails, false);
      },
    );
  });

  group('AuthViewModel Experience Switching Tests', () {
    test('switchExperience transitions activeExperience between customer and merchant', () async {
      final container = ProviderContainer(
        overrides: [
          authViewModelProvider.overrideWith(() => _MockAuthViewModel()),
        ],
      );
      addTearDown(container.dispose);

      final authVm = container.read(authViewModelProvider.notifier);
      expect(
        container.read(authViewModelProvider).activeExperience,
        'customer',
      );

      await authVm.switchExperience('merchant');
      expect(
        container.read(authViewModelProvider).activeExperience,
        'merchant',
      );
      expect(
        container.read(authViewModelProvider).userProfile?.garageId,
        isNull,
      );

      await authVm.switchExperience('customer');
      expect(
        container.read(authViewModelProvider).activeExperience,
        'customer',
      );
    });
  });

  group('Invoice & Payments TabBar UI Widget Tests', () {
    testWidgets(
      'CustomerInvoicesScreen renders custom automotive TabBar with icons',
      (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(home: CustomerInvoicesScreen()),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Invoices & Payments'), findsOneWidget);
        expect(find.byType(TabBar), findsOneWidget);
        expect(find.text('Invoices'), findsOneWidget);
        expect(find.text('Payment History'), findsOneWidget);
        expect(find.byIcon(Icons.receipt_long_rounded), findsOneWidget);
        expect(find.byIcon(Icons.payments_outlined), findsOneWidget);
      },
    );

    testWidgets(
      'MerchantInvoicesScreen renders custom automotive TabBar with icons',
      (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(home: MerchantInvoicesScreen()),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Billing & Payments'), findsOneWidget);
        expect(find.byType(TabBar), findsOneWidget);
        expect(find.text('Invoices'), findsOneWidget);
        expect(find.text('Payment Transactions'), findsOneWidget);
        expect(find.byIcon(Icons.receipt_long_rounded), findsOneWidget);
        expect(find.byIcon(Icons.payments_outlined), findsOneWidget);
      },
    );
  });

  group('Customer Profile Details Entering Section Visibility Tests', () {
    testWidgets(
      'Shows Complete Profile Now button when incomplete and reveals form on tap',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        final mockProfile = UserProfileModel(
          uid: 'cust_incomplete',
          email: 'user@example.com',
          fullName: 'User',
          phoneNumber: '',
          whatsappNumber: '',
          role: 'customer',
          createdAt: DateTime.now(),
        );

        final router = GoRouter(
          initialLocation: RoutePaths.customerProfile,
          routes: [
            GoRoute(
              path: RoutePaths.customerProfile,
              builder: (context, state) => const CustomerProfileScreen(),
            ),
            GoRoute(
              path: RoutePaths.customer,
              builder: (context, state) =>
                  const Scaffold(body: Text('Customer Dashboard')),
            ),
            GoRoute(
              path: RoutePaths.merchant,
              builder: (context, state) =>
                  const Scaffold(body: Text('Merchant Dashboard')),
            ),
            GoRoute(
              path: RoutePaths.auth,
              builder: (context, state) => const Scaffold(body: Text('Auth')),
            ),
          ],
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authViewModelProvider.overrideWith(
                () => _MockAuthViewModel(initialProfile: mockProfile),
              ),
            ],
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Complete Profile Now'), findsOneWidget);
        expect(find.byType(AppTextField), findsNothing);

        await tester.tap(find.text('Complete Profile Now'));
        await tester.pumpAndSettle();

        expect(find.byType(AppTextField), findsNWidgets(3));
        expect(find.text('Save Profile Details'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);

        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        expect(find.text('Complete Profile Now'), findsOneWidget);
        expect(find.byType(AppTextField), findsNothing);
      },
    );

    testWidgets(
      'Shows Edit Profile Details button when complete and reveals form on tap',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        final completeProfile = UserProfileModel(
          uid: 'cust_complete',
          email: 'client@example.com',
          fullName: 'Rahul Sharma',
          phoneNumber: '+91 98460 11111',
          whatsappNumber: '+91 98460 11111',
          role: 'customer',
          createdAt: DateTime.now(),
        );

        final router = GoRouter(
          initialLocation: RoutePaths.customerProfile,
          routes: [
            GoRoute(
              path: RoutePaths.customerProfile,
              builder: (context, state) => const CustomerProfileScreen(),
            ),
          ],
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authViewModelProvider.overrideWith(
                () => _MockAuthViewModel(initialProfile: completeProfile),
              ),
            ],
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('100% Complete'), findsOneWidget);
        expect(find.text('Edit Profile Details'), findsOneWidget);
        expect(find.text('Rahul Sharma'), findsNWidgets(3));
        expect(find.byType(AppTextField), findsNothing);

        await tester.tap(find.text('Edit Profile Details'));
        await tester.pumpAndSettle();

        expect(find.byType(AppTextField), findsNWidgets(3));
        expect(find.text('Save Profile Details'), findsOneWidget);
      },
    );
  });

  group('Customer Dashboard Garages and Services Visibility Tests', () {
    testWidgets(
      'Landing page displays Garages, Repairs, Invoices, Support quick actions and workshop offers',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authViewModelProvider.overrideWith(() => _MockAuthViewModel()),
            ],
            child: MaterialApp(
              home: CustomerDashboardScreen(
                onNavigateToNearbyGarages: () {},
                onNavigateToInvoices: () {},
                onNavigateToReminders: () {},
                onNavigateToJobDetail: (_) {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Garages'), findsWidgets);
        expect(find.text('Repairs'), findsOneWidget);
        expect(find.text('Invoices'), findsOneWidget);
        expect(find.text('Support'), findsOneWidget);
        expect(find.text('Workshop Packages & Periodic Care'), findsOneWidget);
        expect(find.text('Estimates'), findsNothing);
      },
    );
  });

  group('Vishnu Shaji Account Vehicles Tests', () {
    test('GarageRepository returns created vehicles for customer', () async {
      final repo = GarageRepository();
      await repo.createVehicle(
        VehicleModel(
          id: 'veh_v1',
          customerId: 'vishnu_uid_123',
          garageId: 'garage_1',
          make: 'BMW',
          model: '3 Series 330i M Sport',
          year: 2023,
          licensePlate: 'KL 07 CZ 0007',
          fuelType: 'Petrol',
          color: 'Portimao Blue Metallic',
        ),
      );
      await repo.createVehicle(
        VehicleModel(
          id: 'veh_v2',
          customerId: 'vishnu_uid_123',
          garageId: 'garage_1',
          make: 'Toyota',
          model: 'Innova Crysta 2.4 ZX',
          year: 2022,
          licensePlate: 'KL 07 BY 4455',
          fuelType: 'Diesel',
          color: 'Attitude Black',
        ),
      );
      final vehicles = await repo.getVehicles(customerId: 'vishnu_uid_123');

      expect(vehicles.length, 2);
      final plates = vehicles.map((v) => v.licensePlate).toList();
      expect(plates, contains('KL 07 CZ 0007'));
      expect(plates, contains('KL 07 BY 4455'));

      final bmw = vehicles.firstWhere((v) => v.licensePlate == 'KL 07 CZ 0007');
      expect(bmw.make, 'BMW');
      expect(bmw.model, '3 Series 330i M Sport');
      expect(bmw.year, 2023);
      expect(bmw.fuelType, 'Petrol');
      expect(bmw.color, 'Portimao Blue Metallic');
    });

    testWidgets('CustomerVehiclesScreen displays vehicles for customer', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final repo = GarageRepository();
      await repo.createVehicle(
        VehicleModel(
          id: 'veh_v1',
          customerId: 'vishnu_uid_123',
          garageId: 'garage_1',
          make: 'BMW',
          model: '3 Series 330i M Sport',
          year: 2023,
          licensePlate: 'KL 07 CZ 0007',
          fuelType: 'Petrol',
          color: 'Portimao Blue Metallic',
        ),
      );

      final vishnuProfile = UserProfileModel(
        uid: 'vishnu_uid_123',
        email: 'vishnushaji431@gmail.com',
        fullName: 'Vishnu Shaji',
        phoneNumber: '+91 98460 77889',
        role: 'customer',
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            garageRepositoryProvider.overrideWithValue(repo),
            authViewModelProvider.overrideWith(
              () => _MockAuthViewModel(initialProfile: vishnuProfile),
            ),
          ],
          child: MaterialApp(
            home: CustomerVehiclesScreen(onSelectVehicle: (_) {}),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('My Vehicles'), findsOneWidget);
      expect(find.text('KL 07 CZ 0007'), findsOneWidget);
    });

    testWidgets(
      'CustomerDashboardScreen displays Vishnu active job and vehicles',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        final repo = GarageRepository();
        await repo.createServiceJob(
          ServiceJobModel(
            id: 'job_v1',
            jobNumber: 'JOB-2026-077',
            garageId: 'garage_1',
            customerId: 'vishnu_uid_123',
            vehicleId: 'veh_v1',
            vehicleDisplay: '2023 BMW 330i M Sport (KL 07 CZ 0007)',
            status: 'inProgress',
          ),
        );

        final vishnuProfile = UserProfileModel(
          uid: 'vishnu_uid_123',
          email: 'vishnushaji431@gmail.com',
          fullName: 'Vishnu Shaji',
          phoneNumber: '+91 98460 77889',
          role: 'customer',
          createdAt: DateTime.now(),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              garageRepositoryProvider.overrideWithValue(repo),
              authViewModelProvider.overrideWith(
                () => _MockAuthViewModel(initialProfile: vishnuProfile),
              ),
            ],
            child: MaterialApp(
              home: CustomerDashboardScreen(
                onNavigateToNearbyGarages: () {},
                onNavigateToInvoices: () {},
                onNavigateToReminders: () {},
                onNavigateToJobDetail: (_) {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('JOB-2026-077'), findsOneWidget);
        expect(
          find.text('2023 BMW 330i M Sport (KL 07 CZ 0007)'),
          findsOneWidget,
        );
      },
    );
  });

  group('Account Switcher ListView Tests', () {
    testWidgets(
      'AccountSwitcherListView renders accounts and triggers switch',
      (tester) async {
        String? switchedTarget;

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authViewModelProvider.overrideWith(() => _MockAuthViewModel()),
            ],
            child: MaterialApp(
              home: Scaffold(
                body: AccountSwitcherListView(
                  onSwitched: (target) {
                    switchedTarget = target;
                  },
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(ListView), findsOneWidget);
        expect(find.text('Test User'), findsOneWidget);
        expect(find.text('Merchant Workspace'), findsOneWidget);
        expect(find.text('Active'), findsOneWidget);
        expect(find.text('Switch'), findsOneWidget);

        await tester.tap(find.text('Switch'));
        await tester.pumpAndSettle();

        expect(find.text('Switch to Merchant Account?'), findsOneWidget);
        await tester.tap(find.text('Confirm Switch'));
        await tester.pumpAndSettle();

        expect(switchedTarget, 'merchant');
      },
    );

    testWidgets(
      'CustomerProfileScreen renders AccountSwitcherListView and displays both accounts',
      (tester) async {
        final router = GoRouter(
          initialLocation: RoutePaths.customerProfile,
          routes: [
            GoRoute(
              path: RoutePaths.customerProfile,
              builder: (context, state) => const CustomerProfileScreen(),
            ),
            GoRoute(
              path: RoutePaths.merchant,
              builder: (context, state) =>
                  const Scaffold(body: Text('Merchant Workspace')),
            ),
          ],
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authViewModelProvider.overrideWith(() => _MockAuthViewModel()),
            ],
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(AccountSwitcherListView), findsOneWidget);
        expect(find.text('Account Switching'), findsWidgets);
        expect(find.text('Merchant Workspace'), findsOneWidget);
      },
    );
  });

  group('Customer Profile Responsive Layout Tests', () {
    testWidgets(
      'CustomerProfileScreen renders cleanly on mobile viewport 360x640',
      (tester) async {
        tester.view.physicalSize = const Size(360, 640);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        final router = GoRouter(
          initialLocation: RoutePaths.customerProfile,
          routes: [
            GoRoute(
              path: RoutePaths.customerProfile,
              builder: (context, state) => const CustomerProfileScreen(),
            ),
          ],
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authViewModelProvider.overrideWith(() => _MockAuthViewModel()),
            ],
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Account Profile'), findsOneWidget);
        expect(find.text('Personal details & mode switching'), findsOneWidget);
        expect(find.text('Profile Incomplete'), findsOneWidget);
        expect(find.text('Language Preference'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'CustomerProfileScreen adapts to two-column layout on desktop 1440x900',
      (tester) async {
        tester.view.physicalSize = const Size(1440, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        final router = GoRouter(
          initialLocation: RoutePaths.customerProfile,
          routes: [
            GoRoute(
              path: RoutePaths.customerProfile,
              builder: (context, state) => const CustomerProfileScreen(),
            ),
          ],
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authViewModelProvider.overrideWith(() => _MockAuthViewModel()),
            ],
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Account Profile'), findsOneWidget);
        expect(find.text('Profile Incomplete'), findsOneWidget);
        expect(find.text('Language Preference'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'CustomerProfileScreen renders without overflow on 320px screen width',
      (tester) async {
        tester.view.physicalSize = const Size(320, 600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        final router = GoRouter(
          initialLocation: RoutePaths.customerProfile,
          routes: [
            GoRoute(
              path: RoutePaths.customerProfile,
              builder: (context, state) => const CustomerProfileScreen(),
            ),
          ],
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authViewModelProvider.overrideWith(() => _MockAuthViewModel()),
            ],
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Account Profile'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });
}

class _MockAuthViewModel extends AuthViewModel {
  _MockAuthViewModel({this.initialProfile});

  final UserProfileModel? initialProfile;

  @override
  AuthState build() {
    final profile =
        initialProfile ??
        UserProfileModel(
          uid: 'test_user_1',
          email: 'test@example.com',
          fullName: 'Test User',
          phoneNumber: '+91 98765 43210',
          role: 'customer',
          createdAt: DateTime.now(),
        );
    return AuthState(
      isLoading: false,
      isInitialized: true,
      userProfile: profile,
      activeExperience: profile.role == 'merchant' ? 'merchant' : 'customer',
    );
  }

  @override
  Future<void> switchExperience(String targetExperience) async {
    final current = state.userProfile;
    final updated = current?.copyWith(role: targetExperience);
    state = state.copyWith(
      activeExperience: targetExperience,
      userProfile: updated,
    );
  }
}

class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _MockHttpClient();
  }
}

class _MockHttpClient implements HttpClient {
  @override
  bool autoUncompress = false;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _MockHttpClientRequest();

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _MockHttpClientRequest implements HttpClientRequest {
  @override
  final HttpHeaders headers = _MockHttpHeaders();

  @override
  Future<HttpClientResponse> close() async => _MockHttpClientResponse();

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _MockHttpHeaders implements HttpHeaders {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _MockHttpClientResponse implements HttpClientResponse {
  @override
  int get statusCode => 200;
  @override
  int get contentLength => _transparentImage.length;
  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;
  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.value(_transparentImage).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

final Uint8List _transparentImage = Uint8List.fromList(<int>[
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0A,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
]);

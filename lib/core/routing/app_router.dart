import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/routing/route_paths.dart';
import 'package:garage_card/features/authentication/View/auth_screen.dart';
import 'package:garage_card/features/authentication/ViewModel/auth_view_model.dart';
import 'package:garage_card/features/customer/appointments/View/customer_appointments_screen.dart';
import 'package:garage_card/features/customer/customer_navigation_shell.dart';
import 'package:garage_card/features/customer/dashboard/View/customer_dashboard_screen.dart';
import 'package:garage_card/features/customer/estimates/View/customer_estimates_screen.dart';
import 'package:garage_card/features/customer/invoices/View/customer_invoices_screen.dart';
import 'package:garage_card/features/customer/nearby_garages/View/nearby_garages_screen.dart';
import 'package:garage_card/features/customer/notifications/View/customer_notifications_screen.dart';
import 'package:garage_card/features/customer/profile/View/customer_profile_screen.dart';
import 'package:garage_card/features/customer/reminders/View/customer_reminders_screen.dart';
import 'package:garage_card/features/customer/service_jobs/View/customer_job_detail_screen.dart';
import 'package:garage_card/features/customer/vehicles/View/customer_vehicles_screen.dart';
import 'package:garage_card/features/merchant/analytics/View/merchant_analytics_screen.dart';
import 'package:garage_card/features/merchant/customers/View/merchant_customers_screen.dart';
import 'package:garage_card/features/merchant/dashboard/View/merchant_dashboard_screen.dart';
import 'package:garage_card/features/merchant/estimates/View/merchant_estimates_screen.dart';
import 'package:garage_card/features/merchant/garage_profile/View/garage_profile_screen.dart';
import 'package:garage_card/features/merchant/invoices/View/merchant_invoices_screen.dart';
import 'package:garage_card/features/merchant/merchant_navigation_shell.dart';
import 'package:garage_card/features/merchant/notifications/View/merchant_notifications_screen.dart';
import 'package:garage_card/features/merchant/service_jobs/View/merchant_job_detail_screen.dart';
import 'package:garage_card/features/merchant/service_jobs/View/merchant_jobs_screen.dart';
import 'package:garage_card/features/splash/View/splash_screen.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authViewModelProvider);

  return GoRouter(
    initialLocation: RoutePaths.splash,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final isSplashRoute = state.matchedLocation == RoutePaths.splash;
      if (isSplashRoute) {
        return null;
      }

      final isAuth = authState.isAuthenticated;
      final isAuthRoute = state.matchedLocation == RoutePaths.auth;

      if (!isAuth) {
        return isAuthRoute ? null : RoutePaths.auth;
      }

      if (isAuthRoute) {
        return authState.activeExperience == 'merchant'
            ? RoutePaths.merchant
            : RoutePaths.customer;
      }

      if (state.matchedLocation.startsWith('/merchant')) {
        if (authState.activeExperience != 'merchant') {
          return RoutePaths.customer;
        }
      }

      if (state.matchedLocation.startsWith('/customer')) {
        if (authState.activeExperience != 'customer') {
          return RoutePaths.merchant;
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: RoutePaths.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RoutePaths.auth,
        builder: (context, state) => const AuthScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            CustomerNavigationShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.customer,
                builder: (context, state) => CustomerDashboardScreen(
                  onNavigateToNearbyGarages: () =>
                      context.go(RoutePaths.customerGarages),
                  onNavigateToVehicles: () =>
                      context.go(RoutePaths.customerVehicles),
                  onNavigateToEstimates: () =>
                      context.go(RoutePaths.customerEstimates),
                  onNavigateToInvoices: () =>
                      context.go(RoutePaths.customerInvoices),
                  onNavigateToReminders: () =>
                      context.go(RoutePaths.customerReminders),
                  onNavigateToJobDetail: (id) =>
                      context.go('/customer/jobs/$id'),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.customerGarages,
                builder: (context, state) => NearbyGaragesScreen(
                  onSelectGarage: (id) =>
                      CustomerAppointmentsScreen.showBookingSheet(context,
                          garageId: id),
                  onRequestService: (id) =>
                      CustomerAppointmentsScreen.showBookingSheet(context,
                          garageId: id),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.customerVehicles,
                builder: (context, state) => CustomerVehiclesScreen(
                  onSelectVehicle: (id) {},
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.customerInvoices,
                builder: (context, state) => const CustomerInvoicesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.customerProfile,
                builder: (context, state) => const CustomerProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: RoutePaths.customerJobs,
        redirect: (context, state) => RoutePaths.customer,
      ),
      GoRoute(
        path: RoutePaths.customerEstimates,
        builder: (context, state) => const CustomerEstimatesScreen(),
      ),
      GoRoute(
        path: RoutePaths.customerReminders,
        builder: (context, state) => const CustomerRemindersScreen(),
      ),
      GoRoute(
        path: RoutePaths.customerNotifications,
        builder: (context, state) => const CustomerNotificationsScreen(),
      ),
      GoRoute(
        path: RoutePaths.customerJobDetail,
        builder: (context, state) {
          final jobId = state.pathParameters['id'] ?? '';
          return CustomerJobDetailScreen(jobId: jobId);
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MerchantNavigationShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.merchant,
                builder: (context, state) => MerchantDashboardScreen(
                  onNavigateToJobs: () => context.go(RoutePaths.merchantJobs),
                  onNavigateToCustomers: () =>
                      context.go(RoutePaths.merchantCustomers),
                  onNavigateToEstimates: () =>
                      context.go(RoutePaths.merchantEstimates),
                  onNavigateToInvoices: () =>
                      context.go(RoutePaths.merchantInvoices),
                  onNavigateToAppointments: () =>
                      context.go(RoutePaths.merchantJobs),
                  onNavigateToAnalytics: () =>
                      context.go(RoutePaths.merchantAnalytics),
                  onJobSelected: (id) => context.go('/merchant/jobs/$id'),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.merchantJobs,
                builder: (context, state) => const MerchantJobsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.merchantAnalytics,
                builder: (context, state) => const MerchantAnalyticsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.merchantCustomers,
                builder: (context, state) => const MerchantCustomersScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.merchantInvoices,
                builder: (context, state) => const MerchantInvoicesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.merchantSettings,
                builder: (context, state) => const GarageProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: RoutePaths.merchantEstimates,
        builder: (context, state) => const MerchantEstimatesScreen(),
      ),
      GoRoute(
        path: RoutePaths.merchantNotifications,
        builder: (context, state) => const MerchantNotificationsScreen(),
      ),
      GoRoute(
        path: RoutePaths.merchantJobDetail,
        builder: (context, state) {
          final jobId = state.pathParameters['id'] ?? '';
          return MerchantJobDetailScreen(jobId: jobId);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('404 - Page not found: ${state.uri}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(RoutePaths.auth),
              child: const Text('Return Home'),
            ),
          ],
        ),
      ),
    ),
  );
});

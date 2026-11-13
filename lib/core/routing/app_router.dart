import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/routing/route_paths.dart';
import 'package:garage_card/core/shared_widgets/no_internet_screen.dart';
import 'package:garage_card/features/authentication/Model/auth_state.dart';
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
import 'package:garage_card/features/customer/search/View/customer_search_screen.dart';
import 'package:garage_card/features/customer/service_jobs/View/customer_job_detail_screen.dart';
import 'package:garage_card/features/customer/service_jobs/View/customer_jobs_screen.dart';
import 'package:garage_card/features/customer/warranty/View/customer_warranty_vault_screen.dart';
import 'package:garage_card/features/merchant/analytics/View/merchant_analytics_screen.dart';
import 'package:garage_card/features/merchant/customers/View/merchant_customers_screen.dart';
import 'package:garage_card/features/merchant/dashboard/View/merchant_dashboard_screen.dart';
import 'package:garage_card/features/merchant/estimates/View/merchant_estimates_screen.dart';
import 'package:garage_card/features/merchant/garage_profile/View/garage_profile_screen.dart';
import 'package:garage_card/features/merchant/inventory/View/merchant_inventory_screen.dart';
import 'package:garage_card/features/merchant/invoices/View/merchant_invoices_screen.dart';
import 'package:garage_card/features/merchant/mechanics/View/merchant_mechanics_screen.dart';
import 'package:garage_card/features/merchant/merchant_navigation_shell.dart';
import 'package:garage_card/features/merchant/more/View/merchant_more_screen.dart';
import 'package:garage_card/features/merchant/notifications/View/merchant_notifications_screen.dart';
import 'package:garage_card/features/merchant/packages/View/merchant_packages_screen.dart';
import 'package:garage_card/features/merchant/recalls/View/merchant_recalls_screen.dart';
import 'package:garage_card/features/merchant/service_jobs/View/merchant_complete_job_screen.dart';
import 'package:garage_card/features/merchant/service_jobs/View/merchant_create_job_screen.dart';
import 'package:garage_card/features/merchant/service_jobs/View/merchant_job_detail_screen.dart';
import 'package:garage_card/features/merchant/service_jobs/View/merchant_jobs_screen.dart';
import 'package:garage_card/features/merchant/bays/View/merchant_bays_screen.dart';
import 'package:garage_card/features/shared/models/service_job_model.dart';
import 'package:garage_card/features/chat/View/chat_screen.dart';
import 'package:garage_card/features/chat/View/conversation_list_screen.dart';
import 'package:garage_card/features/customer/garage_details/View/customer_garage_detail_screen.dart';
import 'package:garage_card/features/legal/View/privacy_policy_screen.dart';
import 'package:garage_card/features/legal/View/terms_conditions_screen.dart';
import 'package:garage_card/features/merchant/service_catalog/View/merchant_services_screen.dart';
import 'package:garage_card/features/shared/repository/garage_repository.dart';
import 'package:garage_card/features/splash/View/splash_screen.dart';
import 'package:garage_card/features/support/views/customer_create_ticket_screen.dart';
import 'package:garage_card/features/support/views/customer_tickets_screen.dart';
import 'package:garage_card/features/support/views/merchant_tickets_screen.dart';
import 'package:garage_card/features/support/views/ticket_detail_screen.dart';
import 'package:go_router/go_router.dart';

class _AuthRouterListenable extends ChangeNotifier {
  _AuthRouterListenable(Ref ref) {
    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      notifyListeners();
    });
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final authNotifier = _AuthRouterListenable(ref);
  ref.onDispose(authNotifier.dispose);

  return GoRouter(
    initialLocation: RoutePaths.splash,
    refreshListenable: authNotifier,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final authState = ref.read(authViewModelProvider);
      final isSplashRoute = state.matchedLocation == RoutePaths.splash;

      final isPublicLegalRoute =
          state.matchedLocation == RoutePaths.privacy ||
          state.matchedLocation == RoutePaths.terms;
      if (isPublicLegalRoute) {
        return null;
      }

      final isAuth = authState.isAuthenticated;
      final isAuthRoute = state.matchedLocation == RoutePaths.auth;

      if (!authState.isInitialized) {
        if (isSplashRoute || isAuthRoute) {
          return null;
        }
        return RoutePaths.splash;
      }

      if (isSplashRoute) {
        if (!isAuth) {
          return RoutePaths.auth;
        }
        return authState.activeExperience == 'merchant'
            ? RoutePaths.merchant
            : RoutePaths.customer;
      }

      if (!isAuth) {
        return isAuthRoute ? null : RoutePaths.auth;
      }

      if (isAuthRoute) {
        return authState.activeExperience == 'merchant'
            ? RoutePaths.merchant
            : RoutePaths.customer;
      }

      if (state.matchedLocation == RoutePaths.customerVehicles) {
        return RoutePaths.customerGarages;
      }
      if (state.matchedLocation == RoutePaths.customerEstimates) {
        return RoutePaths.customerInvoices;
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
      GoRoute(
        path: RoutePaths.privacy,
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: RoutePaths.terms,
        builder: (context, state) => const TermsConditionsScreen(),
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
                  onNavigateToInvoices: () =>
                      context.go(RoutePaths.customerInvoices),
                  onNavigateToReminders: () =>
                      context.push(RoutePaths.customerReminders),
                  onNavigateToJobDetail: (id) =>
                      context.push('/customer/jobs/$id'),
                  onNavigateToJobs: () => context.push(RoutePaths.customerJobs),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.customerGarages,
                builder: (context, state) => NearbyGaragesScreen(
                  onSelectGarage: (id) => context.push('/customer/garages/$id'),
                  onRequestService: (id) =>
                      CustomerAppointmentsScreen.showBookingSheet(
                        context,
                        garageId: id,
                      ),
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
        path: RoutePaths.customerSearch,
        builder: (context, state) {
          final q = state.uri.queryParameters['q'];
          return CustomerSearchScreen(initialQuery: q);
        },
      ),
      GoRoute(
        path: RoutePaths.customerJobs,
        builder: (context, state) => const CustomerJobsScreen(),
      ),
      GoRoute(
        path: RoutePaths.customerVehicles,
        builder: (context, state) => NearbyGaragesScreen(
          onSelectGarage: (id) => context.push('/customer/garages/$id'),
          onRequestService: (id) => CustomerAppointmentsScreen.showBookingSheet(
            context,
            garageId: id,
          ),
        ),
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
                path: RoutePaths.merchantMore,
                builder: (context, state) => const MerchantMoreScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: RoutePaths.merchantCustomers,
        builder: (context, state) => const MerchantCustomersScreen(),
      ),
      GoRoute(
        path: RoutePaths.merchantInvoices,
        builder: (context, state) => const MerchantInvoicesScreen(),
      ),
      GoRoute(
        path: RoutePaths.merchantSettings,
        builder: (context, state) => const GarageProfileScreen(),
      ),
      GoRoute(
        path: RoutePaths.merchantServices,
        builder: (context, state) => const MerchantServicesScreen(),
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
        path: RoutePaths.merchantCreateJob,
        builder: (context, state) => const MerchantCreateJobScreen(),
      ),
      GoRoute(
        path: RoutePaths.merchantJobDetail,
        builder: (context, state) {
          final jobId = state.pathParameters['id'] ?? '';
          return MerchantJobDetailScreen(jobId: jobId);
        },
      ),
      GoRoute(
        path: RoutePaths.merchantCompleteJob,
        builder: (context, state) {
          final job = state.extra as ServiceJobModel?;
          if (job != null) {
            return MerchantCompleteJobScreen(job: job);
          }
          final jobId = state.pathParameters['id'] ?? '';
          return MerchantJobDetailScreen(jobId: jobId);
        },
      ),
      GoRoute(
        path: RoutePaths.merchantMechanics,
        builder: (context, state) => const MerchantMechanicsScreen(),
      ),
      GoRoute(
        path: RoutePaths.merchantBays,
        builder: (context, state) => const MerchantBaysScreen(),
      ),
      GoRoute(
        path: RoutePaths.merchantRecalls,
        builder: (context, state) => const MerchantRecallsScreen(),
      ),
      GoRoute(
        path: RoutePaths.merchantPackages,
        builder: (context, state) => const MerchantPackagesScreen(),
      ),
      GoRoute(
        path: RoutePaths.customerGarageDetail,
        builder: (context, state) {
          final garageId = state.pathParameters['id'] ?? '';
          final action = state.uri.queryParameters['action'];
          final jobId = state.uri.queryParameters['jobId'];
          return CustomerGarageDetailScreen(
            garageId: garageId,
            initialAction: action,
            targetJobId: jobId,
            onStartChat: () async {
              final repo = ref.read(garageRepositoryProvider);
              final user = ref.read(authViewModelProvider).userProfile;
              final garage = await repo.getGarageDetails(garageId);
              final conv = await repo.getOrCreateConversation(
                customerId: user?.uid ?? 'cust_1',
                customerName: user?.fullName ?? 'Customer',
                garageId: garageId,
                garageName: garage?.name ?? 'Garage',
              );
              if (context.mounted) {
                final encodedName = Uri.encodeComponent(conv.garageName);
                context.push('/chat/${conv.id}?name=$encodedName');
              }
            },
          );
        },
      ),
      GoRoute(
        path: RoutePaths.chatList,
        builder: (context, state) => const ConversationListScreen(),
      ),
      GoRoute(
        path: RoutePaths.chatDetail,
        builder: (context, state) {
          final convId = state.pathParameters['id'] ?? '';
          final name = state.uri.queryParameters['name'] ?? 'Chat';
          final subtitle = state.uri.queryParameters['subtitle'];
          final phone = state.uri.queryParameters['phone'];
          return ChatScreen(
            conversationId: convId,
            recipientName: name,
            recipientPhone: phone,
            subtitle: subtitle,
          );
        },
      ),
      GoRoute(
        path: RoutePaths.merchantServices,
        builder: (context, state) => const MerchantServicesScreen(),
      ),
      GoRoute(
        path: RoutePaths.merchantInventory,
        builder: (context, state) => const MerchantInventoryScreen(),
      ),
      GoRoute(
        path: RoutePaths.customerWarranties,
        builder: (context, state) => const CustomerWarrantyVaultScreen(),
      ),
      GoRoute(
        path: RoutePaths.customerSupport,
        builder: (context, state) => const CustomerTicketsScreen(),
      ),
      GoRoute(
        path: RoutePaths.customerCreateTicket,
        builder: (context, state) {
          final jobId = state.uri.queryParameters['jobId'];
          final garageId = state.uri.queryParameters['garageId'];
          final vehicleId = state.uri.queryParameters['vehicleId'];
          final invoiceId = state.uri.queryParameters['invoiceId'];
          return CustomerCreateTicketScreen(
            preselectedJobId: jobId,
            preselectedGarageId: garageId,
            preselectedVehicleId: vehicleId,
            preselectedInvoiceId: invoiceId,
          );
        },
      ),
      GoRoute(
        path: RoutePaths.customerTicketDetail,
        builder: (context, state) {
          final ticketId = state.pathParameters['id'] ?? '';
          return TicketDetailScreen(ticketId: ticketId);
        },
      ),
      GoRoute(
        path: RoutePaths.merchantSupport,
        builder: (context, state) => const MerchantTicketsScreen(),
      ),
      GoRoute(
        path: RoutePaths.merchantTicketDetail,
        builder: (context, state) {
          final ticketId = state.pathParameters['id'] ?? '';
          return TicketDetailScreen(ticketId: ticketId);
        },
      ),
      GoRoute(
        path: RoutePaths.noInternet,
        builder: (context, state) => const NoInternetScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Colors.red,
            ),
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

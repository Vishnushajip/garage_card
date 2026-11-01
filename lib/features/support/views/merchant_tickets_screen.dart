import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/localization/app_localizations.dart';
import 'package:garage_card/core/shared_widgets/app_custom_app_bar.dart';
import 'package:garage_card/core/shared_widgets/app_empty_state.dart';
import 'package:garage_card/core/shared_widgets/app_error_state.dart';
import 'package:garage_card/core/shared_widgets/app_responsive_layout.dart';
import 'package:garage_card/core/shared_widgets/app_skeleton_loader.dart';
import 'package:garage_card/core/shared_widgets/app_text_field.dart';
import 'package:garage_card/features/merchant/dashboard/ViewModel/merchant_dashboard_view_model.dart';
import 'package:garage_card/features/support/view_models/merchant_support_view_model.dart';
import 'package:garage_card/features/support/widgets/merchant_ticket_card.dart';
import 'package:garage_card/features/support/widgets/merchant_ticket_stats_row.dart';
import 'package:go_router/go_router.dart';

class MerchantTicketsScreen extends ConsumerStatefulWidget {
  const MerchantTicketsScreen({super.key});

  @override
  ConsumerState<MerchantTicketsScreen> createState() =>
      _MerchantTicketsScreenState();
}

class _MerchantTicketsScreenState extends ConsumerState<MerchantTicketsScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dashState = ref.read(merchantDashboardViewModelProvider);
      final garageId = dashState.garage?.id ?? '';
      if (garageId.isNotEmpty) {
        ref
            .read(merchantSupportViewModelProvider.notifier)
            .loadTickets(garageId);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildFilterChip(String label, String value, String currentSelected) {
    final isSelected = value == currentSelected;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {
          ref
              .read(merchantSupportViewModelProvider.notifier)
              .setStatusFilter(value);
        },
        selectedColor: AppColors.primaryRed,
        labelStyle:
            AppFonts.labelSmall(
              color: isSelected ? Colors.white : AppColors.textPrimaryLight,
            ).copyWith(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        showCheckmark: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(merchantSupportViewModelProvider);
    final notifier = ref.read(merchantSupportViewModelProvider.notifier);

    return Scaffold(
      appBar: AppCustomAppBar(
        title: context.tr('customerTickets'),
        subtitle: context.tr('merchantTicketsSubtitle'),
        actions: [
          IconButton(
            tooltip: context.tr('refresh'),
            icon: const Icon(Icons.refresh_rounded),
            onPressed: notifier.refresh,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: notifier.refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: AppResponsiveLayout(
            maxWidth: AppResponsiveLayout.kMaxProjectWidth,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MerchantTicketStatsRow(
                  stats: state.stats,
                  selectedFilter: state.selectedStatus,
                  onSelectFilter: (filterKey) {
                    notifier.setStatusFilter(filterKey);
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _searchController,
                  hint: context.tr('searchTicketsMerchantHint'),
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  onChanged: notifier.setSearchQuery,
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(
                        context.tr('all'),
                        'all',
                        state.selectedStatus,
                      ),
                      _buildFilterChip(
                        context.tr('open'),
                        'open',
                        state.selectedStatus,
                      ),
                      _buildFilterChip(
                        context.tr('inProgress'),
                        'in_progress',
                        state.selectedStatus,
                      ),
                      _buildFilterChip(
                        context.tr('waitingCustomer'),
                        'waiting_for_customer',
                        state.selectedStatus,
                      ),
                      _buildFilterChip(
                        context.tr('waitingMerchant'),
                        'waiting_for_merchant',
                        state.selectedStatus,
                      ),
                      _buildFilterChip(
                        context.tr('resolved'),
                        'resolved',
                        state.selectedStatus,
                      ),
                      _buildFilterChip(
                        context.tr('closed'),
                        'closed',
                        state.selectedStatus,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (state.isLoading)
                  AppSkeletonLoader.list(itemCount: 4)
                else if (state.errorMessage != null)
                  AppErrorState(
                    title: context.tr('errorOccurred'),
                    message: state.errorMessage!,
                    onRetry: notifier.refresh,
                  )
                else if (state.filteredTickets.isEmpty)
                  AppEmptyState(
                    icon: Icons.confirmation_number_outlined,
                    title:
                        state.searchQuery.isNotEmpty ||
                            state.selectedStatus != 'all'
                        ? context.tr('noMatchingTickets')
                        : context.tr('noCustomerTicketsYet'),
                    description:
                        state.searchQuery.isNotEmpty ||
                            state.selectedStatus != 'all'
                        ? context.tr('tryAdjustingFilters')
                        : context.tr('noCustomerTicketsDescription'),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.filteredTickets.length,
                    itemBuilder: (context, index) {
                      final ticket = state.filteredTickets[index];
                      return MerchantTicketCard(
                        ticket: ticket,
                        onTap: () =>
                            context.push('/merchant/support/${ticket.id}'),
                      );
                    },
                  ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

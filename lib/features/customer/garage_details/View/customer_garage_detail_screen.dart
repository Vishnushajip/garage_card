import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/shared_widgets/app_button.dart';
import 'package:garage_card/core/shared_widgets/app_custom_app_bar.dart';
import 'package:garage_card/core/shared_widgets/app_error_state.dart';
import 'package:garage_card/core/shared_widgets/app_loading.dart';
import 'package:garage_card/features/customer/appointments/View/customer_appointments_screen.dart';
import 'package:garage_card/features/customer/inquiry/customer_inquiry_service.dart';
import 'package:garage_card/features/shared/sharing/whatsapp_share_service.dart';

import '../ViewModel/customer_garage_detail_view_model.dart';
import '../Widgets/garage_detail_about_tab.dart';
import '../Widgets/garage_detail_reviews_tab.dart';
import '../Widgets/garage_detail_services_tab.dart';
import '../Widgets/write_review_dialog.dart';

class CustomerGarageDetailScreen extends ConsumerStatefulWidget {
  const CustomerGarageDetailScreen({
    super.key,
    required this.garageId,
    this.initialAction,
    this.targetJobId,
    this.onStartChat,
  });

  final String garageId;
  final String? initialAction;
  final String? targetJobId;
  final VoidCallback? onStartChat;

  @override
  ConsumerState<CustomerGarageDetailScreen> createState() =>
      _CustomerGarageDetailScreenState();
}

class _CustomerGarageDetailScreenState
    extends ConsumerState<CustomerGarageDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    if (widget.initialAction == 'review') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _tabController.animateTo(1);
        final state = ref.read(
          customerGarageDetailViewModelProvider(widget.garageId),
        );
        final vm = ref.read(
          customerGarageDetailViewModelProvider(widget.garageId).notifier,
        );
        WriteReviewDialog.show(
          context,
          garageName: state.garage?.name ?? 'Garage',
          garagePhone: state.garage?.phone,
          jobId: widget.targetJobId,
          onSubmit: vm.submitReview,
        );
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(
      customerGarageDetailViewModelProvider(widget.garageId),
    );
    final vm = ref.read(
      customerGarageDetailViewModelProvider(widget.garageId).notifier,
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryText = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final surfaceColor = isDark
        ? AppColors.surfaceDark
        : AppColors.surfaceLight;

    if (state.isLoading && state.garage == null) {
      return const Scaffold(body: Center(child: AppLoading()));
    }

    if (state.errorMessage != null && state.garage == null) {
      return Scaffold(
        appBar: const AppCustomAppBar(title: 'Workshop Details'),
        body: Center(
          child: AppErrorState(
            message: state.errorMessage!,
            onRetry: () => vm.loadGarage(widget.garageId),
          ),
        ),
      );
    }

    final garage = state.garage!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (ctx, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 240,
              pinned: true,
              backgroundColor: surfaceColor,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (garage.coverImageUrl != null)
                      Image.network(
                        garage.coverImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildFallbackBanner(),
                      )
                    else
                      _buildFallbackBanner(),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.3),
                            Colors.black.withValues(alpha: 0.8),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceDark,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              image: garage.logoUrl != null
                                  ? DecorationImage(
                                      image: NetworkImage(garage.logoUrl!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: garage.logoUrl == null
                                ? const Icon(
                                    Icons.garage_rounded,
                                    color: Colors.white,
                                    size: 32,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        garage.name,
                                        style: AppFonts.headlineSmall(
                                          color: Colors.white,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (garage.isVerified) ...[
                                      const SizedBox(width: 6),
                                      const Icon(
                                        Icons.verified_rounded,
                                        color: AppColors.primaryRed,
                                        size: 18,
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryAmber,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.star_rounded,
                                            size: 14,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            garage.rating.toStringAsFixed(1),
                                            style: AppFonts.labelSmall(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '(${garage.reviewCount} reviews)',
                                      style: AppFonts.bodySmall(
                                        color: Colors.white.withValues(
                                          alpha: 0.9,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '• ${garage.city}',
                                      style: AppFonts.bodySmall(
                                        color: Colors.white.withValues(
                                          alpha: 0.9,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    _buildActionPill(
                      context: context,
                      icon: Icons.directions_rounded,
                      label: 'Directions',
                      accentColor: AppColors.info,
                      onTap: () => WhatsAppShareService.openMapDirections(
                        latitude: garage.latitude,
                        longitude: garage.longitude,
                        label: garage.name,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildActionPill(
                      context: context,
                      icon: Icons.phone_rounded,
                      label: 'Call',
                      accentColor: AppColors.primaryGreen,
                      onTap: () =>
                          WhatsAppShareService.makePhoneCall(garage.phone),
                    ),
                    const SizedBox(width: 8),
                    _buildActionPill(
                      context: context,
                      icon: Icons.chat_rounded,
                      label: 'WhatsApp',
                      accentColor: const Color(0xFF25D366),
                      onTap: () => WhatsAppShareService.openWhatsAppChat(
                        phoneNumber: garage.phone,
                        text:
                            'Hello ${garage.name}, I found your garage on WeFix and would like to inquire about your services.',
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildActionPill(
                      context: context,
                      icon: Icons.forum_rounded,
                      label: 'Chat',
                      accentColor: AppColors.accentBlue,
                      onTap:
                          widget.onStartChat ??
                          () => CustomerInquiryService.startInquiry(
                            context,
                            ref,
                            garage: garage,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverTabHeaderDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primaryRed,
                  unselectedLabelColor: secondaryText,
                  indicatorColor: AppColors.primaryRed,
                  tabs: const [
                    Tab(text: 'Packages & Services'),
                    Tab(text: 'Reviews'),
                    Tab(text: 'About'),
                  ],
                ),
                surfaceColor,
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            GarageDetailServicesTab(
              garageId: widget.garageId,
              state: state,
              vm: vm,
              garage: garage,
            ),
            GarageDetailReviewsTab(
              garageId: widget.garageId,
              state: state,
              vm: vm,
              garage: garage,
            ),
            GarageDetailAboutTab(garage: garage),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: AppButton(
            label: 'Book Service Appointment',
            onPressed: () => CustomerAppointmentsScreen.showBookingSheet(
              context,
              garageId: garage.id,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackBanner() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
        ),
      ),
      child: const Center(
        child: Icon(Icons.car_repair_rounded, size: 64, color: Colors.white24),
      ),
    );
  }

  Widget _buildActionPill({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.28),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: accentColor),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: AppFonts.labelSmall(color: accentColor)
                      .copyWith(fontWeight: FontWeight.bold, fontSize: 10),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SliverTabHeaderDelegate extends SliverPersistentHeaderDelegate {
  _SliverTabHeaderDelegate(this.tabBar, this.backgroundColor);

  final TabBar tabBar;
  final Color backgroundColor;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: backgroundColor, child: tabBar);
  }

  @override
  bool shouldRebuild(_SliverTabHeaderDelegate oldDelegate) {
    return false;
  }
}

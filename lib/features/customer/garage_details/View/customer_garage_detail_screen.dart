import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/formatting/date_formatter.dart';
import 'package:garage_card/core/shared_widgets/app_button.dart';
import 'package:garage_card/core/shared_widgets/app_dropdown.dart';
import 'package:garage_card/core/shared_widgets/app_empty_state.dart';
import 'package:garage_card/core/shared_widgets/app_error_state.dart';
import 'package:garage_card/core/shared_widgets/app_loading.dart';
import 'package:garage_card/core/shared_widgets/app_refresh.dart';
import 'package:garage_card/features/customer/appointments/View/customer_appointments_screen.dart';
import 'package:garage_card/features/shared/models/garage_service_model.dart';
import 'package:garage_card/features/shared/models/review_model.dart';
import 'package:garage_card/features/shared/models/vehicle_model.dart';
import 'package:garage_card/features/shared/pricing/smart_pricing_engine.dart';
import 'package:garage_card/features/shared/sharing/whatsapp_share_service.dart';

import 'package:garage_card/core/shared_widgets/app_status_badge.dart';
import 'package:garage_card/core/shared_widgets/app_whatsapp_button.dart';

import '../Model/customer_garage_detail_state.dart';
import '../ViewModel/customer_garage_detail_view_model.dart';
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
        appBar: AppBar(),
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
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.call_rounded, size: 18),
                        label: const Text('Call'),
                        onPressed: () =>
                            WhatsAppShareService.makePhoneCall(garage.phone),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 18,
                        ),
                        label: const Text('Chat'),
                        onPressed: widget.onStartChat,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.directions_rounded, size: 18),
                        label: const Text('Directions'),
                        onPressed: () => WhatsAppShareService.openMapDirections(
                          latitude: garage.latitude,
                          longitude: garage.longitude,
                          label: garage.name,
                        ),
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
                    Tab(text: 'Services & Pricing'),
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
            _buildServicesTab(context, state, vm, garage),
            _buildReviewsTab(context, state, vm, garage),
            _buildAboutTab(context, garage),
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

  Widget _buildServicesTab(
    BuildContext context,
    CustomerGarageDetailState state,
    CustomerGarageDetailViewModel vm,
    dynamic garage,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryText = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return AppRefresh(
      onRefresh: () => vm.loadGarage(widget.garageId),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.cardLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.tune_rounded,
                      size: 18,
                      color: AppColors.primaryRed,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Smart Pricing Evaluator',
                      style: AppFonts.labelLarge(color: primaryText),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Pricing is dynamically calculated for your selected vehicle based on garage-configured engine capacity and category rules.',
                  style: AppFonts.bodySmall(color: secondaryText),
                ),
                const SizedBox(height: 12),
                if (state.customerVehicles.isNotEmpty)
                  AppDropdown<VehicleModel?>(
                    label: 'Calculating for vehicle',
                    value: state.selectedVehicle,
                    items: [
                      const AppDropdownItem<VehicleModel?>(
                        value: null,
                        title: 'Generic Standard Vehicle',
                      ),
                      ...state.customerVehicles.map(
                        (v) => AppDropdownItem<VehicleModel?>(
                          value: v,
                          title: '${v.displayName} • ${v.vehicleType}',
                        ),
                      ),
                    ],
                    onChanged: vm.selectVehicle,
                  )
                else
                  Text(
                    'No vehicles registered. Prices shown below reflect standard category pricing.',
                    style: AppFonts.bodySmall(color: AppColors.accentBlue),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: state.availableCategories.map((cat) {
                final isSelected = state.selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: AppColors.primaryRed,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : primaryText,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    onSelected: (_) => vm.selectCategory(cat),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          if (state.filteredServices.isEmpty)
            const AppEmptyState(
              title: 'No Services Available',
              message: 'This garage has not published services in this category yet.',
              icon: Icons.miscellaneous_services_rounded,
            )
          else
            ...state.filteredServices.map((service) {
              final evaluated = SmartPricingEngine.evaluate(
                service: service,
                vehicle: state.selectedVehicle,
                currencyCode: garage.currencyCode,
              );

              return _buildServiceCard(context, service, evaluated, garage.id);
            }),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildServiceCard(
    BuildContext context,
    GarageServiceModel service,
    EvaluatedPrice evaluated,
    String garageId,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryText = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    Color priceBadgeColor;
    if (evaluated.isQuotationRequired) {
      priceBadgeColor = AppColors.primaryAmber;
    } else if (evaluated.isStartingPrice) {
      priceBadgeColor = AppColors.accentBlue;
    } else {
      priceBadgeColor = AppColors.primaryGreen;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.name,
                        style: AppFonts.titleMedium(color: primaryText),
                      ),
                      if (service.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          service.description,
                          style: AppFonts.bodySmall(color: secondaryText),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: priceBadgeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: priceBadgeColor),
                  ),
                  child: Text(
                    evaluated.formattedDisplay,
                    style: AppFonts.labelLarge(color: priceBadgeColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 14,
                  color: secondaryText,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    evaluated.pricingSubtitle,
                    style: AppFonts.bodySmall(color: secondaryText),
                  ),
                ),
                Text(
                  '⏱ ${service.estimatedDuration}',
                  style: AppFonts.labelSmall(color: secondaryText),
                ),
              ],
            ),
            if (service.terms != null && service.terms!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                'Note: ${service.terms}',
                style: AppFonts.bodySmall(color: secondaryText),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsTab(
    BuildContext context,
    CustomerGarageDetailState state,
    CustomerGarageDetailViewModel vm,
    dynamic garage,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryText = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return AppRefresh(
      onRefresh: () => vm.loadGarage(widget.garageId),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.cardLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: Row(
              children: [
                Column(
                  children: [
                    Text(
                      garage.rating.toStringAsFixed(1),
                      style: AppFonts.displaySmall(
                        color: AppColors.primaryAmber,
                      ),
                    ),
                    Row(
                      children: List.generate(
                        5,
                        (i) => const Icon(
                          Icons.star_rounded,
                          size: 16,
                          color: AppColors.primaryAmber,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${garage.reviewCount} total reviews',
                      style: AppFonts.labelSmall(color: secondaryText),
                    ),
                  ],
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: AppButton(
                    label: 'Write a Review',
                    icon: const Icon(Icons.rate_review_outlined, size: 18),
                    onPressed: () => WriteReviewDialog.show(
                      context,
                      garageName: garage.name,
                      garagePhone: garage.phone,
                      onSubmit: vm.submitReview,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Verified Customer Reviews',
            style: AppFonts.titleMedium(color: primaryText),
          ),
          const SizedBox(height: 12),
          if (state.reviews.isEmpty)
            const AppEmptyState(
              title: 'No Reviews Yet',
              message: 'Be the first to rate your service experience at this garage!',
              icon: Icons.star_border_rounded,
            )
          else
            ...state.reviews.map((r) => _buildReviewItem(context, r)),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildReviewItem(BuildContext context, ReviewModel review) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryText = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    final publicPhoto = review.publicPhotoUrl;
    final publicReviewImage = review.publicReviewImageUrl;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primaryRed.withValues(alpha: 0.1),
                  backgroundImage: publicPhoto != null
                      ? NetworkImage(publicPhoto)
                      : null,
                  child: publicPhoto == null
                      ? Text(
                          review.displayCustomerName.isNotEmpty
                              ? review.displayCustomerName[0].toUpperCase()
                              : 'C',
                          style: AppFonts.labelMedium(
                            color: AppColors.primaryRed,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.displayCustomerName,
                        style: AppFonts.titleSmall(color: primaryText),
                      ),
                      if (review.createdAt != null)
                        Text(
                          DateFormatter.formatDateTime(review.createdAt!),
                          style: AppFonts.bodySmall(color: secondaryText),
                        ),
                    ],
                  ),
                ),
                Row(
                  children: List.generate(
                    5,
                    (i) => Icon(
                      i < review.rating.round()
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      size: 16,
                      color: AppColors.primaryAmber,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              review.reviewText,
              style: AppFonts.bodyMedium(color: primaryText),
            ),
            if (publicReviewImage != null) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  publicReviewImage,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.shrink(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAboutTab(BuildContext context, dynamic garage) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryText = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final surfaceColor = isDark
        ? AppColors.surfaceDark
        : AppColors.surfaceLight;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (garage.description.isNotEmpty) ...[
          Text('About Garage', style: AppFonts.titleMedium(color: primaryText)),
          const SizedBox(height: 6),
          Text(
            garage.description,
            style: AppFonts.bodyMedium(color: secondaryText),
          ),
          const SizedBox(height: 20),
        ],
        Text(
          'Operating Hours & Contact',
          style: AppFonts.titleMedium(color: primaryText),
        ),
        const SizedBox(height: 12),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(
            Icons.access_time_rounded,
            color: AppColors.primaryRed,
          ),
          title: Text(
            garage.openHours,
            style: AppFonts.bodyMedium(color: primaryText),
          ),
          subtitle: Text(
            'Opening hours',
            style: AppFonts.bodySmall(color: secondaryText),
          ),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(
            Icons.location_on_rounded,
            color: AppColors.primaryRed,
          ),
          title: Text(
            garage.address,
            style: AppFonts.bodyMedium(color: primaryText),
          ),
          subtitle: Text(
            'Physical address',
            style: AppFonts.bodySmall(color: secondaryText),
          ),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.phone_rounded, color: AppColors.primaryRed),
          title: Text(
            garage.phone,
            style: AppFonts.bodyMedium(color: primaryText),
          ),
          subtitle: Text(
            'Direct phone',
            style: AppFonts.bodySmall(color: secondaryText),
          ),
        ),
        if (garage.taxNumber.isNotEmpty)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(
              Icons.badge_rounded,
              color: AppColors.primaryRed,
            ),
            title: Text(
              garage.taxNumber,
              style: AppFonts.bodyMedium(color: primaryText),
            ),
            subtitle: Text(
              'GST / Tax Registration',
              style: AppFonts.bodySmall(color: secondaryText),
            ),
          ),
        const SizedBox(height: 20),
        Text(
          'On-Site & Emergency Services',
          style: AppFonts.titleMedium(color: primaryText),
        ),
        const SizedBox(height: 12),
        Card(
          color: surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color:
                            (garage.isRoadsideAssistanceAvailable as bool? ??
                                true)
                            ? AppColors.errorBg
                            : AppColors.cardLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.emergency_rounded,
                        color:
                            (garage.isRoadsideAssistanceAvailable as bool? ??
                                true)
                            ? AppColors.error
                            : AppColors.textSecondaryLight,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'On-Road Breakdown Assistance',
                                  style: AppFonts.titleSmall(
                                    color: primaryText,
                                  ),
                                ),
                              ),
                              AppStatusBadge(
                                status:
                                    (garage.isRoadsideAssistanceAvailable
                                            as bool? ??
                                        true)
                                    ? 'approved'
                                    : 'rejected',
                                customLabel:
                                    (garage.isRoadsideAssistanceAvailable
                                            as bool? ??
                                        true)
                                    ? 'AVAILABLE'
                                    : 'UNAVAILABLE',
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            (garage.isRoadsideAssistanceAvailable as bool? ??
                                    true)
                                ? 'Mechanics travel directly to your on-road vehicle breakdown spot for emergency fixes.'
                                : 'Roadside emergency dispatch is currently unavailable for this garage.',
                            style: AppFonts.bodySmall(color: secondaryText),
                          ),
                          if (garage.isRoadsideAssistanceAvailable as bool? ??
                              true) ...[
                            const SizedBox(height: 12),
                            AppWhatsAppButton(
                              phoneNumber: garage.phone,
                              label: 'Request On-Road Help (WhatsApp)',
                              isFullWidth: true,
                              message: 'SOS: My vehicle is broken down on the road. Please let me know if a mechanic can reach my location.',
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color:
                            (garage.isDoorstepRepairAvailable as bool? ?? true)
                            ? AppColors.successBg
                            : AppColors.cardLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.home_repair_service_rounded,
                        color:
                            (garage.isDoorstepRepairAvailable as bool? ?? true)
                            ? AppColors.success
                            : AppColors.textSecondaryLight,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Doorstep Service / Pickup',
                                  style: AppFonts.titleSmall(
                                    color: primaryText,
                                  ),
                                ),
                              ),
                              AppStatusBadge(
                                status:
                                    (garage.isDoorstepRepairAvailable
                                            as bool? ??
                                        true)
                                    ? 'approved'
                                    : 'rejected',
                                customLabel:
                                    (garage.isDoorstepRepairAvailable
                                            as bool? ??
                                        true)
                                    ? 'AVAILABLE'
                                    : 'UNAVAILABLE',
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            (garage.isDoorstepRepairAvailable as bool? ?? true)
                                ? 'Mechanics visit your doorstep or pick up your vehicle from home/office.'
                                : 'Doorstep repair and vehicle pickup are not offered by this workshop.',
                            style: AppFonts.bodySmall(color: secondaryText),
                          ),
                          if (garage.isDoorstepRepairAvailable as bool? ??
                              true) ...[
                            const SizedBox(height: 12),
                            AppWhatsAppButton(
                              phoneNumber: garage.phone,
                              label: 'Book Doorstep Service (WhatsApp)',
                              variant: WhatsAppButtonVariant.outline,
                              isFullWidth: true,
                              message:
                                  'Hello ${garage.name}, I would like to enquire about doorstep repair/pickup for my vehicle.',
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 80),
      ],
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/pagination/proactive_scroll_listener.dart';
import 'package:garage_card/core/shared_widgets/app_custom_app_bar.dart';
import 'package:garage_card/core/shared_widgets/app_empty_state.dart';
import 'package:garage_card/core/shared_widgets/app_error_state.dart';
import 'package:garage_card/core/shared_widgets/app_loading.dart';
import 'package:garage_card/core/shared_widgets/app_pagination_loader.dart';
import 'package:garage_card/core/shared_widgets/app_refresh.dart';
import 'package:garage_card/core/shared_widgets/app_responsive_layout.dart';
import 'package:garage_card/core/utils/debouncer.dart';

import '../ViewModel/nearby_garages_view_model.dart';
import '../Widgets/garage_card_item.dart';

class NearbyGaragesScreen extends ConsumerStatefulWidget {
  const NearbyGaragesScreen({
    super.key,
    required this.onSelectGarage,
    required this.onRequestService,
  });

  final ValueChanged<String> onSelectGarage;
  final ValueChanged<String> onRequestService;

  @override
  ConsumerState<NearbyGaragesScreen> createState() =>
      _NearbyGaragesScreenState();
}

class _NearbyGaragesScreenState extends ConsumerState<NearbyGaragesScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final Debouncer _debouncer = Debouncer(
    delay: const Duration(milliseconds: 350),
  );
  late final ProactiveScrollListener _scrollListener;
  String _lastQuery = '';
  bool _searchFocused = false;

  @override
  void initState() {
    super.initState();
    _scrollListener = ProactiveScrollListener(
      onPrefetchRequested: () {
        ref.read(nearbyGaragesViewModelProvider.notifier).fetchNextPage();
      },
    );
    final initialQuery = ref.read(nearbyGaragesViewModelProvider).searchQuery;
    if (initialQuery.isNotEmpty) {
      _searchCtrl.text = initialQuery;
      _lastQuery = initialQuery;
    }
  }

  @override
  void dispose() {
    _debouncer.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _runSearch(String raw) {
    final query = raw.trim();
    if (query == _lastQuery) return;
    if (mounted) {
      setState(() => _lastQuery = query);
    }
    ref.read(nearbyGaragesViewModelProvider.notifier).search(query);
  }

  void _onSearchSubmitted(String val) {
    _debouncer.dispose();
    _runSearch(val);
  }

  void _clearSearch() {
    _debouncer.dispose();
    _searchCtrl.clear();
    _runSearch('');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(nearbyGaragesViewModelProvider);
    final vm = ref.read(nearbyGaragesViewModelProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: const AppCustomAppBar(title: 'Nearby Garages & Packages'),
      body: NotificationListener<ScrollNotification>(
        onNotification: _scrollListener.handleScrollNotification,
        child: AppRefresh(
          onRefresh: vm.refresh,
          child: AppResponsiveLayout(
            child: LayoutBuilder(
              builder: (ctx, constraints) {
                final width = constraints.maxWidth;
                final columns = width >= 1024 ? 3 : (width >= 650 ? 2 : 1);
                const spacing = 16.0;
                final itemWidth = (width - spacing * (columns - 1)) / columns;
                final hasQuery = _lastQuery.isNotEmpty;

                final slivers = <Widget>[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildSearchField(isDark, state.isLoading),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildSpotlightPackageBanner(isDark),
                    ),
                  ),
                ];

                if (state.isLoading) {
                  slivers.add(
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: AppLoading(
                        message: hasQuery
                            ? 'Searching for "$_lastQuery"...'
                            : 'Searching nearby garages & packages...',
                      ),
                    ),
                  );
                } else if (state.errorMessage != null &&
                    state.garages.isEmpty) {
                  slivers.add(
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: AppErrorState(
                        message: state.errorMessage!,
                        onRetry: vm.refresh,
                      ),
                    ),
                  );
                } else if (state.garages.isEmpty) {
                  slivers.add(
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: AppEmptyState(
                        title: 'No Garages Found',
                        message: hasQuery
                            ? 'No results for "$_lastQuery". Try another garage name, locality or city.'
                            : 'Try searching for another locality or extending your search radius.',
                        icon: Icons.location_off_rounded,
                      ),
                    ),
                  );
                } else {
                  slivers.add(
                    SliverToBoxAdapter(
                      child: _buildResultsHeader(
                        isDark: isDark,
                        title: hasQuery
                            ? 'Results for "$_lastQuery"'
                            : 'Garages near you',
                        count: state.garages.length,
                      ),
                    ),
                  );
                  slivers.add(
                    SliverToBoxAdapter(
                      child: Wrap(
                        spacing: spacing,
                        runSpacing: spacing,
                        children: [
                          for (final garage in state.garages)
                            SizedBox(
                              width: itemWidth,
                              child: GarageCardItem(
                                key: ValueKey(garage.id),
                                garage: garage,
                                userLat: state.userLatitude,
                                userLon: state.userLongitude,
                                onTap: () => widget.onSelectGarage(garage.id),
                                onRequestService: () =>
                                    widget.onRequestService(garage.id),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                  slivers.add(
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 24),
                        child: AppPaginationLoader(
                          isLoading: state.isFetchingNextPage,
                          errorMessage: state.errorMessage,
                          onRetry: vm.fetchNextPage,
                        ),
                      ),
                    ),
                  );
                }

                return CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: slivers,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField(bool isDark, bool isLoading) {
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final primaryText = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryText = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _searchFocused ? AppColors.accentBlue : borderColor,
          width: _searchFocused ? 1.6 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentBlue.withValues(
              alpha: _searchFocused ? 0.16 : 0.06,
            ),
            blurRadius: _searchFocused ? 20 : 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Focus(
        onFocusChange: (focused) {
          if (mounted) setState(() => _searchFocused = focused);
        },
        child: TextField(
          controller: _searchCtrl,
          textInputAction: TextInputAction.search,
          style: AppFonts.bodyMedium(color: primaryText),
          cursorColor: AppColors.accentBlue,
          onChanged: (val) {
            _debouncer.run(() => _runSearch(val));
          },
          onSubmitted: _onSearchSubmitted,
          decoration: InputDecoration(
            hintText: 'Search by garage name, locality, or city...',
            hintStyle: AppFonts.bodyMedium(
              color: secondaryText.withValues(alpha: 0.8),
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 4,
              vertical: 16,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 10, right: 6),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.accentBlue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: AppColors.accentBlue,
                ),
              ),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 54,
              minHeight: 36,
            ),
            suffixIcon: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _searchCtrl,
              builder: (_, value, _) {
                if (isLoading && _lastQuery.isNotEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.accentBlue,
                      ),
                    ),
                  );
                }
                if (value.text.isEmpty) return const SizedBox.shrink();
                return IconButton(
                  tooltip: 'Clear',
                  icon: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: secondaryText,
                  ),
                  onPressed: _clearSearch,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultsHeader({
    required bool isDark,
    required String title,
    required int count,
  }) {
    final primaryText = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;

    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.primaryRed,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppFonts.titleSmall(color: primaryText)
                  .copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.2),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.accentBlue.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count found',
              style: AppFonts.labelSmall(color: AppColors.accentBlue)
                  .copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpotlightPackageBanner(bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.accentAmber.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: -45,
              right: -35,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accentAmber.withValues(alpha: 0.35),
                      AppColors.accentAmber.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.accentAmber,
                                Color.lerp(
                                  AppColors.accentAmber,
                                  Colors.deepOrange,
                                  0.35,
                                )!,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.flash_on_rounded,
                                size: 13,
                                color: Colors.black,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  'EXCLUSIVE WORKSHOP PACKAGES',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style:
                                      AppFonts.labelSmall(color: Colors.black)
                                          .copyWith(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 10,
                                          ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(
                        Icons.verified_rounded,
                        color: AppColors.accentAmber,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Fixed Pricing',
                        style: AppFonts.labelSmall(color: Colors.white70),
                        maxLines: 1,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Comprehensive Periodic Services & Inspection Packs',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.titleSmall(color: Colors.white).copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Compare garages, see what\'s included, and chat with mechanics before booking.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.bodySmall(color: Colors.white70)
                        .copyWith(height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

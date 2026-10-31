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
import 'package:garage_card/core/shared_widgets/app_text_field.dart';
import 'package:garage_card/core/utils/debouncer.dart';
import 'package:garage_card/features/shared/models/garage_model.dart';

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
  final Debouncer _debouncer = Debouncer();
  late final ProactiveScrollListener _scrollListener;

  @override
  void initState() {
    super.initState();
    _scrollListener = ProactiveScrollListener(
      onPrefetchRequested: () {
        ref.read(nearbyGaragesViewModelProvider.notifier).fetchNextPage();
      },
    );
  }

  @override
  void dispose() {
    _debouncer.dispose();
    _searchCtrl.dispose();
    super.dispose();
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
            child: Column(
              children: [
                AppTextField(
                  controller: _searchCtrl,
                  hint: 'Search by garage name, locality, or city...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _searchCtrl.clear();
                            vm.search('');
                          },
                        )
                      : null,
                  onChanged: (val) {
                    _debouncer.run(() => vm.search(val));
                  },
                ),
                const SizedBox(height: 12),
                _buildSpotlightPackageBanner(isDark),
                const SizedBox(height: 12),
                Expanded(
                  child: Builder(
                    builder: (context) {
                      if (state.isLoading) {
                        return const AppLoading(
                          message: 'Searching nearby garages & packages...',
                        );
                      }
                      if (state.errorMessage != null && state.garages.isEmpty) {
                        return AppErrorState(
                          message: state.errorMessage!,
                          onRetry: vm.refresh,
                        );
                      }
                      if (state.garages.isEmpty) {
                        return const AppEmptyState(
                          title: 'No Garages Found',
                          message: 'Try searching for another locality or extending your search radius.',
                          icon: Icons.location_off_rounded,
                        );
                      }

                      return LayoutBuilder(
                        builder: (ctx, constraints) {
                          final width = constraints.maxWidth;
                          final columns = width >= 1024
                              ? 3
                              : (width >= 650 ? 2 : 1);

                          final chunked = <List<GarageModel>>[];
                          for (
                            var i = 0;
                            i < state.garages.length;
                            i += columns
                          ) {
                            chunked.add(
                              state.garages.sublist(
                                i,
                                (i + columns > state.garages.length)
                                    ? state.garages.length
                                    : i + columns,
                              ),
                            );
                          }

                          return ListView.builder(
                            itemCount: chunked.length + 1,
                            itemBuilder: (ctx, index) {
                              if (index == chunked.length) {
                                return AppPaginationLoader(
                                  isLoading: state.isFetchingNextPage,
                                  errorMessage: state.errorMessage,
                                  onRetry: vm.fetchNextPage,
                                );
                              }

                              final rowItems = chunked[index];
                              if (columns == 1) {
                                final garage = rowItems.first;
                                return GarageCardItem(
                                  garage: garage,
                                  userLat: state.userLatitude,
                                  userLon: state.userLongitude,
                                  onTap: () => widget.onSelectGarage(garage.id),
                                  onRequestService: () =>
                                      widget.onRequestService(garage.id),
                                );
                              }

                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (int c = 0; c < columns; c++) ...[
                                    if (c > 0) const SizedBox(width: 16),
                                    if (c < rowItems.length)
                                      Expanded(
                                        child: GarageCardItem(
                                          garage: rowItems[c],
                                          userLat: state.userLatitude,
                                          userLon: state.userLongitude,
                                          onTap: () => widget.onSelectGarage(
                                            rowItems[c].id,
                                          ),
                                          onRequestService: () => widget
                                              .onRequestService(rowItems[c].id),
                                        ),
                                      )
                                    else
                                      const Expanded(child: SizedBox.shrink()),
                                  ],
                                ],
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpotlightPackageBanner(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accentAmber.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.accentAmber,
                  borderRadius: BorderRadius.circular(6),
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
                    Text(
                      'EXCLUSIVE WORKSHOP PACKAGES',
                      style: AppFonts.labelSmall(color: Colors.black)
                          .copyWith(fontWeight: FontWeight.bold, fontSize: 10),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.verified_rounded,
                color: AppColors.accentAmber,
                size: 14,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  'Fixed Pricing',
                  style: AppFonts.labelSmall(color: Colors.white70),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Comprehensive Periodic Services & Inspection Packs',
            style: AppFonts.titleSmall(color: Colors.white)
                .copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Compare certified garages, review included parts & labor, and chat directly with mechanics before booking.',
            style: AppFonts.bodySmall(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

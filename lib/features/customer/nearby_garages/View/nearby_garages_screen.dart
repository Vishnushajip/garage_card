import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/pagination/proactive_scroll_listener.dart';
import 'package:garage_card/core/shared_widgets/app_empty_state.dart';
import 'package:garage_card/core/shared_widgets/app_error_state.dart';
import 'package:garage_card/core/shared_widgets/app_loading.dart';
import 'package:garage_card/core/shared_widgets/app_pagination_loader.dart';
import 'package:garage_card/core/shared_widgets/app_refresh.dart';
import 'package:garage_card/core/shared_widgets/app_responsive_layout.dart';
import 'package:garage_card/core/shared_widgets/app_text_field.dart';
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
  ConsumerState<NearbyGaragesScreen> createState() => _NearbyGaragesScreenState();
}

class _NearbyGaragesScreenState extends ConsumerState<NearbyGaragesScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
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
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(nearbyGaragesViewModelProvider);
    final vm = ref.read(nearbyGaragesViewModelProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Nearby Garages',
          style: AppFonts.titleLarge(color: primaryTextColor),
        ),
      ),
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
                    vm.search(val);
                  },
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Builder(
                    builder: (context) {
                      if (state.isLoading) {
                        return const AppLoading(message: 'Searching nearby garages...');
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
                          message:
                              'Try searching for another locality or extending your search radius.',
                          icon: Icons.location_off_rounded,
                        );
                      }

                      return ListView.builder(
                        itemCount: state.garages.length + 1,
                        itemBuilder: (ctx, index) {
                          if (index == state.garages.length) {
                            return AppPaginationLoader(
                              isLoading: state.isFetchingNextPage,
                              errorMessage: state.errorMessage,
                              onRetry: vm.fetchNextPage,
                            );
                          }

                          final garage = state.garages[index];
                          return GarageCardItem(
                            garage: garage,
                            userLat: state.userLatitude,
                            userLon: state.userLongitude,
                            onTap: () => widget.onSelectGarage(garage.id),
                            onRequestService: () =>
                                widget.onRequestService(garage.id),
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
}

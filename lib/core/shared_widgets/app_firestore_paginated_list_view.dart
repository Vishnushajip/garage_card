import 'package:flutter/material.dart';
import 'package:garage_card/core/constants/app_constants.dart';
import 'package:garage_card/core/pagination/proactive_scroll_listener.dart';
import 'package:garage_card/core/shared_widgets/app_error_state.dart';
import 'package:garage_card/core/shared_widgets/app_loading.dart';
import 'package:garage_card/core/shared_widgets/app_pagination_loader.dart';
import 'package:garage_card/core/shared_widgets/app_refresh.dart';

class AppFirestorePaginatedListView<T> extends StatelessWidget {
  const AppFirestorePaginatedListView({
    super.key,
    required this.items,
    required this.isInitialLoading,
    required this.isFetchingNextPage,
    required this.hasMore,
    required this.onPrefetchNextPage,
    required this.onRefresh,
    required this.itemBuilder,
    required this.emptyState,
    this.header,
    this.errorMessage,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.prefetchThreshold = AppConstants.paginationPrefetchThreshold,
    this.separator,
  });

  final List<T> items;
  final bool isInitialLoading;
  final bool isFetchingNextPage;
  final bool hasMore;
  final VoidCallback onPrefetchNextPage;
  final Future<void> Function() onRefresh;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget emptyState;
  final Widget? header;
  final String? errorMessage;
  final EdgeInsetsGeometry padding;
  final double prefetchThreshold;
  final Widget? separator;

  @override
  Widget build(BuildContext context) {
    if (isInitialLoading && items.isEmpty) {
      return Column(
        children: [
          ?header,
          const Expanded(child: AppLoading(message: 'Loading records...')),
        ],
      );
    }

    if (errorMessage != null && items.isEmpty) {
      return Column(
        children: [
          ?header,
          Expanded(
            child: Center(
              child: AppErrorState(message: errorMessage!, onRetry: onRefresh),
            ),
          ),
        ],
      );
    }

    final scrollListener = ProactiveScrollListener(
      threshold: prefetchThreshold,
      onPrefetchRequested: () {
        if (hasMore && !isFetchingNextPage && !isInitialLoading) {
          onPrefetchNextPage();
        }
      },
    );

    return NotificationListener<ScrollNotification>(
      onNotification: scrollListener.handleScrollNotification,
      child: AppRefresh(
        onRefresh: onRefresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            if (header != null) SliverToBoxAdapter(child: header!),
            if (items.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: emptyState),
              )
            else
              SliverPadding(
                padding: padding,
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final itemIndex = separator != null ? index ~/ 2 : index;
                      final isSeparator = separator != null && index.isOdd;

                      if (isSeparator) {
                        return separator!;
                      }

                      return itemBuilder(context, items[itemIndex], itemIndex);
                    },
                    childCount: separator != null
                        ? (items.length * 2) - 1
                        : items.length,
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: AppPaginationLoader(isLoading: isFetchingNextPage),
            ),
          ],
        ),
      ),
    );
  }
}

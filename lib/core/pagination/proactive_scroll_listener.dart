import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

class ProactiveScrollListener {
  ProactiveScrollListener({
    required this.onPrefetchRequested,
    this.threshold = AppConstants.paginationPrefetchThreshold,
  });

  final VoidCallback onPrefetchRequested;
  final double threshold;

  bool handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      final metrics = notification.metrics;
      if (metrics.maxScrollExtent > 0) {
        final currentPosition = metrics.pixels;
        final triggerPosition = metrics.maxScrollExtent * threshold;
        if (currentPosition >= triggerPosition) {
          onPrefetchRequested();
        }
      }
    }
    return false;
  }
}

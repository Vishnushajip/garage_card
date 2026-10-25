import 'package:flutter/material.dart';

import '../colors/app_colors.dart';

class AppRefresh extends StatelessWidget {
  const AppRefresh({super.key, required this.onRefresh, required this.child});

  final Future<void> Function() onRefresh;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.accentBlue,
      backgroundColor: Theme.of(context).cardColor,
      child: child,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/network/connectivity_service.dart';
import 'package:garage_card/core/shared_widgets/no_internet_screen.dart';

class AppConnectivityWrapper extends ConsumerWidget {
  const AppConnectivityWrapper({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider);

    if (!isOnline) {
      return const NoInternetScreen();
    }

    return child;
  }
}

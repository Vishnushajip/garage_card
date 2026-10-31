import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/network/connectivity_service.dart';
import 'package:garage_card/core/shared_widgets/no_internet_screen.dart';

class AppConnectivityWrapper extends ConsumerWidget {
  const AppConnectivityWrapper({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider);
    final allowOffline = ref.watch(offlineBrowsingProvider);

    if (!isOnline && !allowOffline) {
      return const NoInternetScreen();
    }

    if (!isOnline && allowOffline) {
      return Scaffold(
        body: Column(
          children: [
            Material(
              color: AppColors.warning,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.wifi_off_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Offline Mode — Viewing cached data',
                          style: AppFonts.labelSmall(color: Colors.white)
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      InkWell(
                        onTap: () => ref
                            .read(connectivityControllerProvider.notifier)
                            .retry(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Retry Sync',
                            style: AppFonts.labelSmall(color: Colors.white)
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(child: child),
          ],
        ),
      );
    }

    return child;
  }
}

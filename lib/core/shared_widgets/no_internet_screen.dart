import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/network/connectivity_service.dart';
import 'package:garage_card/core/shared_widgets/app_button.dart';
import 'package:garage_card/core/shared_widgets/app_responsive_layout.dart';
import 'package:garage_card/core/shared_widgets/app_status_badge.dart';

class NoInternetScreen extends ConsumerStatefulWidget {
  const NoInternetScreen({super.key, this.onRetrySuccess});

  final VoidCallback? onRetrySuccess;

  @override
  ConsumerState<NoInternetScreen> createState() => _NoInternetScreenState();
}

class _NoInternetScreenState extends ConsumerState<NoInternetScreen> {
  bool _isChecking = false;

  Future<void> _handleRetry() async {
    if (_isChecking) return;
    setState(() => _isChecking = true);

    final isBackOnline = await ref
        .read(connectivityControllerProvider.notifier)
        .retry();

    if (!mounted) return;
    setState(() => _isChecking = false);

    if (isBackOnline) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.wifi, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                'Internet connection restored',
                style: AppFonts.bodyMedium(color: Colors.white),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );
      widget.onRetrySuccess?.call();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.wifi_off, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                'Still offline. Check Wi-Fi or cellular network',
                style: AppFonts.bodyMedium(color: Colors.white),
              ),
            ],
          ),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final bgColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;
    final cardBgColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: AppResponsiveLayout(
              maxWidth: 520,
              padding: EdgeInsets.zero,
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.35 : 0.06),
                      blurRadius: 28,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AppStatusBadge(
                      status: 'rejected',
                      customLabel: 'OFFLINE MODE',
                    ),
                    const SizedBox(height: 24),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        height: 220,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF0F172A)
                              : const Color(0xFFF1F5F9),
                          border: Border.all(
                            color: borderColor.withOpacity(0.5),
                          ),
                        ),
                        child: Image.asset(
                          'assets/images/no_internet.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Center(
                            child: Icon(
                              Icons.wifi_off_rounded,
                              size: 80,
                              color: AppColors.primaryRed.withOpacity(0.8),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No Internet Connection',
                      style: AppFonts.titleLarge(color: primaryTextColor)
                          .copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Garage Card requires an active internet connection to sync live repair jobs, digital estimates, and customer invoices in real time.',
                      style: AppFonts.bodyMedium(color: secondaryTextColor)
                          .copyWith(height: 1.5),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.backgroundDark
                            : AppColors.backgroundLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            size: 20,
                            color: AppColors.accentBlue,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Please check your Wi-Fi router or cellular mobile data connection.',
                              style: AppFonts.labelSmall(
                                color: secondaryTextColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    AppButton(
                      label: 'Check Connection',
                      icon: const Icon(
                        Icons.refresh_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                      isFullWidth: true,
                      isLoading: _isChecking,
                      onPressed: _handleRetry,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

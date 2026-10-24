import 'package:flutter/material.dart';
import '../colors/app_colors.dart';
import '../fonts/app_fonts.dart';

class AppPaginationLoader extends StatelessWidget {
  const AppPaginationLoader({
    super.key,
    required this.isLoading,
    this.errorMessage,
    this.onRetry,
  });

  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    if (errorMessage != null && onRetry != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                errorMessage!,
                style: AppFonts.labelSmall(color: AppColors.error),
              ),
              const SizedBox(height: 6),
              TextButton(
                onPressed: onRetry,
                child: const Text('Retry loading more'),
              ),
            ],
          ),
        ),
      );
    }

    if (!isLoading) return const SizedBox.shrink();

    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentBlue),
          ),
        ),
      ),
    );
  }
}

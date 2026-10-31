import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/shared_widgets/app_button.dart';

class AppRetryButton extends StatefulWidget {
  const AppRetryButton({
    super.key,
    required this.onRetry,
    this.label = 'Try Again',
    this.isCompact = false,
    this.isLoading = false,
  });

  final Future<void> Function()? onRetry;
  final String label;
  final bool isCompact;
  final bool isLoading;

  @override
  State<AppRetryButton> createState() => _AppRetryButtonState();
}

class _AppRetryButtonState extends State<AppRetryButton> {
  bool _internalLoading = false;

  bool get _effectiveLoading => widget.isLoading || _internalLoading;

  Future<void> _handleRetry() async {
    if (widget.onRetry == null || _effectiveLoading) return;
    setState(() => _internalLoading = true);
    try {
      await widget.onRetry!();
    } finally {
      if (mounted) {
        setState(() => _internalLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isCompact) {
      return OutlinedButton.icon(
        onPressed: _effectiveLoading ? null : _handleRetry,
        icon: _effectiveLoading
            ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.accentBlue,
                  ),
                ),
              )
            : const Icon(Icons.refresh_rounded, size: 16),
        label: Text(
          widget.label,
          style: AppFonts.labelMedium(color: AppColors.accentBlue),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          side: const BorderSide(color: AppColors.accentBlue, width: 1.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }

    return AppButton(
      label: widget.label,
      onPressed: widget.onRetry == null ? null : _handleRetry,
      isLoading: _effectiveLoading,
      icon: const Icon(Icons.refresh_rounded, size: 18),
      variant: AppButtonVariant.primary,
    );
  }
}


import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/shared_widgets/app_button.dart';
import 'package:garage_card/core/shared_widgets/app_text_field.dart';
import 'package:garage_card/features/shared/models/service_job_model.dart';

class GatePassVerificationDialog extends StatefulWidget {
  const GatePassVerificationDialog({
    super.key,
    required this.job,
    required this.onVerify,
  });

  final ServiceJobModel job;
  final Future<bool> Function(String otp) onVerify;

  @override
  State<GatePassVerificationDialog> createState() =>
      _GatePassVerificationDialogState();
}

class _GatePassVerificationDialogState
    extends State<GatePassVerificationDialog> {
  final _otpCtrl = TextEditingController();
  bool _isVerifying = false;
  String? _error;
  bool _isSuccess = false;

  @override
  void dispose() {
    _otpCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleVerify() async {
    final code = _otpCtrl.text.trim();
    if (code.length != 6) {
      setState(() => _error = 'Enter full 6-digit delivery OTP');
      return;
    }

    setState(() {
      _isVerifying = true;
      _error = null;
    });

    final success = await widget.onVerify(code);
    if (!mounted) return;

    if (success) {
      setState(() {
        _isVerifying = false;
        _isSuccess = true;
      });
      await Future.delayed(const Duration(milliseconds: 1200));
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } else {
      setState(() {
        _isVerifying = false;
        _error = 'Invalid OTP code. Please check with customer.';
      });
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
    final dialogBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Dialog(
      backgroundColor: dialogBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: borderColor),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.accentBlue.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.security_rounded,
                            color: AppColors.accentBlue,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            'Gate Pass Verification',
                            style: AppFonts.titleMedium(color: primaryTextColor)
                                .copyWith(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.backgroundDark
                      : AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.job.vehicleDisplay,
                      style: AppFonts.titleSmall(color: primaryTextColor)
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Job: ${widget.job.jobNumber} • Customer: ${widget.job.customerName}',
                      style: AppFonts.labelSmall(color: secondaryTextColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (_isSuccess) ...[
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.success,
                        size: 54,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Delivery Authorized!',
                        style: AppFonts.titleMedium(color: AppColors.success)
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Vehicle marked completed & released at exit gate.',
                        style: AppFonts.bodySmall(color: secondaryTextColor),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Text(
                  'Enter Customer\'s 6-Digit Gate OTP',
                  style: AppFonts.labelSmall(color: secondaryTextColor)
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                AppTextField(
                  controller: _otpCtrl,
                  hint: 'e.g. 482910',
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.pin_rounded, size: 20),
                  errorText: _error,
                  onChanged: (val) {
                    if (_error != null) setState(() => _error = null);
                    if (val.trim().length == 6) {
                      _handleVerify();
                    }
                  },
                ),
                const SizedBox(height: 20),
                AppButton(
                  label: _isVerifying
                      ? 'Verifying OTP...'
                      : 'Authorize & Release Vehicle',
                  icon: _isVerifying
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.verified_user_rounded, size: 18),
                  variant: AppButtonVariant.primary,
                  onPressed: _isVerifying ? null : _handleVerify,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

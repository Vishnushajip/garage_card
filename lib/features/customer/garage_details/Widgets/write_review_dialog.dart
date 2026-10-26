import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/shared_widgets/app_button.dart';
import 'package:garage_card/core/shared_widgets/app_text_field.dart';
import 'package:garage_card/core/shared_widgets/app_whatsapp_button.dart';

class WriteReviewDialog extends StatefulWidget {
  const WriteReviewDialog({
    super.key,
    required this.garageName,
    this.garagePhone,
    this.jobId,
    required this.onSubmit,
  });

  final String garageName;
  final String? garagePhone;
  final String? jobId;
  final Future<bool> Function({
    required double rating,
    required String reviewText,
    required bool consentSharePhoto,
    required bool consentShareName,
    String? photoUrl,
  })
  onSubmit;

  static Future<bool?> show(
    BuildContext context, {
    required String garageName,
    String? garagePhone,
    String? jobId,
    required Future<bool> Function({
      required double rating,
      required String reviewText,
      required bool consentSharePhoto,
      required bool consentShareName,
      String? photoUrl,
    })
    onSubmit,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => WriteReviewDialog(
        garageName: garageName,
        garagePhone: garagePhone,
        jobId: jobId,
        onSubmit: onSubmit,
      ),
    );
  }

  @override
  State<WriteReviewDialog> createState() => _WriteReviewDialogState();
}

class _WriteReviewDialogState extends State<WriteReviewDialog> {
  final _commentController = TextEditingController();
  final _photoUrlController = TextEditingController();
  double _rating = 5.0;
  bool _consentName = true;
  bool _consentPhoto = false;
  bool _isSubmitting = false;
  String _selectedLang = 'en';
  String? _error;

  @override
  void dispose() {
    _commentController.disposeSpaces();
    _photoUrlController.disposeSpaces();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryText = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final surfaceColor = isDark
        ? AppColors.surfaceDark
        : AppColors.surfaceLight;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: surfaceColor,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rate & Review',
                            style: AppFonts.headlineSmall(color: primaryText),
                          ),
                          Text(
                            widget.garageName,
                            style: AppFonts.bodySmall(color: secondaryText),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: _isSubmitting
                          ? null
                          : () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starValue = index + 1.0;
                      return IconButton(
                        iconSize: 36,
                        icon: Icon(
                          _rating >= starValue
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: AppColors.primaryAmber,
                        ),
                        onPressed: _isSubmitting
                            ? null
                            : () => setState(() => _rating = starValue),
                      );
                    }),
                  ),
                ),
                Center(
                  child: Text(
                    '${_rating.toInt()} / 5 Stars',
                    style: AppFonts.titleMedium(color: AppColors.primaryAmber),
                  ),
                ),
                const SizedBox(height: 20),
                AppTextField(
                  controller: _commentController,
                  label: 'Your Review & Feedback',
                  hint: 'Describe your service experience, punctuality, and staff behaviour...',
                  maxLines: 3,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _photoUrlController,
                  label: 'Optional Photo Link',
                  hint: 'https://...',
                  prefixIcon: const Icon(Icons.image_outlined),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : AppColors.cardLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Privacy & Display Consent',
                        style: AppFonts.labelLarge(color: primaryText),
                      ),
                      const SizedBox(height: 10),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'Display my name publicly',
                          style: AppFonts.bodyMedium(color: primaryText),
                        ),
                        subtitle: Text(
                          _consentName
                              ? 'Your name will be visible to everyone.'
                              : 'Shown as "Verified Customer" for privacy.',
                          style: AppFonts.bodySmall(color: secondaryText),
                        ),
                        value: _consentName,
                        activeColor: AppColors.primaryRed,
                        onChanged: _isSubmitting
                            ? null
                            : (val) => setState(() => _consentName = val),
                      ),
                      const Divider(height: 16),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'Display my photo publicly',
                          style: AppFonts.bodyMedium(color: primaryText),
                        ),
                        subtitle: Text(
                          _consentPhoto
                              ? 'Your profile/vehicle photo will appear with review.'
                              : 'Photo is completely hidden from public display.',
                          style: AppFonts.bodySmall(color: secondaryText),
                        ),
                        value: _consentPhoto,
                        activeColor: AppColors.primaryRed,
                        onChanged: _isSubmitting
                            ? null
                            : (val) => setState(() => _consentPhoto = val),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.successBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Send Direct via WhatsApp',
                            style: AppFonts.labelMedium(
                              color: AppColors.primaryDark,
                            ).copyWith(fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              ChoiceChip(
                                label: const Text('EN'),
                                selected: _selectedLang == 'en',
                                onSelected: (s) {
                                  if (s) setState(() => _selectedLang = 'en');
                                },
                              ),
                              const SizedBox(width: 4),
                              ChoiceChip(
                                label: const Text('മല'),
                                selected: _selectedLang == 'ml',
                                onSelected: (s) {
                                  if (s) setState(() => _selectedLang = 'ml');
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      AppWhatsAppButton(
                        phoneNumber: widget.garagePhone ?? '+919846012345',
                        label: _selectedLang == 'ml'
                            ? 'റിവ്യൂ വാട്സാപ്പിൽ അയക്കുക'
                            : 'Send Review via WhatsApp',
                        variant: WhatsAppButtonVariant.outline,
                        isFullWidth: true,
                        message: _selectedLang == 'ml'
                            ? 'നമസ്കാരം ${widget.garageName}, WeFix-ലെ എന്റെ സർവീസ് റിവ്യൂ:\nറേറ്റിംഗ്: ${_rating.toInt()}/5 സ്റ്റാർ\nഅഭിപ്രായം: ${_commentController.text.trim().isNotEmpty ? _commentController.text.trim() : 'നല്ല സർവീസ്!'}'
                            : 'Hello ${widget.garageName}, here is my service review on WeFix:\nRating: ${_rating.toInt()}/5 Stars\nFeedback: ${_commentController.text.trim().isNotEmpty ? _commentController.text.trim() : 'Great service!'}',
                      ),
                    ],
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: AppFonts.bodySmall(color: AppColors.primaryRed),
                  ),
                ],
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: _isSubmitting
                            ? null
                            : () => Navigator.pop(context),
                        child: Text(
                          'Cancel',
                          style: AppFonts.labelLarge(color: secondaryText),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: AppButton(
                        label: 'Submit Review',
                        isLoading: _isSubmitting,
                        onPressed: () async {
                          if (_commentController.text.trim().isEmpty) {
                            setState(
                              () =>
                                  _error = 'Please enter your review comments.',
                            );
                            return;
                          }
                          setState(() {
                            _isSubmitting = true;
                            _error = null;
                          });
                          final nav = Navigator.of(context);
                          final ok = await widget.onSubmit(
                            rating: _rating,
                            reviewText: _commentController.text.trim(),
                            consentShareName: _consentName,
                            consentSharePhoto: _consentPhoto,
                            photoUrl: _photoUrlController.text.trim().isNotEmpty
                                ? _photoUrlController.text.trim()
                                : null,
                          );
                          if (!mounted) return;
                          if (ok) {
                            nav.pop(true);
                          } else {
                            setState(() {
                              _isSubmitting = false;
                              _error =
                                  'Failed to submit review. Please try again.';
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

extension on TextEditingController {
  void disposeSpaces() {
    dispose();
  }
}

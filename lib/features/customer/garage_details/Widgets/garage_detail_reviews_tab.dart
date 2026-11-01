import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/formatting/date_formatter.dart';
import 'package:garage_card/core/shared_widgets/app_button.dart';
import 'package:garage_card/core/shared_widgets/app_empty_state.dart';
import 'package:garage_card/core/shared_widgets/app_refresh.dart';
import 'package:garage_card/features/shared/models/garage_model.dart';
import 'package:garage_card/features/shared/models/review_model.dart';

import '../Model/customer_garage_detail_state.dart';
import '../ViewModel/customer_garage_detail_view_model.dart';
import 'write_review_dialog.dart';

class GarageDetailReviewsTab extends StatelessWidget {
  const GarageDetailReviewsTab({
    super.key,
    required this.garageId,
    required this.state,
    required this.vm,
    required this.garage,
  });

  final String garageId;
  final CustomerGarageDetailState state;
  final CustomerGarageDetailViewModel vm;
  final GarageModel garage;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryText = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return AppRefresh(
      onRefresh: () => vm.loadGarage(garageId),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.cardLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: Row(
              children: [
                Column(
                  children: [
                    Text(
                      garage.rating.toStringAsFixed(1),
                      style: AppFonts.displaySmall(
                        color: AppColors.primaryAmber,
                      ),
                    ),
                    Row(
                      children: List.generate(
                        5,
                        (i) => const Icon(
                          Icons.star_rounded,
                          size: 16,
                          color: AppColors.primaryAmber,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${garage.reviewCount} total reviews',
                      style: AppFonts.labelSmall(color: secondaryText),
                    ),
                  ],
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: AppButton(
                    label: 'Write a Review',
                    icon: const Icon(Icons.rate_review_outlined, size: 18),
                    onPressed: () => WriteReviewDialog.show(
                      context,
                      garageName: garage.name,
                      garagePhone: garage.phone,
                      onSubmit: vm.submitReview,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Verified Customer Reviews',
            style: AppFonts.titleMedium(color: primaryText),
          ),
          const SizedBox(height: 12),
          if (state.reviews.isEmpty)
            const AppEmptyState(
              title: 'No Reviews Yet',
              message: 'Be the first to rate your service experience at this garage!',
              icon: Icons.star_border_rounded,
            )
          else
            ...state.reviews.map((r) => GarageDetailReviewItem(review: r)),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class GarageDetailReviewItem extends StatelessWidget {
  const GarageDetailReviewItem({super.key, required this.review});

  final ReviewModel review;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryText = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    final publicPhoto = review.publicPhotoUrl;
    final publicReviewImage = review.publicReviewImageUrl;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primaryRed.withValues(alpha: 0.1),
                  backgroundImage: publicPhoto != null
                      ? NetworkImage(publicPhoto)
                      : null,
                  child: publicPhoto == null
                      ? Text(
                          review.displayCustomerName.isNotEmpty
                              ? review.displayCustomerName[0].toUpperCase()
                              : 'C',
                          style: AppFonts.labelMedium(
                            color: AppColors.primaryRed,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.displayCustomerName,
                        style: AppFonts.titleSmall(color: primaryText),
                      ),
                      if (review.createdAt != null)
                        Text(
                          DateFormatter.formatDateTime(review.createdAt!),
                          style: AppFonts.bodySmall(color: secondaryText),
                        ),
                    ],
                  ),
                ),
                Row(
                  children: List.generate(
                    5,
                    (i) => Icon(
                      i < review.rating.round()
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      size: 16,
                      color: AppColors.primaryAmber,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              review.reviewText,
              style: AppFonts.bodyMedium(color: primaryText),
            ),
            if (publicReviewImage != null) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  publicReviewImage,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.shrink(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';

import 'app_notification_model.dart';

class AppNotificationToast extends StatefulWidget {
  const AppNotificationToast({
    super.key,
    required this.item,
    required this.onDismiss,
  });

  final AppNotificationItem item;
  final VoidCallback onDismiss;

  @override
  State<AppNotificationToast> createState() => _AppNotificationToastState();
}

class _AppNotificationToastState extends State<AppNotificationToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.35),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleDismiss() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  Color _accentColor(AppNotificationType type) {
    switch (type) {
      case AppNotificationType.success:
        return AppColors.primaryGreen;
      case AppNotificationType.error:
        return AppColors.primaryRed;
      case AppNotificationType.warning:
        return AppColors.primaryAmber;
      case AppNotificationType.info:
        return AppColors.accentBlue;
      case AppNotificationType.loading:
        return AppColors.accentBlue;
    }
  }

  Widget _buildIcon(AppNotificationType type, Color accent) {
    switch (type) {
      case AppNotificationType.success:
        return Icon(Icons.check_circle_rounded, color: accent, size: 22);
      case AppNotificationType.error:
        return Icon(Icons.error_outline_rounded, color: accent, size: 22);
      case AppNotificationType.warning:
        return Icon(Icons.warning_amber_rounded, color: accent, size: 22);
      case AppNotificationType.info:
        return Icon(Icons.info_outline_rounded, color: accent, size: 22);
      case AppNotificationType.loading:
        return SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2.2,
            value: widget.item.progress,
            color: accent,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = _accentColor(widget.item.type);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return Material(
      color: Colors.transparent,
      type: MaterialType.transparency,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Dismissible(
            key: Key(widget.item.id),
            direction: DismissDirection.up,
            onDismissed: (_) => widget.onDismiss(),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              constraints: const BoxConstraints(maxWidth: 440),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: accent.withValues(alpha: isDark ? 0.45 : 0.25),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: _buildIcon(widget.item.type, accent),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (widget.item.title != null &&
                                    widget.item.title!.isNotEmpty) ...[
                                  Text(
                                    widget.item.title!,
                                    style:
                                        AppFonts.labelMedium(
                                          color: primaryTextColor,
                                        ).copyWith(
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.none,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                ],
                                Text(
                                  widget.item.message,
                                  style:
                                      AppFonts.bodySmall(
                                        color: widget.item.title != null
                                            ? secondaryTextColor
                                            : primaryTextColor,
                                      ).copyWith(
                                        fontWeight: FontWeight.w500,
                                        decoration: TextDecoration.none,
                                      ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (widget.item.actionLabel != null &&
                                    widget.item.onAction != null) ...[
                                  const SizedBox(height: 8),
                                  InkWell(
                                    onTap: () {
                                      widget.item.onAction!();
                                      _handleDismiss();
                                    },
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: accent.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        widget.item.actionLabel!,
                                        style:
                                            AppFonts.labelSmall(
                                              color: accent,
                                            ).copyWith(
                                              fontWeight: FontWeight.bold,
                                              decoration: TextDecoration.none,
                                            ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (widget.item.isDismissible &&
                              widget.item.type != AppNotificationType.loading)
                            IconButton(
                              icon: const Icon(Icons.close_rounded, size: 18),
                              color: secondaryTextColor.withValues(alpha: 0.7),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 28,
                                minHeight: 28,
                              ),
                              onPressed: _handleDismiss,
                            ),
                        ],
                      ),
                    ),
                    if (widget.item.progress != null &&
                        widget.item.type == AppNotificationType.loading)
                      LinearProgressIndicator(
                        value: widget.item.progress,
                        minHeight: 2.5,
                        backgroundColor: accent.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(accent),
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

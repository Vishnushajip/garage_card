import 'package:flutter/material.dart';

enum AppNotificationType { success, error, warning, info, loading }

class AppNotificationItem {
  const AppNotificationItem({
    required this.id,
    required this.message,
    this.title,
    required this.type,
    this.duration = const Duration(seconds: 4),
    this.actionLabel,
    this.onAction,
    this.progress,
    this.isDismissible = true,
    required this.createdAt,
  });

  final String id;
  final String message;
  final String? title;
  final AppNotificationType type;
  final Duration? duration;
  final String? actionLabel;
  final VoidCallback? onAction;
  final double? progress;
  final bool isDismissible;
  final DateTime createdAt;

  AppNotificationItem copyWith({
    String? id,
    String? message,
    String? title,
    AppNotificationType? type,
    Duration? duration,
    String? actionLabel,
    VoidCallback? onAction,
    double? progress,
    bool? isDismissible,
    DateTime? createdAt,
  }) {
    return AppNotificationItem(
      id: id ?? this.id,
      message: message ?? this.message,
      title: title ?? this.title,
      type: type ?? this.type,
      duration: duration ?? this.duration,
      actionLabel: actionLabel ?? this.actionLabel,
      onAction: onAction ?? this.onAction,
      progress: progress ?? this.progress,
      isDismissible: isDismissible ?? this.isDismissible,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

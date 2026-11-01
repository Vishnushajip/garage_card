import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_notification_model.dart';

class AppNotificationNotifier extends Notifier<List<AppNotificationItem>> {
  final Map<String, Timer> _dismissTimers = {};

  @override
  List<AppNotificationItem> build() {
    ref.onDispose(() {
      for (final timer in _dismissTimers.values) {
        timer.cancel();
      }
      _dismissTimers.clear();
    });
    return [];
  }

  String show({
    required String message,
    String? title,
    required AppNotificationType type,
    Duration? duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onAction,
    double? progress,
    bool isDismissible = true,
  }) {
    final id = 'notif_${DateTime.now().microsecondsSinceEpoch}';
    final effectiveDuration = type == AppNotificationType.loading
        ? null
        : duration;

    final item = AppNotificationItem(
      id: id,
      message: message,
      title: title,
      type: type,
      duration: effectiveDuration,
      actionLabel: actionLabel,
      onAction: onAction,
      progress: progress,
      isDismissible: isDismissible,
      createdAt: DateTime.now(),
    );

    final current = List<AppNotificationItem>.from(state);
    if (current.length >= 3) {
      final removed = current.removeAt(0);
      _dismissTimers[removed.id]?.cancel();
      _dismissTimers.remove(removed.id);
    }
    current.add(item);
    state = current;

    if (effectiveDuration != null) {
      _dismissTimers[id]?.cancel();
      _dismissTimers[id] = Timer(effectiveDuration, () {
        dismiss(id);
      });
    }

    return id;
  }

  void update(
    String id, {
    String? message,
    String? title,
    AppNotificationType? type,
    Duration? duration = const Duration(seconds: 4),
    double? progress,
  }) {
    final index = state.indexWhere((n) => n.id == id);
    if (index == -1) return;

    final current = state[index];
    final updatedType = type ?? current.type;
    final effectiveDuration = updatedType == AppNotificationType.loading
        ? null
        : duration;

    final updated = current.copyWith(
      message: message ?? current.message,
      title: title ?? current.title,
      type: updatedType,
      duration: effectiveDuration,
      progress: progress ?? current.progress,
    );

    final list = List<AppNotificationItem>.from(state);
    list[index] = updated;
    state = list;

    _dismissTimers[id]?.cancel();
    _dismissTimers.remove(id);

    if (effectiveDuration != null) {
      _dismissTimers[id] = Timer(effectiveDuration, () {
        dismiss(id);
      });
    }
  }

  void dismiss(String id) {
    _dismissTimers[id]?.cancel();
    _dismissTimers.remove(id);
    state = state.where((n) => n.id != id).toList();
  }

  void dismissAll() {
    for (final timer in _dismissTimers.values) {
      timer.cancel();
    }
    _dismissTimers.clear();
    state = [];
  }
}

final appNotificationListProvider =
    NotifierProvider<AppNotificationNotifier, List<AppNotificationItem>>(
      AppNotificationNotifier.new,
    );

class AppNotificationService {
  AppNotificationService._();
  static final AppNotificationService instance = AppNotificationService._();

  static AppNotificationNotifier? _notifier;

  static void setNotifier(AppNotificationNotifier notifier) {
    _notifier = notifier;
  }

  static String show({
    BuildContext? context,
    required String message,
    String? title,
    required AppNotificationType type,
    Duration? duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onAction,
    double? progress,
  }) {
    if (_notifier != null) {
      return _notifier!.show(
        message: message,
        title: title,
        type: type,
        duration: duration,
        actionLabel: actionLabel,
        onAction: onAction,
        progress: progress,
      );
    }
    return '';
  }

  static String success(
    String message, {
    BuildContext? context,
    String? title,
    Duration? duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return show(
      context: context,
      message: message,
      title: title,
      type: AppNotificationType.success,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static String error(
    String message, {
    BuildContext? context,
    String? title,
    Duration? duration = const Duration(seconds: 5),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return show(
      context: context,
      message: message,
      title: title,
      type: AppNotificationType.error,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static String warning(
    String message, {
    BuildContext? context,
    String? title,
    Duration? duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return show(
      context: context,
      message: message,
      title: title,
      type: AppNotificationType.warning,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static String info(
    String message, {
    BuildContext? context,
    String? title,
    Duration? duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return show(
      context: context,
      message: message,
      title: title,
      type: AppNotificationType.info,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static String loading(
    String message, {
    BuildContext? context,
    String? title,
    double? progress,
  }) {
    return show(
      context: context,
      message: message,
      title: title,
      type: AppNotificationType.loading,
      progress: progress,
      duration: null,
    );
  }

  static void update(
    String id, {
    String? message,
    String? title,
    AppNotificationType? type,
    Duration? duration = const Duration(seconds: 4),
    double? progress,
  }) {
    _notifier?.update(
      id,
      message: message,
      title: title,
      type: type,
      duration: duration,
      progress: progress,
    );
  }

  static void dismiss(String id) {
    _notifier?.dismiss(id);
  }

  static void dismissAll() {
    _notifier?.dismissAll();
  }
}

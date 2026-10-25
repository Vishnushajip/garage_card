import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/routing/app_router.dart';
import 'foreground_notification_banner.dart';
import 'push_notification_service.dart';

class AppNotificationHost extends ConsumerStatefulWidget {
  const AppNotificationHost({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  ConsumerState<AppNotificationHost> createState() =>
      _AppNotificationHostState();
}

class _AppNotificationHostState extends ConsumerState<AppNotificationHost> {
  StreamSubscription<RemoteMessage>? _messageSub;
  StreamSubscription<String>? _deepLinkSub;
  RemoteMessage? _activeForegroundMessage;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initNotifications();
    });
  }

  void _initNotifications() {
    final service = ref.read(pushNotificationServiceProvider);
    service.initialize();

    _deepLinkSub = service.onDeepLink.listen((path) {
      if (mounted && path.isNotEmpty) {
        ref.read(appRouterProvider).go(path);
      }
    });

    _messageSub = service.onForegroundMessage.listen((message) {
      if (mounted) {
        setState(() {
          _activeForegroundMessage = message;
        });
        _dismissTimer?.cancel();
        _dismissTimer = Timer(const Duration(seconds: 6), () {
          if (mounted) {
            setState(() {
              _activeForegroundMessage = null;
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _messageSub?.cancel();
    _deepLinkSub?.cancel();
    _dismissTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeMsg = _activeForegroundMessage;

    return Stack(
      children: [
        widget.child,
        if (activeMsg != null)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ForegroundNotificationBanner(
              title: activeMsg.notification?.title ??
                  activeMsg.data['title'] ??
                  'Garage Alert',
              body: activeMsg.notification?.body ??
                  activeMsg.data['body'] ??
                  '',
              imageUrl: activeMsg.notification?.android?.imageUrl ??
                  activeMsg.notification?.apple?.imageUrl ??
                  activeMsg.data['imageUrl'] as String?,
              onTap: () {
                final deepLink = activeMsg.data['deepLink'] as String? ?? '/';
                setState(() {
                  _activeForegroundMessage = null;
                });
                _dismissTimer?.cancel();
                ref.read(appRouterProvider).go(deepLink);
              },
              onDismiss: () {
                setState(() {
                  _activeForegroundMessage = null;
                });
                _dismissTimer?.cancel();
              },
            ),
          ),
      ],
    );
  }
}

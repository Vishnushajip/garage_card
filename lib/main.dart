import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/firebase/firebase_config.dart';
import 'core/notifications/push_notification_service.dart';
import 'core/routing/app_url_strategy.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureAppUrlStrategy();
  await FirebaseConfig.initialize();
  if (!kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }
  runApp(
    const ProviderScope(
      child: GarageCardApp(),
    ),
  );
}

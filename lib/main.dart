import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/routing/app_url_strategy.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureAppUrlStrategy();
  runApp(
    const ProviderScope(
      child: GarageCardApp(),
    ),
  );
}

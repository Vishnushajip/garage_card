import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../firebase_options.dart';

class FirebaseConfig {
  FirebaseConfig._();

  static bool _isInitialized = false;

  static bool get isInitialized => _isInitialized;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
      _isInitialized = true;
    } catch (_) {
      try {
        if (Firebase.apps.isNotEmpty) {
          _isInitialized = true;
        }
      } catch (_) {}
    }
  }
}

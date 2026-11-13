import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../firebase_options.dart';

class FirebaseConfig {
  FirebaseConfig._();

  static bool _isInitialized = false;
  static bool _isFirestoreDatabaseReady = true;

  static bool get isInitialized => _isInitialized;
  static bool get isFirestoreDatabaseReady => _isFirestoreDatabaseReady;

  static void markFirestoreUnavailable() {
    _isFirestoreDatabaseReady = false;
  }

  static void markFirestoreAvailable() {
    _isFirestoreDatabaseReady = true;
  }

  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      if (kIsWeb) {
        try {
          await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
        } catch (_) {}
        FirebaseFirestore.instance.settings = const Settings(
          persistenceEnabled: true,
          webExperimentalForceLongPolling: true,
          ignoreUndefinedProperties: true,
        );
      } else {
        FirebaseFirestore.instance.settings = const Settings(
          persistenceEnabled: true,
          cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
        );
      }
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

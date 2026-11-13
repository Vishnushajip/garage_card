import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static FirebaseOptions get web {
    var domain = 'garage-b7ed1.firebaseapp.com';
    if (kIsWeb) {
      final host = Uri.base.host;
      if (host.isNotEmpty &&
          !host.contains('localhost') &&
          !host.contains('127.0.0.1')) {
        domain = host;
      }
    }
    return FirebaseOptions(
      apiKey: 'AIzaSyD1LMs5Rzha-BIrg2982MG_Hf88sRFLa-I',
      appId: '1:62265849009:web:de72a4084ed3b138621e90',
      messagingSenderId: '62265849009',
      projectId: 'garage-b7ed1',
      authDomain: domain,
      storageBucket: 'garage-b7ed1.firebasestorage.app',
      measurementId: 'G-B9QQTW2D4C',
    );
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAD9PjSN7lU28SkjJYI9cZqSLt4JS5OOY8',
    appId: '1:62265849009:android:f4ad5b2e0f39b3a3621e90',
    messagingSenderId: '62265849009',
    projectId: 'garage-b7ed1',
    storageBucket: 'garage-b7ed1.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB_4yjE3Xy05h8LPeUy24vA25S2qSgVDp8',
    appId: '1:62265849009:ios:a58a147ffaec6bd8621e90',
    messagingSenderId: '62265849009',
    projectId: 'garage-b7ed1',
    storageBucket: 'garage-b7ed1.firebasestorage.app',
    androidClientId: '62265849009-c17p7h4nupkpq25v6440ktqs38mjm0sa.apps.googleusercontent.com',
    iosClientId: '62265849009-and7c7421at747pp67c6v3qpvmpo2sk0.apps.googleusercontent.com',
    iosBundleId: 'com.example.garageCard',
  );
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB_4yjE3Xy05h8LPeUy24vA25S2qSgVDp8',
    appId: '1:62265849009:ios:a58a147ffaec6bd8621e90',
    messagingSenderId: '62265849009',
    projectId: 'garage-b7ed1',
    storageBucket: 'garage-b7ed1.firebasestorage.app',
    androidClientId: '62265849009-c17p7h4nupkpq25v6440ktqs38mjm0sa.apps.googleusercontent.com',
    iosClientId: '62265849009-and7c7421at747pp67c6v3qpvmpo2sk0.apps.googleusercontent.com',
    iosBundleId: 'com.example.garageCard',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyD1LMs5Rzha-BIrg2982MG_Hf88sRFLa-I',
    appId: '1:62265849009:web:6fb0e1a353236d13621e90',
    messagingSenderId: '62265849009',
    projectId: 'garage-b7ed1',
    authDomain: 'garage-b7ed1.firebaseapp.com',
    storageBucket: 'garage-b7ed1.firebasestorage.app',
    measurementId: 'G-5M35SLLWL2',
  );
}

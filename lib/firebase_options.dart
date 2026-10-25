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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD1LMs5Rzha-BIrg2982MG_Hf88sRFLa-I',
    appId: '1:62265849009:web:de72a4084ed3b138621e90',
    messagingSenderId: '62265849009',
    projectId: 'garage-b7ed1',
    authDomain: 'garage-b7ed1.firebaseapp.com',
    storageBucket: 'garage-b7ed1.firebasestorage.app',
    measurementId: 'G-B9QQTW2D4C',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAD9PjSN7lU28SkjJYI9cZqSLt4JS5OOY8',
    appId: '1:62265849009:android:f4ad5b2e0f39b3a3621e90',
    messagingSenderId: '62265849009',
    projectId: 'garage-b7ed1',
    storageBucket: 'garage-b7ed1.firebasestorage.app',
  );
}

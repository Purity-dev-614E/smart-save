// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBUT_zXCk_5I7vpniHE4uoUazlJ7cspjZY',
    appId: '1:573789924828:web:18ec6e6b70cfd74a927319',
    messagingSenderId: '573789924828',
    projectId: 'smart-save-702ed',
    authDomain: 'smart-save-702ed.firebaseapp.com',
    storageBucket: 'smart-save-702ed.firebasestorage.app',
    measurementId: 'G-41WC3WGL4W',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBOVcIZJ-bMxpFr88ACsQEF85-H1OxstOY',
    appId: '1:573789924828:android:e03a9407436f341f927319',
    messagingSenderId: '573789924828',
    projectId: 'smart-save-702ed',
    storageBucket: 'smart-save-702ed.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCBkyEF3ueauEZagob9IVjQrYoIMfK90-w',
    appId: '1:573789924828:ios:c269ce3b472cdf75927319',
    messagingSenderId: '573789924828',
    projectId: 'smart-save-702ed',
    storageBucket: 'smart-save-702ed.firebasestorage.app',
    iosBundleId: 'com.example.smartSave',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCBkyEF3ueauEZagob9IVjQrYoIMfK90-w',
    appId: '1:573789924828:ios:c269ce3b472cdf75927319',
    messagingSenderId: '573789924828',
    projectId: 'smart-save-702ed',
    storageBucket: 'smart-save-702ed.firebasestorage.app',
    iosBundleId: 'com.example.smartSave',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBUT_zXCk_5I7vpniHE4uoUazlJ7cspjZY',
    appId: '1:573789924828:web:f1fb41b269bdd072927319',
    messagingSenderId: '573789924828',
    projectId: 'smart-save-702ed',
    authDomain: 'smart-save-702ed.firebaseapp.com',
    storageBucket: 'smart-save-702ed.firebasestorage.app',
    measurementId: 'G-DX8ZGNVEXV',
  );
}

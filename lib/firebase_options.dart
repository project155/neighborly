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
    apiKey: 'AIzaSyBA09_FXoG5qCeBwjVbvG7d0SWstCfpthQ',
    appId: '1:461357301086:web:4526ab265cf48d52faa3cf',
    messagingSenderId: '461357301086',
    projectId: 'nighbourly-94e10',
    authDomain: 'nighbourly-94e10.firebaseapp.com',
    storageBucket: 'nighbourly-94e10.firebasestorage.app',
    measurementId: 'G-1Y4T6TN0TV',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBpV_d9Tsb5LNDEe765qAF4-fC2Y4eFAT4',
    appId: '1:461357301086:android:598e3d6950c2110dfaa3cf',
    messagingSenderId: '461357301086',
    projectId: 'nighbourly-94e10',
    storageBucket: 'nighbourly-94e10.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCbRwXCmFLBi_u49-2PLXv_QTuRdYG4ecI',
    appId: '1:461357301086:ios:172f73d43e778d32faa3cf',
    messagingSenderId: '461357301086',
    projectId: 'nighbourly-94e10',
    storageBucket: 'nighbourly-94e10.firebasestorage.app',
    iosBundleId: 'com.example.neighborly',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCbRwXCmFLBi_u49-2PLXv_QTuRdYG4ecI',
    appId: '1:461357301086:ios:172f73d43e778d32faa3cf',
    messagingSenderId: '461357301086',
    projectId: 'nighbourly-94e10',
    storageBucket: 'nighbourly-94e10.firebasestorage.app',
    iosBundleId: 'com.example.neighborly',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBA09_FXoG5qCeBwjVbvG7d0SWstCfpthQ',
    appId: '1:461357301086:web:90bf2ef3e02126b8faa3cf',
    messagingSenderId: '461357301086',
    projectId: 'nighbourly-94e10',
    authDomain: 'nighbourly-94e10.firebaseapp.com',
    storageBucket: 'nighbourly-94e10.firebasestorage.app',
    measurementId: 'G-R6FMSP7J32',
  );
}

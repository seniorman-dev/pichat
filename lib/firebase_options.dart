// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
    apiKey: 'AIzaSyDcbELxknTNSO_EdAy26xNWgfB7bMCkiLo',
    appId: '1:930937927575:web:1a49d1c6ca207430fa76d2',
    messagingSenderId: '930937927575',
    projectId: 'pichat-247',
    authDomain: 'pichat-247.firebaseapp.com',
    storageBucket: 'pichat-247.appspot.com',
    measurementId: 'G-2KVD7JH2FP',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDHyqu5DHOpHnS3WHLiBny7o3R97zZ3dJU',
    appId: '1:930937927575:android:c8f1731de1ec8389fa76d2',
    messagingSenderId: '930937927575',
    projectId: 'pichat-247',
    storageBucket: 'pichat-247.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDKQOKTg2jg5TYTEVGCfOBhvIP2hw2aIIE',
    appId: '1:930937927575:ios:3aaa338723d3b64efa76d2',
    messagingSenderId: '930937927575',
    projectId: 'pichat-247',
    storageBucket: 'pichat-247.appspot.com',
    iosClientId: '930937927575-u0ounktde40kbhc2bl6eghde8c93mcqn.apps.googleusercontent.com',
    iosBundleId: 'com.example.pichat',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDKQOKTg2jg5TYTEVGCfOBhvIP2hw2aIIE',
    appId: '1:930937927575:ios:3aaa338723d3b64efa76d2',
    messagingSenderId: '930937927575',
    projectId: 'pichat-247',
    storageBucket: 'pichat-247.appspot.com',
    iosClientId: '930937927575-u0ounktde40kbhc2bl6eghde8c93mcqn.apps.googleusercontent.com',
    iosBundleId: 'com.example.pichat',
  );
}
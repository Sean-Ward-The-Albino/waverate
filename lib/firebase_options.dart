import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAQ7RN9CPJwzTBpXmlJ0-uCA4TI18bd5VM',
    appId: '1:517556513553:android:9817b74a83be8ee2b07ab0',
    messagingSenderId: '517556513553',
    projectId: 'waverate',
    storageBucket: 'waverate.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA1OLqwnQBZZmi7S53_LIye5R3TT1-Meho',
    appId: '1:517556513553:web:2cc730787e720e2fb07ab0',
    messagingSenderId: '517556513553',
    projectId: 'waverate',
    authDomain: 'waverate.firebaseapp.com',
    storageBucket: 'waverate.firebasestorage.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCRCFQWR_JdakBP6EAPeT1MXnfBDdiJFqc',
    appId: '1:517556513553:ios:0ed2922d6421fab1b07ab0',
    messagingSenderId: '517556513553',
    projectId: 'waverate',
    storageBucket: 'waverate.firebasestorage.app',
    iosBundleId: 'com.example.waverate',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCRCFQWR_JdakBP6EAPeT1MXnfBDdiJFqc',
    appId: '1:517556513553:ios:0ed2922d6421fab1b07ab0',
    messagingSenderId: '517556513553',
    projectId: 'waverate',
    storageBucket: 'waverate.firebasestorage.app',
    iosBundleId: 'com.example.waverate',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyA1OLqwnQBZZmi7S53_LIye5R3TT1-Meho',
    appId: '1:517556513553:web:58c042e98832ee5fb07ab0',
    messagingSenderId: '517556513553',
    projectId: 'waverate',
    authDomain: 'waverate.firebaseapp.com',
    storageBucket: 'waverate.firebasestorage.app',
  );
}

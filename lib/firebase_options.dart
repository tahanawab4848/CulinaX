// Run: dart pub global activate flutterfire_cli
// Then: flutterfire configure
// This file will be auto-generated. Placeholder values below allow compile;
// replace with your Firebase project config before production use.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.windows:
        return windows;
      default:
        return android;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAgWwYr6mg8uuip9oATgVQILrHjrjdhAzU',
    appId: '1:23058298757:android:7c4212478be4dabf7576ec',
    messagingSenderId: '23058298757',
    projectId: 'culinax-app',
    authDomain: 'culinax-app.firebaseapp.com',
    storageBucket: 'culinax-app.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAgWwYr6mg8uuip9oATgVQILrHjrjdhAzU',
    appId: '1:23058298757:android:7c4212478be4dabf7576ec',
    messagingSenderId: '23058298757',
    projectId: 'culinax-app',
    storageBucket: 'culinax-app.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAgWwYr6mg8uuip9oATgVQILrHjrjdhAzU',
    appId: '1:23058298757:android:7c4212478be4dabf7576ec',
    messagingSenderId: '23058298757',
    projectId: 'culinax-app',
    storageBucket: 'culinax-app.firebasestorage.app',
    iosBundleId: 'com.example.smartPantry',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAgWwYr6mg8uuip9oATgVQILrHjrjdhAzU',
    appId: '1:23058298757:android:7c4212478be4dabf7576ec',
    messagingSenderId: '23058298757',
    projectId: 'culinax-app',
    authDomain: 'culinax-app.firebaseapp.com',
    storageBucket: 'culinax-app.firebasestorage.app',
  );
}

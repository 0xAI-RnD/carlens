import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA64RLyEwjys3_4mQVT_a2rKKrQkYThCYY',
    appId: '1:293397550929:android:3e8f73caf76505a1576570',
    messagingSenderId: '293397550929',
    projectId: 'carlens-85357',
    storageBucket: 'carlens-85357.firebasestorage.app',
  );
}

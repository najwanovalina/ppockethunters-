
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAJXrM06cviUhjGoZLfBjk8VOiv2sldQDE',
    appId: '1:390975764047:web:7fb59eee45fff167b01c3a',
    messagingSenderId: '390975764047',
    projectId: 'project-pencatat-keuangan',
    authDomain: 'project-pencatat-keuangan.firebaseapp.com',
    storageBucket: 'project-pencatat-keuangan.firebasestorage.app',
    measurementId: 'G-V34G7KP9DE',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBRrs-khGe8gHaQUucJLOmsW1piqm_00BE',
    appId: '1:390975764047:android:36b1f8988de23efdb01c3a',
    messagingSenderId: '390975764047',
    projectId: 'project-pencatat-keuangan',
    storageBucket: 'project-pencatat-keuangan.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAcBj-EChjg74qoshnEBTpAs2OD46yTAPk',
    appId: '1:390975764047:ios:ff21640d549eaf1bb01c3a',
    messagingSenderId: '390975764047',
    projectId: 'project-pencatat-keuangan',
    storageBucket: 'project-pencatat-keuangan.firebasestorage.app',
    iosBundleId: 'com.example.flutterCatatanuang',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAcBj-EChjg74qoshnEBTpAs2OD46yTAPk',
    appId: '1:390975764047:ios:ff21640d549eaf1bb01c3a',
    messagingSenderId: '390975764047',
    projectId: 'project-pencatat-keuangan',
    storageBucket: 'project-pencatat-keuangan.firebasestorage.app',
    iosBundleId: 'com.example.flutterCatatanuang',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAJXrM06cviUhjGoZLfBjk8VOiv2sldQDE',
    appId: '1:390975764047:web:20a19b8f6794b447b01c3a',
    messagingSenderId: '390975764047',
    projectId: 'project-pencatat-keuangan',
    authDomain: 'project-pencatat-keuangan.firebaseapp.com',
    storageBucket: 'project-pencatat-keuangan.firebasestorage.app',
    measurementId: 'G-TG8VYD75Y6',
  );
}

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;

/// Plantilla de opciones de Firebase. `flutterfire configure` reemplaza este
/// archivo en el Paso 16. Los marcadores REEMPLAZAR permiten trabajar sin
/// Firebase mientras tanto (la app funciona en modo local).
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return android;
    }
    throw UnsupportedError('Wallet UNSAAC solo se distribuye para Android.');
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAqdsm_1oE_HABn6Ew6D1DpsHnBZkyKRnI',
    appId: '1:664747208936:android:26f9adc47a4a7e7d3d995d',
    messagingSenderId: '664747208936',
    projectId: 'wallet-unsaac-alain',
    storageBucket: 'wallet-unsaac-alain.firebasestorage.app',
  );
}

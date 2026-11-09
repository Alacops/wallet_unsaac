import 'package:flutter/material.dart';
import 'package:wallet_unsaac/app.dart';
import 'package:wallet_unsaac/core/config/firebase_bootstrap.dart';
import 'package:wallet_unsaac/core/theme/theme_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Reto 1: las preferencias se leen antes de runApp para que el primer frame
  // ya se dibuje con el tema correcto (sin parpadeo claro → oscuro).
  final themePreferences = await ThemePreferences.create();
  final firebaseStatus = await FirebaseBootstrap.initialize();
  runApp(
    WalletApp(
      firebaseStatus: firebaseStatus,
      themePreferences: themePreferences,
    ),
  );
}

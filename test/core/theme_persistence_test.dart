import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet_unsaac/core/theme/app_theme.dart';
import 'package:wallet_unsaac/core/theme/theme_cubit.dart';
import 'package:wallet_unsaac/core/theme/theme_preferences.dart';

/// Pruebas del Reto 1: el tema persiste entre sesiones.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<ThemePreferences> buildPreferences() => ThemePreferences.create();

  group('ThemePreferences', () {
    test('guarda y recupera el modo elegido', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final prefs = await buildPreferences();

      await prefs.saveMode(ThemeMode.dark);

      // Una nueva instancia simula reabrir la app: debe leer lo guardado.
      final reopened = await buildPreferences();
      expect(reopened.loadMode(), ThemeMode.dark);
    });

    test('sin valor guardado, el modo inicial es system', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final prefs = await buildPreferences();

      expect(prefs.loadMode(), ThemeMode.system);
    });

    test('un valor corrupto no rompe el arranque y cae en system', () async {
      SharedPreferences.setMockInitialValues(
        <String, Object>{'wallet.theme_mode': 'valor_invalido'},
      );
      final prefs = await buildPreferences();

      expect(prefs.loadMode(), ThemeMode.system);
    });

    test('themeModeFromName mapea nombres y descarta los desconocidos', () {
      expect(themeModeFromName('light'), ThemeMode.light);
      expect(themeModeFromName('dark'), ThemeMode.dark);
      expect(themeModeFromName('system'), ThemeMode.system);
      expect(themeModeFromName(null), ThemeMode.system);
      expect(themeModeFromName('otro'), ThemeMode.system);
    });
  });

  group('ThemeCubit', () {
    test('recupera el modo persistido como estado inicial', () async {
      SharedPreferences.setMockInitialValues(
        <String, Object>{'wallet.theme_mode': 'dark'},
      );
      final prefs = await buildPreferences();
      final cubit = ThemeCubit(prefs);

      expect(cubit.state.mode, ThemeMode.dark);
      await cubit.close();
    });

    test('toggle recorre claro → oscuro → sistema → claro y persiste',
        () async {
      SharedPreferences.setMockInitialValues(
        <String, Object>{'wallet.theme_mode': 'light'},
      );
      final prefs = await buildPreferences();
      final cubit = ThemeCubit(prefs);

      await cubit.toggle();
      expect(cubit.state.mode, ThemeMode.dark);
      await cubit.toggle();
      expect(cubit.state.mode, ThemeMode.system);
      await cubit.toggle();
      expect(cubit.state.mode, ThemeMode.light);

      // Lo último emitido también quedó persistido.
      final reopened = await buildPreferences();
      expect(reopened.loadMode(), ThemeMode.light);
      await cubit.close();
    });

    test('setSeedColor cambia y persiste el color semilla', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final prefs = await buildPreferences();
      final cubit = ThemeCubit(prefs);

      expect(cubit.state.seedColor, AppTheme.seed);

      const nuevo = Color(0xFF1565C0);
      await cubit.setSeedColor(nuevo);
      expect(cubit.state.seedColor, nuevo);

      final reopened = await buildPreferences();
      expect(reopened.loadSeedColor(), nuevo);
      await cubit.close();
    });
  });
}

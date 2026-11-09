import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet_unsaac/core/theme/app_theme.dart';

/// Almacenamiento del tema con `shared_preferences`.
///
/// Reto 1: separa la persistencia del Cubit para poder probarla de forma
/// aislada. La lectura es síncrona (se carga antes de `runApp`); la escritura
/// es asíncrona y se dispara después de cada `emit`.
class ThemePreferences {
  ThemePreferences(this._prefs);

  final SharedPreferences _prefs;

  static const String _modeKey = 'wallet.theme_mode';
  static const String _seedKey = 'wallet.seed_color';

  /// Crea la instancia leyendo las preferencias ya persistidas.
  static Future<ThemePreferences> create() async {
    final prefs = await SharedPreferences.getInstance();
    return ThemePreferences(prefs);
  }

  /// Recupera el modo guardado. Si no hay valor o está corrupto, devuelve
  /// `ThemeMode.system` sin lanzar excepción.
  ThemeMode loadMode() => themeModeFromName(_prefs.getString(_modeKey));

  Future<void> saveMode(ThemeMode mode) =>
      _prefs.setString(_modeKey, mode.name);

  /// Recupera el color semilla guardado o el granate institucional.
  Color loadSeedColor() {
    final value = _prefs.getInt(_seedKey);
    if (value == null) return AppTheme.seed;
    return Color(value);
  }

  Future<void> saveSeedColor(Color color) =>
      _prefs.setInt(_seedKey, color.toARGB32());
}

/// Convierte un nombre persistido en `ThemeMode`. Un valor desconocido o nulo
/// cae en `ThemeMode.system`.
ThemeMode themeModeFromName(String? name) => ThemeMode.values.firstWhere(
      (mode) => mode.name == name,
      orElse: () => ThemeMode.system,
    );

import 'package:flutter/material.dart';

/// Construye el tema Material 3 a partir de un color semilla.
///
/// Reto 4: el color semilla es un parámetro, de modo que toda la paleta
/// (primary, surface, onPrimary, …) se recalcula sin definir colores a mano.
abstract final class AppTheme {
  /// Granate institucional de la UNSAAC, color semilla por defecto.
  static const Color seed = Color(0xFF7A1F2B);

  /// Colores semilla que ofrece el selector del Reto 4.
  static const List<Color> seeds = [
    Color(0xFF7A1F2B), // Granate institucional
    Color(0xFF1565C0), // Azul
    Color(0xFF2E7D32), // Verde
    Color(0xFF6A1B9A), // Morado
    Color(0xFFEF6C00), // Naranja
  ];

  static ThemeData light(Color seedColor) =>
      _build(Brightness.light, seedColor);

  static ThemeData dark(Color seedColor) => _build(Brightness.dark, seedColor);

  static ThemeData _build(Brightness brightness, Color seedColor) {
    final scheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

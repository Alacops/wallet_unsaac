import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet_unsaac/core/theme/theme_preferences.dart';
import 'package:wallet_unsaac/core/theme/theme_state.dart';

/// Gobierna el tema de la aplicación.
///
/// Reto 1: el estado inicial se recupera de [ThemePreferences] y cada cambio
/// se guarda de inmediato (después de `emit`).
/// Reto 4: expone [setSeedColor] para cambiar el color semilla.
class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit(this._preferences)
      : super(
          ThemeState(
            mode: _preferences.loadMode(),
            seedColor: _preferences.loadSeedColor(),
          ),
        );

  final ThemePreferences _preferences;

  /// Recorre los modos en el orden claro → oscuro → sistema → claro.
  Future<void> toggle() {
    final next = switch (state.mode) {
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
      ThemeMode.system => ThemeMode.light,
    };
    return setMode(next);
  }

  Future<void> setMode(ThemeMode mode) async {
    emit(state.copyWith(mode: mode));
    await _preferences.saveMode(mode);
  }

  Future<void> useSystemMode() => setMode(ThemeMode.system);

  Future<void> setSeedColor(Color color) async {
    emit(state.copyWith(seedColor: color));
    await _preferences.saveSeedColor(color);
  }
}

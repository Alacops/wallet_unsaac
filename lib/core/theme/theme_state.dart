import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:wallet_unsaac/core/theme/app_theme.dart';

/// Estado inmutable del tema: modo claro/oscuro/sistema y color semilla.
///
/// Reto 4: `seedColor` se agrega a `props` para que participe en la igualdad
/// del estado.
class ThemeState extends Equatable {
  const ThemeState({
    this.mode = ThemeMode.system,
    this.seedColor = AppTheme.seed,
  });

  final ThemeMode mode;
  final Color seedColor;

  bool get isDark => mode == ThemeMode.dark;

  ThemeState copyWith({ThemeMode? mode, Color? seedColor}) => ThemeState(
        mode: mode ?? this.mode,
        seedColor: seedColor ?? this.seedColor,
      );

  @override
  List<Object?> get props => [mode, seedColor];
}

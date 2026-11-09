import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet_unsaac/core/theme/app_theme.dart';
import 'package:wallet_unsaac/core/theme/theme_cubit.dart';
import 'package:wallet_unsaac/core/theme/theme_preferences.dart';
import 'package:wallet_unsaac/features/wallet/presentation/widgets/seed_color_selector.dart';

/// Pruebas del Reto 4: color semilla configurable.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppTheme', () {
    test('el primary resultante coincide con ColorScheme.fromSeed', () {
      const seed = Color(0xFF1565C0);
      final theme = AppTheme.light(seed);
      final expected = ColorScheme.fromSeed(
        seedColor: seed,
        brightness: Brightness.light,
      );
      expect(theme.colorScheme.primary, expected.primary);
    });

    test('colores semilla distintos producen primary distintos', () {
      final granate = AppTheme.light(AppTheme.seed).colorScheme.primary;
      final azul = AppTheme.light(const Color(0xFF1565C0)).colorScheme.primary;
      expect(granate, isNot(azul));
    });

    test('ofrece al menos cuatro colores semilla', () {
      expect(AppTheme.seeds.length, greaterThanOrEqualTo(4));
    });
  });

  group('SeedColorSelector', () {
    testWidgets('tocar un color actualiza el color semilla del ThemeCubit',
        (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final prefs = await ThemePreferences.create();
      final cubit = ThemeCubit(prefs);

      await tester.pumpWidget(
        BlocProvider.value(
          value: cubit,
          child: const MaterialApp(
            home: Scaffold(body: SeedColorSelector()),
          ),
        ),
      );

      expect(cubit.state.seedColor, AppTheme.seed);

      // Toca el segundo punto de color de la lista.
      await tester.tap(find.byType(GestureDetector).at(1));
      await tester.pump();

      expect(cubit.state.seedColor, AppTheme.seeds[1]);
      await cubit.close();
    });
  });
}

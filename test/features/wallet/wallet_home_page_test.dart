import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet_unsaac/core/config/firebase_status.dart';
import 'package:wallet_unsaac/core/theme/app_theme.dart';
import 'package:wallet_unsaac/core/theme/theme_cubit.dart';
import 'package:wallet_unsaac/core/theme/theme_preferences.dart';
import 'package:wallet_unsaac/core/theme/theme_state.dart';
import 'package:wallet_unsaac/features/wallet/data/repositories/in_memory_wallet_repository.dart';
import 'package:wallet_unsaac/features/wallet/domain/entities/movement.dart';
import 'package:wallet_unsaac/features/wallet/domain/entities/wallet_summary.dart';
import 'package:wallet_unsaac/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:wallet_unsaac/features/wallet/presentation/blocs/movements/movements_bloc.dart';
import 'package:wallet_unsaac/features/wallet/presentation/blocs/movements/movements_event.dart';
import 'package:wallet_unsaac/features/wallet/presentation/cubits/privacy_cubit.dart';
import 'package:wallet_unsaac/features/wallet/presentation/pages/wallet_home_page.dart';

/// Repositorio que falla, para comprobar la vista de error.
class _FailingRepository implements WalletRepository {
  @override
  Future<WalletSummary> loadSummary() async => throw Exception('sin conexión');

  @override
  Future<WalletSummary> addMovement(Movement movement) async =>
      throw Exception('sin conexión');

  @override
  Future<WalletSummary> updateMovement(Movement movement) async =>
      throw Exception('sin conexión');

  @override
  Future<WalletSummary> removeMovement(String movementId) async =>
      throw Exception('sin conexión');

  @override
  Future<WalletSummary> clearMovements() async =>
      throw Exception('sin conexión');
}

Future<void> _pumpHome(
  WidgetTester tester, {
  WalletRepository? repository,
}) async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final prefs = await ThemePreferences.create();
  final repo =
      repository ?? InMemoryWalletRepository(latency: Duration.zero);

  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(create: (_) => ThemeCubit(prefs)),
        BlocProvider<PrivacyCubit>(create: (_) => PrivacyCubit()),
        BlocProvider<MovementsBloc>(
          create: (_) =>
              MovementsBloc(repository: repo)..add(const MovementsStarted()),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) => MaterialApp(
          theme: AppTheme.light(state.seedColor),
          darkTheme: AppTheme.dark(state.seedColor),
          themeMode: state.mode,
          home: const WalletHomePage(
            firebaseStatus: FirebaseStatus.notConfigured(),
          ),
        ),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('estado de éxito muestra el saldo y los movimientos',
      (tester) async {
    await _pumpHome(tester);
    await tester.pump(); // procesa el microtask de loadSummary → Success

    expect(find.text('S/ 1,274.60'), findsOneWidget);
    expect(find.text('Últimos movimientos'), findsOneWidget);

    // El primer movimiento queda bajo el viewport por la cabecera de identidad;
    // lo traemos a la vista antes de comprobarlo.
    await tester.scrollUntilVisible(
      find.text('Sueldo de prácticas'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Sueldo de prácticas'), findsOneWidget);
  });

  testWidgets('el botón de ojo oculta y muestra el saldo (Reto 2)',
      (tester) async {
    await _pumpHome(tester);
    await tester.pump();

    expect(find.text('S/ 1,274.60'), findsOneWidget);

    await tester.tap(find.byTooltip('Ocultar saldo'));
    await tester.pump();

    expect(find.text('S/ 1,274.60'), findsNothing);
    expect(find.byTooltip('Mostrar saldo'), findsOneWidget);
  });

  testWidgets('estado de error muestra mensaje y botón Reintentar (Reto 3)',
      (tester) async {
    await _pumpHome(tester, repository: _FailingRepository());
    await tester.pump();

    expect(
      find.text(MovementsBloc.loadFailureMessage),
      findsOneWidget,
    );
    expect(find.text('Reintentar'), findsOneWidget);
  });
}

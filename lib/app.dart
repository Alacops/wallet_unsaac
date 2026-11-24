import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet_unsaac/core/config/firebase_status.dart';
import 'package:wallet_unsaac/core/theme/app_theme.dart';
import 'package:wallet_unsaac/core/theme/theme_cubit.dart';
import 'package:wallet_unsaac/core/theme/theme_preferences.dart';
import 'package:wallet_unsaac/core/theme/theme_state.dart';
import 'package:wallet_unsaac/features/wallet/data/repositories/in_memory_wallet_repository.dart';
import 'package:wallet_unsaac/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:wallet_unsaac/features/wallet/presentation/blocs/movements/movements_bloc.dart';
import 'package:wallet_unsaac/features/wallet/presentation/blocs/movements/movements_event.dart';
import 'package:wallet_unsaac/features/wallet/presentation/cubits/privacy_cubit.dart';
import 'package:wallet_unsaac/features/wallet/presentation/pages/wallet_home_page.dart';

/// Raíz de la aplicación. Inyecta el repositorio y los Cubits por encima de
/// `MaterialApp`, y conecta el tema con `BlocBuilder<ThemeCubit, ThemeState>`.
class WalletApp extends StatelessWidget {
  const WalletApp({
    super.key,
    required this.firebaseStatus,
    required this.themePreferences,
    this.repository,
  });

  final FirebaseStatus firebaseStatus;
  final ThemePreferences themePreferences;

  /// Permite inyectar un repositorio distinto (por ejemplo, uno que falla) para
  /// probar los estados de error sin Firebase (Reto 3). En producción se usa la
  /// implementación en memoria.
  final WalletRepository? repository;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<WalletRepository>(
      create: (_) => repository ?? InMemoryWalletRepository(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ThemeCubit>(
            create: (_) => ThemeCubit(themePreferences),
          ),
          BlocProvider<PrivacyCubit>(
            create: (_) => PrivacyCubit(),
          ),
          BlocProvider<MovementsBloc>(
            lazy: false,
            create: (context) =>
                MovementsBloc(repository: context.read<WalletRepository>())
                  ..add(const MovementsStarted()),
          ),
        ],
        child: BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, themeState) {
            return MaterialApp(
              title: 'Wallet UNSAAC',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light(themeState.seedColor),
              darkTheme: AppTheme.dark(themeState.seedColor),
              themeMode: themeState.mode,
              home: WalletHomePage(firebaseStatus: firebaseStatus),
            );
          },
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet_unsaac/core/config/firebase_status.dart';
import 'package:wallet_unsaac/core/theme/app_theme.dart';
import 'package:wallet_unsaac/core/theme/theme_cubit.dart';
import 'package:wallet_unsaac/core/theme/theme_preferences.dart';
import 'package:wallet_unsaac/core/theme/theme_state.dart';
import 'package:wallet_unsaac/features/auth/data/repositories/firebase_auth_repository.dart';
import 'package:wallet_unsaac/features/auth/data/repositories/in_memory_auth_repository.dart';
import 'package:wallet_unsaac/features/auth/domain/repositories/auth_repository.dart';
import 'package:wallet_unsaac/features/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:wallet_unsaac/features/auth/presentation/blocs/auth/auth_event.dart';
import 'package:wallet_unsaac/features/auth/presentation/pages/auth_gate.dart';
import 'package:wallet_unsaac/features/wallet/data/repositories/in_memory_wallet_repository.dart';
import 'package:wallet_unsaac/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:wallet_unsaac/features/wallet/presentation/blocs/movements/movements_bloc.dart';
import 'package:wallet_unsaac/features/wallet/presentation/blocs/movements/movements_event.dart';
import 'package:wallet_unsaac/features/wallet/presentation/cubits/privacy_cubit.dart';

/// Raíz de la aplicación.
///
/// Inyecta las dependencias y decide qué implementación de autenticación usar:
/// Firebase si está listo; el repositorio en memoria si la app corre en modo
/// local. Los parámetros opcionales permiten sustituir los repositorios en las
/// pruebas de widget.
class WalletApp extends StatelessWidget {
  const WalletApp({
    super.key,
    required this.firebaseStatus,
    required this.themePreferences,
    this.walletRepository,
    this.authRepository,
  });

  final FirebaseStatus firebaseStatus;
  final ThemePreferences themePreferences;
  final WalletRepository? walletRepository;
  final AuthRepository? authRepository;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<WalletRepository>(
          create: (_) => walletRepository ?? InMemoryWalletRepository(),
        ),
        RepositoryProvider<AuthRepository>(
          create: (_) =>
              authRepository ??
              (firebaseStatus.isReady
                  ? FirebaseAuthRepository()
                  : InMemoryAuthRepository()),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            lazy: false,
            create: (context) =>
                AuthBloc(repository: context.read<AuthRepository>())
                  ..add(const AuthStarted()),
          ),
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
              home: AuthGate(firebaseStatus: firebaseStatus),
            );
          },
        ),
      ),
    );
  }
}

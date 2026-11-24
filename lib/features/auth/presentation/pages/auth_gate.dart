import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet_unsaac/core/config/firebase_status.dart';
import 'package:wallet_unsaac/features/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:wallet_unsaac/features/auth/presentation/blocs/auth/auth_state.dart';
import 'package:wallet_unsaac/features/auth/presentation/pages/login_page.dart';
import 'package:wallet_unsaac/features/wallet/presentation/pages/wallet_home_page.dart';

/// Decide qué pantalla corresponde según la sesión.
///
/// El estado [AuthLoading] no cambia la pantalla: la interfaz de acceso sigue
/// montada y su botón refleja la carga. El gate solo cambia cuando la sesión
/// queda resuelta: autenticada o no autenticada.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key, required this.firebaseStatus});

  final FirebaseStatus firebaseStatus;

  static String? _messageOf(AuthState state) => switch (state) {
        AuthAuthenticated(:final message) => message,
        AuthUnauthenticated(:final message) => message,
        _ => null,
      };

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) {
        final message = _messageOf(current);
        return message != null && message != _messageOf(previous);
      },
      listener: (context, state) {
        final message = _messageOf(state);
        if (message == null) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        buildWhen: (previous, current) => current is! AuthLoading,
        builder: (context, state) {
          return switch (state) {
            AuthInitial() || AuthLoading() => const _AuthSplash(),
            AuthAuthenticated() => WalletHomePage(
                firebaseStatus: firebaseStatus,
              ),
            AuthUnauthenticated() => LoginPage(
                showDemoHint: !firebaseStatus.isReady,
              ),
          };
        },
      ),
    );
  }
}

class _AuthSplash extends StatelessWidget {
  const _AuthSplash();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: scheme.primaryContainer,
              child: Icon(
                Icons.account_balance_wallet_rounded,
                size: 34,
                color: scheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Wallet UNSAAC',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 18),
            const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
            const SizedBox(height: 12),
            Text(
              'Recuperando sesión…',
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

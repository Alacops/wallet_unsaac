import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet_unsaac/core/config/firebase_status.dart';
import 'package:wallet_unsaac/core/theme/theme_cubit.dart';
import 'package:wallet_unsaac/core/theme/theme_state.dart';
import 'package:wallet_unsaac/features/wallet/domain/entities/wallet_summary.dart';
import 'package:wallet_unsaac/features/wallet/presentation/cubits/balance_cubit.dart';
import 'package:wallet_unsaac/features/wallet/presentation/cubits/balance_state.dart';
import 'package:wallet_unsaac/features/wallet/presentation/cubits/privacy_cubit.dart';
import 'package:wallet_unsaac/features/wallet/presentation/cubits/privacy_state.dart';
import 'package:wallet_unsaac/features/wallet/presentation/widgets/balance_card.dart';
import 'package:wallet_unsaac/features/wallet/presentation/widgets/firebase_status_card.dart';
import 'package:wallet_unsaac/features/wallet/presentation/widgets/movement_tile.dart';
import 'package:wallet_unsaac/features/wallet/presentation/widgets/seed_color_selector.dart';

/// Pantalla principal de Wallet UNSAAC (Sesión 1 + cuatro retos).
///
/// La carga la gobierna [BalanceCubit] (Reto 3); la privacidad, [PrivacyCubit]
/// (Reto 2); el tema y el color semilla, [ThemeCubit] (Retos 1 y 4). La
/// pantalla no calcula ni habla directamente con el repositorio.
class WalletHomePage extends StatelessWidget {
  const WalletHomePage({super.key, required this.firebaseStatus});

  final FirebaseStatus firebaseStatus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: Row(
          children: [
            Icon(
              Icons.account_balance_wallet_rounded,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            const Text(
              'Wallet UNSAAC',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
            ),
          ],
        ),
        actions: const [_ThemeModeButton(), SizedBox(width: 8)],
      ),
      body: BlocBuilder<BalanceCubit, BalanceState>(
        builder: (context, state) {
          return switch (state) {
            BalanceInitial() ||
            BalanceLoading() =>
              const Center(child: CircularProgressIndicator()),
            BalanceFailure(:final message) => _ErrorView(
                message: message,
                onRetry: () => context.read<BalanceCubit>().load(),
              ),
            BalanceSuccess(:final summary) => _SummaryView(
                summary: summary,
                firebaseStatus: firebaseStatus,
              ),
          };
        },
      ),
    );
  }
}

/// Botón del AppBar que recorre claro → oscuro → sistema (Reto 1). El icono y
/// el tooltip reflejan el modo actual.
class _ThemeModeButton extends StatelessWidget {
  const _ThemeModeButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        final (IconData icon, String tooltip) = switch (state.mode) {
          ThemeMode.light => (
              Icons.light_mode_outlined,
              'Tema claro · tocar para oscuro',
            ),
          ThemeMode.dark => (
              Icons.dark_mode_outlined,
              'Tema oscuro · tocar para seguir al sistema',
            ),
          ThemeMode.system => (
              Icons.brightness_auto_outlined,
              'Según el sistema · tocar para claro',
            ),
        };
        return IconButton(
          tooltip: tooltip,
          icon: Icon(icon),
          onPressed: () => context.read<ThemeCubit>().toggle(),
        );
      },
    );
  }
}

class _SummaryView extends StatelessWidget {
  const _SummaryView({required this.summary, required this.firebaseStatus});

  final WalletSummary summary;
  final FirebaseStatus firebaseStatus;

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$feature se habilita en la Sesión 2.'),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<PrivacyCubit, PrivacyState>(
      builder: (context, privacy) {
        return RefreshIndicator(
          onRefresh: () => context.read<BalanceCubit>().load(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              Text(
                'Hola, estudiante UNSAAC',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Este es el resumen de tus finanzas en noviembre de 2026.',
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 20),
              BalanceCard(
                summary: summary,
                hideBalance: privacy.hidden,
                onTogglePrivacy: () => context.read<PrivacyCubit>().toggle(),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: () =>
                          _showComingSoon(context, 'Registrar ingreso'),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Ingreso'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _showComingSoon(context, 'Registrar egreso'),
                      icon: const Icon(Icons.remove_rounded),
                      label: const Text('Egreso'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Últimos movimientos',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        _showComingSoon(context, 'El historial completo'),
                    child: const Text('Ver todos'),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              if (summary.isEmpty)
                const _EmptyMovements()
              else
                for (final movement in summary.movements) ...[
                  MovementTile(movement: movement, hideAmount: privacy.hidden),
                  const SizedBox(height: 10),
                ],
              const SizedBox(height: 16),
              const SeedColorSelector(),
              const SizedBox(height: 20),
              FirebaseStatusCard(status: firebaseStatus),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Datos de demostración · Wallet UNSAAC 1.0.0',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Vista de error con botón de reintento (Reto 3).
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 56, color: scheme.error),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Revisa la conexión y vuelve a intentarlo.',
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyMovements extends StatelessWidget {
  const _EmptyMovements();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 40,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            const Text('Todavía no registraste movimientos.'),
          ],
        ),
      ),
    );
  }
}

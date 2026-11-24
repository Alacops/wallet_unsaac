import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet_unsaac/core/config/app_profile.dart';
import 'package:wallet_unsaac/core/config/firebase_status.dart';
import 'package:wallet_unsaac/core/theme/theme_cubit.dart';
import 'package:wallet_unsaac/core/theme/theme_state.dart';
import 'package:wallet_unsaac/features/wallet/domain/entities/movement.dart';
import 'package:wallet_unsaac/features/wallet/domain/entities/wallet_summary.dart';
import 'package:wallet_unsaac/features/wallet/presentation/blocs/movements/movement_filter.dart';
import 'package:wallet_unsaac/features/wallet/presentation/blocs/movements/movements_bloc.dart';
import 'package:wallet_unsaac/features/wallet/presentation/blocs/movements/movements_event.dart';
import 'package:wallet_unsaac/features/wallet/presentation/blocs/movements/movements_state.dart';
import 'package:wallet_unsaac/features/wallet/presentation/cubits/privacy_cubit.dart';
import 'package:wallet_unsaac/features/wallet/presentation/cubits/privacy_state.dart';
import 'package:wallet_unsaac/features/wallet/presentation/widgets/balance_card.dart';
import 'package:wallet_unsaac/features/wallet/presentation/widgets/firebase_status_card.dart';
import 'package:wallet_unsaac/features/wallet/presentation/widgets/identity_header.dart';
import 'package:wallet_unsaac/features/wallet/presentation/widgets/movement_tile.dart';
import 'package:wallet_unsaac/features/wallet/presentation/widgets/seed_color_selector.dart';
import 'package:wallet_unsaac/features/wallet/presentation/widgets/unsaac_logo.dart';

/// Pantalla principal de Wallet UNSAAC.
///
/// El flujo de movimientos lo gobierna [MovementsBloc]: la pantalla no calcula
/// saldos ni habla directamente con el repositorio, solo envía eventos y pinta
/// estados. La privacidad la gobierna [PrivacyCubit]; el tema y el color
/// semilla, [ThemeCubit].
class WalletHomePage extends StatelessWidget {
  const WalletHomePage({super.key, required this.firebaseStatus});

  final FirebaseStatus firebaseStatus;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: Row(
          children: [
            const UnsaacLogo(size: 32),
            const SizedBox(width: 10),
            Text(
              AppProfile.appName,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
            ),
          ],
        ),
        actions: const [
          _ClearHistoryButton(),
          _ThemeModeButton(),
          SizedBox(width: 8),
        ],
      ),
      body: BlocListener<MovementsBloc, MovementsState>(
        // Reto 3: solo reacciona a un error nuevo sobre una lista visible.
        listenWhen: (previous, current) =>
            current is MovementsReady &&
            current.errorMessage != null &&
            (previous is! MovementsReady ||
                previous.errorMessage != current.errorMessage),
        listener: (context, state) {
          final message = (state as MovementsReady).errorMessage!;
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(message),
                action: SnackBarAction(
                  label: 'Reintentar',
                  onPressed: () => context
                      .read<MovementsBloc>()
                      .add(const MovementsStarted()),
                ),
              ),
            );
        },
        child: BlocBuilder<MovementsBloc, MovementsState>(
          // Reto 4: un cambio de solo-filtro no reconstruye la pantalla. La
          // tarjeta de saldo y las acciones no dependen del filtro; el
          // BlocSelector interno reconstruye únicamente la lista.
          buildWhen: (previous, current) {
            if (previous is MovementsReady && current is MovementsReady) {
              return previous.summary != current.summary ||
                  previous.isSaving != current.isSaving ||
                  previous.errorMessage != current.errorMessage;
            }
            return true;
          },
          builder: (context, state) {
            return switch (state) {
              MovementsInitial() ||
              MovementsLoading() =>
                const Center(child: CircularProgressIndicator()),
              MovementsFailure(:final message) => _ErrorView(
                  message: message,
                  onRetry: () => context
                      .read<MovementsBloc>()
                      .add(const MovementsStarted()),
                ),
              MovementsReady(:final summary, :final isSaving) => _SummaryView(
                  summary: summary,
                  isSaving: isSaving,
                  firebaseStatus: firebaseStatus,
                ),
            };
          },
        ),
      ),
    );
  }
}

/// Botón del AppBar que recorre claro → oscuro → sistema. El icono y el
/// tooltip reflejan el modo actual.
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

/// Botón del AppBar que vacía el historial tras confirmar. Envía
/// [MovementsCleared]; la decisión de borrar la toma el usuario en el diálogo.
class _ClearHistoryButton extends StatelessWidget {
  const _ClearHistoryButton();

  Future<void> _confirmAndClear(BuildContext context) async {
    final bloc = context.read<MovementsBloc>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Vaciar historial'),
        content: const Text(
          '¿Seguro que quieres eliminar todos los movimientos? '
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Vaciar'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      bloc.add(const MovementsCleared());
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Vaciar historial',
      icon: const Icon(Icons.delete_sweep_outlined),
      onPressed: () => _confirmAndClear(context),
    );
  }
}

class _SummaryView extends StatelessWidget {
  const _SummaryView({
    required this.summary,
    required this.isSaving,
    required this.firebaseStatus,
  });

  final WalletSummary summary;
  final bool isSaving;
  final FirebaseStatus firebaseStatus;

  /// Construye un movimiento de demostración con un identificador único y lo
  /// envía al bloc con [MovementAdded]. En un producto real, el identificador
  /// lo genera el backend o un UUID.
  void _addDemoMovement(BuildContext context, MovementType type) {
    final now = DateTime.now();
    final isIncome = type == MovementType.income;
    final movement = Movement(
      id: 'tx-${now.microsecondsSinceEpoch}',
      title: isIncome ? 'Ingreso de demostración' : 'Egreso de demostración',
      category: isIncome ? 'Ingreso extra' : 'Alimentación',
      amount: isIncome ? 150 : 25.50,
      type: type,
      date: now,
    );
    context.read<MovementsBloc>().add(MovementAdded(movement));
  }

  /// Abre un formulario mínimo (título y monto) para editar el movimiento y,
  /// si el usuario guarda, envía [MovementUpdated] con el mismo id (Reto 1).
  Future<void> _editMovement(BuildContext context, Movement movement) async {
    final bloc = context.read<MovementsBloc>();
    final edited = await showDialog<Movement>(
      context: context,
      builder: (_) => _EditMovementDialog(movement: movement),
    );
    if (edited != null) {
      bloc.add(MovementUpdated(edited));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<PrivacyCubit, PrivacyState>(
      builder: (context, privacy) {
        return RefreshIndicator(
          onRefresh: () async {
            final bloc = context.read<MovementsBloc>();
            bloc.add(const MovementsStarted());
            await bloc.stream
                .firstWhere((state) => state is! MovementsLoading);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              const IdentityHeader(),
              const SizedBox(height: 16),
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
                          _addDemoMovement(context, MovementType.income),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Ingreso'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _addDemoMovement(context, MovementType.expense),
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
                  if (isSaving)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Guardando…',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      '${summary.movements.length} registros',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              // Reto 4: solo esta región se reconstruye al cambiar el filtro.
              BlocSelector<MovementsBloc, MovementsState, MovementFilter>(
                selector: (state) =>
                    state is MovementsReady ? state.filter : MovementFilter.all,
                builder: (context, filter) {
                  final visible = switch (filter) {
                    MovementFilter.all => summary.movements,
                    MovementFilter.income => summary.movements
                        .where((movement) => movement.isIncome)
                        .toList(),
                    MovementFilter.expense => summary.movements
                        .where((movement) => !movement.isIncome)
                        .toList(),
                  };
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SegmentedButton<MovementFilter>(
                        segments: const [
                          ButtonSegment(
                            value: MovementFilter.all,
                            label: Text('Todos'),
                          ),
                          ButtonSegment(
                            value: MovementFilter.income,
                            label: Text('Ingresos'),
                          ),
                          ButtonSegment(
                            value: MovementFilter.expense,
                            label: Text('Egresos'),
                          ),
                        ],
                        selected: {filter},
                        onSelectionChanged: (selection) => context
                            .read<MovementsBloc>()
                            .add(MovementsFilterChanged(selection.first)),
                      ),
                      const SizedBox(height: 12),
                      if (summary.isEmpty)
                        const _EmptyMovements()
                      else if (visible.isEmpty)
                        const _NoMovementsForFilter()
                      else
                        for (final movement in visible) ...[
                          MovementTile(
                            movement: movement,
                            hideAmount: privacy.hidden,
                            onEdit: () => _editMovement(context, movement),
                            onDelete: () => context
                                .read<MovementsBloc>()
                                .add(MovementRemoved(movement.id)),
                          ),
                          const SizedBox(height: 10),
                        ],
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              const SeedColorSelector(),
              const SizedBox(height: 20),
              FirebaseStatusCard(status: firebaseStatus),
              const SizedBox(height: 20),
              const _AcademicFooter(),
            ],
          ),
        );
      },
    );
  }
}

/// Vista de error con botón de reintento.
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

/// Pie con el contexto académico del proyecto (curso, docente y versión).
class _AcademicFooter extends StatelessWidget {
  const _AcademicFooter();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    return Column(
      children: [
        const UnsaacLogo(size: 36),
        const SizedBox(height: 8),
        Text(AppProfile.courseLine, style: style, textAlign: TextAlign.center),
        Text('Docente: ${AppProfile.teacher}',
            style: style, textAlign: TextAlign.center),
        Text(AppProfile.unit, style: style, textAlign: TextAlign.center),
        const SizedBox(height: 4),
        Text(
          'Datos de demostración · ${AppProfile.appName} ${AppProfile.appVersion}',
          style: style?.copyWith(fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Formulario mínimo para editar un movimiento (Reto 1). Solo permite cambiar
/// el título y el monto; el identificador, el tipo y la fecha no se tocan, de
/// modo que `copyWith` nunca cambia el id.
class _EditMovementDialog extends StatefulWidget {
  const _EditMovementDialog({required this.movement});

  final Movement movement;

  @override
  State<_EditMovementDialog> createState() => _EditMovementDialogState();
}

class _EditMovementDialogState extends State<_EditMovementDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.movement.title);
    _amountController = TextEditingController(
      text: widget.movement.amount.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final amount = double.parse(_amountController.text.replaceAll(',', '.'));
    Navigator.of(context).pop(
      widget.movement.copyWith(
        title: _titleController.text.trim(),
        amount: amount,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar movimiento'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Título'),
              textInputAction: TextInputAction.next,
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Escribe un título'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Monto',
                prefixText: 'S/ ',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                final parsed =
                    double.tryParse((value ?? '').replaceAll(',', '.'));
                if (parsed == null || parsed <= 0) {
                  return 'Escribe un monto válido';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _save, child: const Text('Guardar')),
      ],
    );
  }
}

/// Mensaje cuando el filtro activo no tiene movimientos, pero sí hay otros
/// (Reto 4). Distinto del historial totalmente vacío.
class _NoMovementsForFilter extends StatelessWidget {
  const _NoMovementsForFilter();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(
              Icons.filter_alt_off_outlined,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('No hay movimientos de este tipo.'),
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

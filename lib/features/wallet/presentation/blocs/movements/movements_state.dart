import 'package:equatable/equatable.dart';
import 'package:wallet_unsaac/features/wallet/domain/entities/movement.dart';
import 'package:wallet_unsaac/features/wallet/domain/entities/wallet_summary.dart';
import 'package:wallet_unsaac/features/wallet/presentation/blocs/movements/movement_filter.dart';

/// Estados que el [MovementsBloc] puede emitir.
///
/// La jerarquía es sellada y exclusiva: en un instante el bloc está en una de
/// estas cuatro situaciones, nunca en dos. Cada subtipo lleva solo los datos
/// que necesita, de modo que la interfaz no tenga que revisar banderas ni
/// desreferenciar valores nulos.
sealed class MovementsState extends Equatable {
  const MovementsState();

  @override
  List<Object?> get props => const [];
}

/// Estado anterior a la primera carga.
final class MovementsInitial extends MovementsState {
  const MovementsInitial();
}

/// Hay una operación de lectura en curso.
final class MovementsLoading extends MovementsState {
  const MovementsLoading();
}

/// El resumen está disponible para pintarse.
///
/// [isSaving] es verdadero mientras una operación de guardado está en curso: la
/// lista sigue visible y la interfaz muestra un indicador lineal (Reto 2).
///
/// [errorMessage] es un mensaje transitorio cuando falla una operación de alta,
/// edición o baja: la lista se conserva y la pantalla muestra un `SnackBar` en
/// vez de reemplazar todo el contenido por una vista de error (Reto 3).
final class MovementsReady extends MovementsState {
  const MovementsReady(
    this.summary, {
    this.isSaving = false,
    this.errorMessage,
    this.filter = MovementFilter.all,
  });

  final WalletSummary summary;
  final bool isSaving;
  final String? errorMessage;
  final MovementFilter filter;

  /// Movimientos que se muestran según el [filter]. El resumen y el saldo se
  /// calculan siempre sobre todos los movimientos (Reto 4).
  List<Movement> get visibleMovements => switch (filter) {
        MovementFilter.all => summary.movements,
        MovementFilter.income =>
          summary.movements.where((movement) => movement.isIncome).toList(),
        MovementFilter.expense =>
          summary.movements.where((movement) => !movement.isIncome).toList(),
      };

  MovementsReady copyWith({
    WalletSummary? summary,
    bool? isSaving,
    String? errorMessage,
    MovementFilter? filter,
  }) {
    return MovementsReady(
      summary ?? this.summary,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage ?? this.errorMessage,
      filter: filter ?? this.filter,
    );
  }

  @override
  List<Object?> get props => [summary, isSaving, errorMessage, filter];
}

/// La última operación falló; [message] es apto para mostrarse al usuario.
final class MovementsFailure extends MovementsState {
  const MovementsFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

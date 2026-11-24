import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet_unsaac/features/wallet/domain/entities/wallet_summary.dart';
import 'package:wallet_unsaac/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:wallet_unsaac/features/wallet/presentation/blocs/movements/movements_event.dart';
import 'package:wallet_unsaac/features/wallet/presentation/blocs/movements/movements_state.dart';

/// Bloc que gobierna el resumen de movimientos de Wallet UNSAAC.
///
/// Recibe intenciones ([MovementsEvent]), consulta el repositorio y emite
/// estados ([MovementsState]). No conoce widgets, `BuildContext` ni Firebase:
/// esa separación permite probarlo con `blocTest` en milisegundos.
class MovementsBloc extends Bloc<MovementsEvent, MovementsState> {
  MovementsBloc({required this.repository}) : super(const MovementsInitial()) {
    on<MovementsStarted>(_onStarted);
    on<MovementAdded>(_onAdded);
    on<MovementUpdated>(_onUpdated);
    on<MovementRemoved>(_onRemoved);
    on<MovementsCleared>(_onCleared);
  }

  final WalletRepository repository;

  /// Mensajes estables que la interfaz puede mostrar tal cual. Al vivir en el
  /// bloc, las pruebas verifican el texto sin duplicarlo.
  static const String loadFailureMessage =
      'No se pudieron cargar los movimientos.';
  static const String addFailureMessage = 'No se pudo registrar el movimiento.';
  static const String updateFailureMessage =
      'No se pudo actualizar el movimiento.';
  static const String removeFailureMessage =
      'No se pudo eliminar el movimiento.';
  static const String clearFailureMessage = 'No se pudo vaciar el historial.';

  Future<void> _onStarted(
    MovementsStarted event,
    Emitter<MovementsState> emit,
  ) async {
    if (emit.isDone) return;
    emit(const MovementsLoading());
    await _execute(emit, loadFailureMessage, repository.loadSummary);
  }

  Future<void> _onAdded(MovementAdded event, Emitter<MovementsState> emit) {
    return _execute(
      emit,
      addFailureMessage,
      () => repository.addMovement(event.movement),
    );
  }

  Future<void> _onUpdated(MovementUpdated event, Emitter<MovementsState> emit) {
    return _execute(
      emit,
      updateFailureMessage,
      () => repository.updateMovement(event.movement),
    );
  }

  Future<void> _onRemoved(MovementRemoved event, Emitter<MovementsState> emit) {
    return _execute(
      emit,
      removeFailureMessage,
      () => repository.removeMovement(event.movementId),
    );
  }

  Future<void> _onCleared(
    MovementsCleared event,
    Emitter<MovementsState> emit,
  ) {
    return _execute(emit, clearFailureMessage, repository.clearMovements);
  }

  /// Patrón común de las cuatro operaciones: ejecutar, emitir el resumen o
  /// emitir un estado de error. La interfaz nunca ve la excepción original:
  /// ve un mensaje que puede mostrar.
  ///
  /// `emit.isDone` se comprueba después de cada `await` porque el bloc pudo
  /// cerrarse mientras la operación estaba en curso; emitir en ese momento
  /// lanzaría un `StateError`.
  Future<void> _execute(
    Emitter<MovementsState> emit,
    String failureMessage,
    Future<WalletSummary> Function() operation,
  ) async {
    if (emit.isDone) return;
    try {
      final summary = await operation();
      if (emit.isDone) return;
      emit(MovementsReady(summary));
    } on Exception {
      if (emit.isDone) return;
      emit(MovementsFailure(failureMessage));
    }
  }
}

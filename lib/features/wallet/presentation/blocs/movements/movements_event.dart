import 'package:equatable/equatable.dart';
import 'package:wallet_unsaac/features/wallet/domain/entities/movement.dart';
import 'package:wallet_unsaac/features/wallet/presentation/blocs/movements/movement_filter.dart';

/// Intenciones que la interfaz puede enviar al [MovementsBloc].
///
/// Los eventos se modelan con una clase sellada: el compilador conoce todos
/// los subtipos y el bloc puede registrar un manejador por cada uno. El nombre
/// se escribe en pasado porque describe algo que ya ocurrió.
sealed class MovementsEvent extends Equatable {
  const MovementsEvent();

  @override
  List<Object?> get props => const [];
}

/// Pide la carga inicial del resumen.
final class MovementsStarted extends MovementsEvent {
  const MovementsStarted();
}

/// Pide registrar un movimiento nuevo.
final class MovementAdded extends MovementsEvent {
  const MovementAdded(this.movement);

  final Movement movement;

  @override
  List<Object?> get props => [movement];
}

/// Pide reemplazar un movimiento existente por su versión editada.
/// El [movement] conserva el mismo identificador (Reto 1).
final class MovementUpdated extends MovementsEvent {
  const MovementUpdated(this.movement);

  final Movement movement;

  @override
  List<Object?> get props => [movement];
}

/// Pide eliminar el movimiento con [movementId].
final class MovementRemoved extends MovementsEvent {
  const MovementRemoved(this.movementId);

  final String movementId;

  @override
  List<Object?> get props => [movementId];
}

/// Pide vaciar el historial de movimientos.
final class MovementsCleared extends MovementsEvent {
  const MovementsCleared();
}

/// Pide cambiar el filtro de la lista por tipo (Reto 4). No toca el repositorio:
/// solo cambia qué movimientos se muestran.
final class MovementsFilterChanged extends MovementsEvent {
  const MovementsFilterChanged(this.filter);

  final MovementFilter filter;

  @override
  List<Object?> get props => [filter];
}

import 'package:equatable/equatable.dart';
import 'package:wallet_unsaac/features/wallet/domain/entities/wallet_summary.dart';

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
final class MovementsReady extends MovementsState {
  const MovementsReady(this.summary);

  final WalletSummary summary;

  @override
  List<Object?> get props => [summary];
}

/// La última operación falló; [message] es apto para mostrarse al usuario.
final class MovementsFailure extends MovementsState {
  const MovementsFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

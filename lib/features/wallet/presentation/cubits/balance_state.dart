import 'package:equatable/equatable.dart';
import 'package:wallet_unsaac/features/wallet/domain/entities/wallet_summary.dart';

/// Jerarquía sellada de estados del saldo (Reto 3). Distingue con claridad
/// la carga, el éxito y el error, en lugar de mezclarlos en un FutureBuilder.
sealed class BalanceState extends Equatable {
  const BalanceState();

  @override
  List<Object?> get props => const [];
}

final class BalanceInitial extends BalanceState {
  const BalanceInitial();
}

final class BalanceLoading extends BalanceState {
  const BalanceLoading();
}

final class BalanceSuccess extends BalanceState {
  const BalanceSuccess(this.summary);

  final WalletSummary summary;

  @override
  List<Object?> get props => [summary];
}

final class BalanceFailure extends BalanceState {
  const BalanceFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

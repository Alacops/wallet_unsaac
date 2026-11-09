import 'package:wallet_unsaac/features/wallet/domain/entities/movement.dart';

/// Resumen de la billetera. El saldo se calcula aquí, no en la pantalla.
class WalletSummary {
  const WalletSummary({required this.movements});

  final List<Movement> movements;

  double get income => movements
      .where((movement) => movement.isIncome)
      .fold(0, (total, movement) => total + movement.amount);

  double get expenses => movements
      .where((movement) => !movement.isIncome)
      .fold(0, (total, movement) => total + movement.amount);

  double get balance => income - expenses;

  bool get isEmpty => movements.isEmpty;
}

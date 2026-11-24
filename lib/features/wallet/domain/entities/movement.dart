import 'package:equatable/equatable.dart';

/// Tipo de movimiento financiero.
enum MovementType { income, expense }

/// Movimiento financiero del dominio. No conoce Flutter ni Firebase.
///
/// `amount` siempre es positivo; el signo se deriva del [type]. Esto evita
/// inconsistencias al sumar y simplifica el cálculo del saldo.
///
/// Implementa [Equatable] porque viaja dentro del estado del bloc. Dos
/// movimientos con los mismos valores deben compararse como iguales para que
/// el estado pueda compararse por valor y el bloc no emita de más.
class Movement extends Equatable {
  const Movement({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.type,
    required this.date,
  });

  final String id;
  final String title;
  final String category;
  final double amount;
  final MovementType type;
  final DateTime date;

  bool get isIncome => type == MovementType.income;

  double get signedAmount => isIncome ? amount : -amount;

  /// Devuelve una copia del movimiento con los campos indicados cambiados.
  /// El [id] no se puede cambiar: si cambiara, el movimiento se convertiría
  /// en otro y la eliminación posterior fallaría.
  Movement copyWith({
    String? title,
    String? category,
    double? amount,
    MovementType? type,
    DateTime? date,
  }) {
    return Movement(
      id: id,
      title: title ?? this.title,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      date: date ?? this.date,
    );
  }

  @override
  List<Object?> get props => [id, title, category, amount, type, date];
}

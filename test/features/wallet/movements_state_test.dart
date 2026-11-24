import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_unsaac/features/wallet/domain/entities/movement.dart';
import 'package:wallet_unsaac/features/wallet/domain/entities/wallet_summary.dart';
import 'package:wallet_unsaac/features/wallet/presentation/blocs/movements/movements_state.dart';

/// Igualdad por valor de las entidades y de los estados. Sin esta igualdad el
/// bloc emitiría estados redundantes y las pruebas del bloc fallarían.
Movement _movement(String id) => Movement(
      id: id,
      title: 'Sueldo de prácticas',
      category: 'Trabajo',
      amount: 1200,
      type: MovementType.income,
      date: DateTime(2026, 11, 2),
    );

void main() {
  group('Igualdad por valor', () {
    test('dos Movement con los mismos valores son iguales', () {
      expect(_movement('tx-001'), equals(_movement('tx-001')));
      expect(_movement('tx-001'), isNot(equals(_movement('tx-002'))));
    });

    test('dos WalletSummary con los mismos movimientos son iguales', () {
      final a = WalletSummary(movements: [_movement('tx-001')]);
      final b = WalletSummary(movements: [_movement('tx-001')]);
      expect(a, equals(b));
    });

    test('dos MovementsReady con el mismo resumen son iguales', () {
      final summary = WalletSummary(movements: [_movement('tx-001')]);
      expect(MovementsReady(summary), equals(MovementsReady(summary)));
    });

    test('dos MovementsReady con resúmenes distintos son distintos', () {
      final a = MovementsReady(WalletSummary(movements: [_movement('tx-001')]));
      final b = MovementsReady(WalletSummary(movements: [_movement('tx-002')]));
      expect(a, isNot(equals(b)));
    });

    test('MovementsFailure compara por mensaje; Initial y Loading difieren', () {
      expect(
        const MovementsFailure('falló'),
        equals(const MovementsFailure('falló')),
      );
      expect(const MovementsInitial(), equals(const MovementsInitial()));
      expect(
        const MovementsInitial(),
        isNot(equals(const MovementsLoading())),
      );
    });
  });
}

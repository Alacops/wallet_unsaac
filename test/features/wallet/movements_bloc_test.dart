import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_unsaac/features/wallet/data/repositories/in_memory_wallet_repository.dart';
import 'package:wallet_unsaac/features/wallet/domain/entities/movement.dart';
import 'package:wallet_unsaac/features/wallet/domain/entities/wallet_summary.dart';
import 'package:wallet_unsaac/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:wallet_unsaac/features/wallet/presentation/blocs/movements/movements_bloc.dart';
import 'package:wallet_unsaac/features/wallet/presentation/blocs/movements/movements_event.dart';
import 'package:wallet_unsaac/features/wallet/presentation/blocs/movements/movements_state.dart';

/// Semilla mínima y determinista: dos movimientos, un ingreso y un egreso.
final Movement _income = Movement(
  id: 'tx-001',
  title: 'Sueldo de prácticas',
  category: 'Trabajo',
  amount: 1200,
  type: MovementType.income,
  date: DateTime(2026, 11, 2),
);

final Movement _expense = Movement(
  id: 'tx-002',
  title: 'Pasajes al campus',
  category: 'Transporte',
  amount: 48,
  type: MovementType.expense,
  date: DateTime(2026, 11, 6),
);

final List<Movement> _seed = <Movement>[_income, _expense];

final Movement _newMovement = Movement(
  id: 'tx-003',
  title: 'Almuerzo en el comedor',
  category: 'Alimentación',
  amount: 7.50,
  type: MovementType.expense,
  date: DateTime(2026, 11, 7),
);

MovementsBloc _buildBloc() {
  return MovementsBloc(
    repository: InMemoryWalletRepository(
      latency: Duration.zero,
      movements: _seed,
    ),
  );
}

/// Repositorio que falla en todas las operaciones. Sirve para probar los
/// estados de error sin depender de la red ni de Firebase.
class _FailingRepository implements WalletRepository {
  @override
  Future<WalletSummary> loadSummary() async {
    throw Exception('Servicio no disponible');
  }

  @override
  Future<WalletSummary> addMovement(Movement movement) async {
    throw Exception('Servicio no disponible');
  }

  @override
  Future<WalletSummary> updateMovement(Movement movement) async {
    throw Exception('Servicio no disponible');
  }

  @override
  Future<WalletSummary> removeMovement(String movementId) async {
    throw Exception('Servicio no disponible');
  }

  @override
  Future<WalletSummary> clearMovements() async {
    throw Exception('Servicio no disponible');
  }
}

void main() {
  group('MovementsBloc', () {
    test('inicia en MovementsInitial', () {
      final bloc = _buildBloc();
      expect(bloc.state, const MovementsInitial());
      addTearDown(bloc.close);
    });

    blocTest<MovementsBloc, MovementsState>(
      'emite [cargando, listo] al iniciar',
      build: _buildBloc,
      act: (bloc) => bloc.add(const MovementsStarted()),
      expect: () => [
        const MovementsLoading(),
        MovementsReady(WalletSummary(movements: _seed)),
      ],
    );

    blocTest<MovementsBloc, MovementsState>(
      'emite el resumen con el movimiento nuevo al agregar',
      build: _buildBloc,
      act: (bloc) => bloc.add(MovementAdded(_newMovement)),
      expect: () => [
        MovementsReady(WalletSummary(movements: [..._seed, _newMovement])),
      ],
    );

    blocTest<MovementsBloc, MovementsState>(
      'edita un movimiento conservando su posición y recalcula el saldo (Reto 1)',
      build: _buildBloc,
      act: (bloc) =>
          bloc.add(MovementUpdated(_income.copyWith(amount: 1500))),
      expect: () => [
        MovementsReady(
          WalletSummary(movements: [_income.copyWith(amount: 1500), _expense]),
        ),
      ],
    );

    blocTest<MovementsBloc, MovementsState>(
      'emite el resumen sin el movimiento al eliminar',
      build: _buildBloc,
      act: (bloc) => bloc.add(const MovementRemoved('tx-001')),
      expect: () => [
        MovementsReady(WalletSummary(movements: [_expense])),
      ],
    );

    blocTest<MovementsBloc, MovementsState>(
      'no emite si el resumen no cambia',
      build: _buildBloc,
      seed: () => MovementsReady(WalletSummary(movements: _seed)),
      act: (bloc) => bloc.add(const MovementRemoved('tx-inexistente')),
      expect: () => <MovementsState>[],
    );

    blocTest<MovementsBloc, MovementsState>(
      'vacía el historial con MovementsCleared',
      build: _buildBloc,
      act: (bloc) => bloc.add(const MovementsCleared()),
      expect: () => [const MovementsReady(WalletSummary(movements: []))],
    );

    blocTest<MovementsBloc, MovementsState>(
      'emite carga y error cuando falla la lectura',
      build: () => MovementsBloc(repository: _FailingRepository()),
      act: (bloc) => bloc.add(const MovementsStarted()),
      expect: () => [
        const MovementsLoading(),
        const MovementsFailure(MovementsBloc.loadFailureMessage),
      ],
    );

    blocTest<MovementsBloc, MovementsState>(
      'emite error cuando falla el alta',
      build: () => MovementsBloc(repository: _FailingRepository()),
      act: (bloc) => bloc.add(MovementAdded(_newMovement)),
      expect: () =>
          [const MovementsFailure(MovementsBloc.addFailureMessage)],
    );

    blocTest<MovementsBloc, MovementsState>(
      'emite error cuando falla la eliminación',
      build: () => MovementsBloc(repository: _FailingRepository()),
      act: (bloc) => bloc.add(const MovementRemoved('tx-001')),
      expect: () => [
        const MovementsFailure(MovementsBloc.removeFailureMessage),
      ],
    );
  });
}

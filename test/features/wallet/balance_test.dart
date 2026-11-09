import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_unsaac/features/wallet/data/repositories/in_memory_wallet_repository.dart';
import 'package:wallet_unsaac/features/wallet/domain/entities/wallet_summary.dart';
import 'package:wallet_unsaac/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:wallet_unsaac/features/wallet/presentation/cubits/balance_cubit.dart';
import 'package:wallet_unsaac/features/wallet/presentation/cubits/balance_state.dart';

/// Repositorio que siempre falla, para probar la rama de error (Reto 3).
class _FailingRepository implements WalletRepository {
  @override
  Future<WalletSummary> loadSummary() async {
    throw Exception('sin conexión');
  }
}

void main() {
  group('BalanceCubit', () {
    test('el estado inicial es BalanceInitial', () {
      final cubit = BalanceCubit(InMemoryWalletRepository(latency: Duration.zero));
      expect(cubit.state, const BalanceInitial());
      cubit.close();
    });

    blocTest<BalanceCubit, BalanceState>(
      'éxito: emite Loading y luego Success con el resumen',
      build: () =>
          BalanceCubit(InMemoryWalletRepository(latency: Duration.zero)),
      act: (cubit) => cubit.load(),
      expect: () => [
        const BalanceLoading(),
        isA<BalanceSuccess>().having(
          (state) => state.summary.balance,
          'balance',
          closeTo(1274.60, 0.001),
        ),
      ],
    );

    blocTest<BalanceCubit, BalanceState>(
      'fallo: emite Loading y luego Failure con mensaje comprensible',
      build: () => BalanceCubit(_FailingRepository()),
      act: (cubit) => cubit.load(),
      expect: () => const [
        BalanceLoading(),
        BalanceFailure('No se pudo cargar el resumen de la billetera.'),
      ],
    );

    blocTest<BalanceCubit, BalanceState>(
      'reintento: un segundo load vuelve a consultar el repositorio',
      build: () =>
          BalanceCubit(InMemoryWalletRepository(latency: Duration.zero)),
      act: (cubit) async {
        await cubit.load();
        await cubit.load();
      },
      expect: () => [
        const BalanceLoading(),
        isA<BalanceSuccess>(),
        const BalanceLoading(),
        isA<BalanceSuccess>(),
      ],
    );
  });
}

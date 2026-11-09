import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_unsaac/features/wallet/domain/entities/movement.dart';
import 'package:wallet_unsaac/features/wallet/domain/entities/wallet_summary.dart';
import 'package:wallet_unsaac/features/wallet/presentation/cubits/privacy_cubit.dart';
import 'package:wallet_unsaac/features/wallet/presentation/cubits/privacy_state.dart';
import 'package:wallet_unsaac/features/wallet/presentation/widgets/balance_card.dart';

/// Pruebas del Reto 2: saldo privado con PrivacyCubit.
void main() {
  group('PrivacyCubit', () {
    test('el estado inicial muestra los importes (hidden = false)', () {
      final cubit = PrivacyCubit();
      expect(cubit.state, const PrivacyState());
      expect(cubit.state.hidden, isFalse);
      cubit.close();
    });

    blocTest<PrivacyCubit, PrivacyState>(
      'toggle oculta y vuelve a mostrar',
      build: PrivacyCubit.new,
      act: (cubit) => cubit
        ..toggle()
        ..toggle(),
      expect: () => const [
        PrivacyState(hidden: true),
        PrivacyState(hidden: false),
      ],
    );
  });

  group('BalanceCard', () {
    final summary = WalletSummary(
      movements: [
        Movement(
          id: 'tx-1',
          title: 'Sueldo',
          category: 'Trabajo',
          amount: 1000,
          type: MovementType.income,
          date: DateTime(2026, 11, 2),
        ),
      ],
    );

    Widget wrap({required bool hideBalance}) => MaterialApp(
          home: Scaffold(
            body: BalanceCard(
              summary: summary,
              hideBalance: hideBalance,
              onTogglePrivacy: () {},
            ),
          ),
        );

    testWidgets('muestra el importe cuando no está oculto', (tester) async {
      await tester.pumpWidget(wrap(hideBalance: false));
      // Aparece en el saldo grande y en el total de ingresos.
      expect(find.text('S/ 1,000.00'), findsWidgets);
    });

    testWidgets('enmascara el importe cuando está oculto', (tester) async {
      await tester.pumpWidget(wrap(hideBalance: true));
      expect(find.text('S/ 1,000.00'), findsNothing);
      expect(find.text('••••••'), findsWidgets);
    });
  });
}

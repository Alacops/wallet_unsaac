import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet_unsaac/app.dart';
import 'package:wallet_unsaac/core/config/firebase_status.dart';
import 'package:wallet_unsaac/core/theme/theme_preferences.dart';
import 'package:wallet_unsaac/features/auth/domain/entities/auth_user.dart';
import 'package:wallet_unsaac/features/auth/domain/failures/auth_failure.dart';

import 'helpers/fake_auth_repository.dart';

const AuthUser _user = AuthUser(
  uid: 'uid-001',
  email: 'estudiante@unsaac.edu.pe',
  displayName: 'Estudiante UNSAAC',
);

FakeAuthRepository _unauthenticated({
  AuthUser? signInResult,
  AuthException? signInError,
}) {
  final repository = FakeAuthRepository(
    stream: Stream<AuthUser?>.value(null),
    signInResult: signInResult,
  );
  repository.signInError = signInError;
  return repository;
}

Future<void> _pumpApp(
  WidgetTester tester,
  FakeAuthRepository repository,
) async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final prefs = await ThemePreferences.create();
  await tester.pumpWidget(
    WalletApp(
      firebaseStatus: const FirebaseStatus.notConfigured(),
      themePreferences: prefs,
      authRepository: repository,
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('el formulario de acceso valida correo y contraseña',
      (tester) async {
    await _pumpApp(tester, _unauthenticated());

    expect(find.text('Inicia sesión'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('login_submit')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('login_submit')));
    await tester.pumpAndSettle();

    expect(find.text('Ingresa tu correo.'), findsOneWidget);
    expect(find.text('Ingresa tu contraseña.'), findsOneWidget);
  });

  testWidgets('un inicio de sesión correcto abre la billetera', (tester) async {
    await _pumpApp(tester, _unauthenticated(signInResult: _user));

    await tester.enterText(
      find.byKey(const Key('login_email')),
      'estudiante@unsaac.edu.pe',
    );
    await tester.enterText(
      find.byKey(const Key('login_password')),
      'wallet123',
    );
    await tester.ensureVisible(find.byKey(const Key('login_submit')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('login_submit')));
    await tester.pumpAndSettle();

    expect(find.text('Saldo disponible'), findsOneWidget);
    expect(find.text('S/ 1,274.60'), findsOneWidget);
  });

  testWidgets('un fallo de acceso muestra el mensaje del bloc', (tester) async {
    final repository = _unauthenticated(
      signInError: const AuthException(
        AuthFailureReason.invalidCredentials,
        AuthMessages.invalidCredentials,
      ),
    );
    await _pumpApp(tester, repository);

    await tester.enterText(
      find.byKey(const Key('login_email')),
      'estudiante@unsaac.edu.pe',
    );
    await tester.enterText(
      find.byKey(const Key('login_password')),
      'incorrecta',
    );
    await tester.ensureVisible(find.byKey(const Key('login_submit')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('login_submit')));
    await tester.pumpAndSettle();

    expect(find.text(AuthMessages.invalidCredentials), findsOneWidget);
  });

  testWidgets('el registro exige que las contraseñas coincidan',
      (tester) async {
    await _pumpApp(tester, _unauthenticated());

    await tester.ensureVisible(find.byKey(const Key('login_register')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('login_register')));
    await tester.pumpAndSettle();
    expect(find.text('Crea tu cuenta'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('register_email')),
      'nuevo@unsaac.edu.pe',
    );
    await tester.enterText(
      find.byKey(const Key('register_password')),
      'wallet123',
    );
    await tester.enterText(
      find.byKey(const Key('register_confirm')),
      'wallet124',
    );
    await tester.ensureVisible(find.byKey(const Key('register_submit')));
    await tester.tap(find.byKey(const Key('register_submit')));
    await tester.pumpAndSettle();

    expect(find.text('Las contraseñas no coinciden.'), findsOneWidget);
  });
}

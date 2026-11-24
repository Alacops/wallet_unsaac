import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_unsaac/features/auth/domain/entities/auth_user.dart';
import 'package:wallet_unsaac/features/auth/domain/failures/auth_failure.dart';
import 'package:wallet_unsaac/features/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:wallet_unsaac/features/auth/presentation/blocs/auth/auth_event.dart';
import 'package:wallet_unsaac/features/auth/presentation/blocs/auth/auth_state.dart';

import 'helpers/fake_auth_repository.dart';

const AuthUser _user = AuthUser(
  uid: 'uid-001',
  email: 'estudiante@unsaac.edu.pe',
  displayName: 'Estudiante UNSAAC',
);

void main() {
  group('AuthBloc', () {
    test('inicia en AuthInitial', () {
      final bloc = AuthBloc(repository: FakeAuthRepository());
      expect(bloc.state, const AuthInitial());
      addTearDown(bloc.close);
    });

    blocTest<AuthBloc, AuthState>(
      'AuthStarted emite carga y sesión autenticada',
      build: () => AuthBloc(
        repository: FakeAuthRepository(
          user: _user,
          stream: Stream<AuthUser?>.value(_user),
        ),
      ),
      act: (bloc) => bloc.add(const AuthStarted()),
      expect: () => [const AuthLoading(), const AuthAuthenticated(_user)],
    );

    blocTest<AuthBloc, AuthState>(
      'AuthStarted sin usuario emite no autenticado',
      build: () => AuthBloc(
        repository: FakeAuthRepository(stream: Stream<AuthUser?>.value(null)),
      ),
      act: (bloc) => bloc.add(const AuthStarted()),
      expect: () => [const AuthLoading(), const AuthUnauthenticated()],
    );

    blocTest<AuthBloc, AuthState>(
      'el inicio de sesión correcto emite carga y usuario',
      build: () =>
          AuthBloc(repository: FakeAuthRepository(signInResult: _user)),
      act: (bloc) => bloc.add(
        const AuthLoginRequested(
          email: 'estudiante@unsaac.edu.pe',
          password: 'wallet123',
        ),
      ),
      expect: () => [const AuthLoading(), const AuthAuthenticated(_user)],
    );

    blocTest<AuthBloc, AuthState>(
      'el inicio de sesión fallido emite el mensaje estable',
      build: () => AuthBloc(
        repository: FakeAuthRepository()
          ..signInError = const AuthException(
            AuthFailureReason.invalidCredentials,
            AuthMessages.invalidCredentials,
          ),
      ),
      act: (bloc) => bloc.add(
        const AuthLoginRequested(
          email: 'estudiante@unsaac.edu.pe',
          password: 'incorrecta',
        ),
      ),
      expect: () => [
        const AuthLoading(),
        const AuthUnauthenticated(message: AuthMessages.invalidCredentials),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'el registro correcto emite carga y usuario',
      build: () =>
          AuthBloc(repository: FakeAuthRepository(registerResult: _user)),
      act: (bloc) => bloc.add(
        const AuthRegisterRequested(
          email: 'estudiante@unsaac.edu.pe',
          password: 'wallet123',
        ),
      ),
      expect: () => [const AuthLoading(), const AuthAuthenticated(_user)],
    );

    blocTest<AuthBloc, AuthState>(
      'el registro con correo existente emite el error de dominio',
      build: () => AuthBloc(
        repository: FakeAuthRepository()
          ..registerError = const AuthException(
            AuthFailureReason.emailAlreadyInUse,
            AuthMessages.emailAlreadyInUse,
          ),
      ),
      act: (bloc) => bloc.add(
        const AuthRegisterRequested(
          email: 'estudiante@unsaac.edu.pe',
          password: 'wallet123',
        ),
      ),
      expect: () => [
        const AuthLoading(),
        const AuthUnauthenticated(message: AuthMessages.emailAlreadyInUse),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'el cierre de sesión limpia el usuario',
      build: () => AuthBloc(repository: FakeAuthRepository(user: _user)),
      seed: () => const AuthAuthenticated(_user),
      act: (bloc) => bloc.add(const AuthLogoutRequested()),
      expect: () => [const AuthLoading(), const AuthUnauthenticated()],
    );

    blocTest<AuthBloc, AuthState>(
      'si falla el cierre, conserva la sesión y muestra el mensaje',
      build: () => AuthBloc(
        repository: FakeAuthRepository(user: _user)
          ..signOutError = const AuthException(
            AuthFailureReason.network,
            AuthMessages.network,
          ),
      ),
      seed: () => const AuthAuthenticated(_user),
      act: (bloc) => bloc.add(const AuthLogoutRequested()),
      expect: () => [
        const AuthLoading(),
        const AuthAuthenticated(_user, message: AuthMessages.network),
      ],
    );
  });
}

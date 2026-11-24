import 'dart:async';

import 'package:wallet_unsaac/core/config/demo_credentials.dart';
import 'package:wallet_unsaac/features/auth/domain/entities/auth_user.dart';
import 'package:wallet_unsaac/features/auth/domain/failures/auth_failure.dart';
import 'package:wallet_unsaac/features/auth/domain/repositories/auth_repository.dart';

/// Implementación de demostración para el modo local.
///
/// Se usa solo cuando Firebase no está configurado. Guarda las contraseñas en
/// memoria y las pierde al cerrar la app: no es un sistema de autenticación de
/// producción. Permite que el taller y la demo funcionen sin conectividad.
class InMemoryAuthRepository implements AuthRepository {
  InMemoryAuthRepository({this.latency = const Duration(milliseconds: 250)}) {
    final demo = AuthUser(
      uid: 'local-demo',
      email: DemoCredentials.email,
      displayName: 'Estudiante UNSAAC',
    );
    _users[demo.email] = demo;
    _passwords[demo.email] = DemoCredentials.password;
  }

  final Duration latency;
  final Map<String, AuthUser> _users = <String, AuthUser>{};
  final Map<String, String> _passwords = <String, String>{};
  final StreamController<AuthUser?> _changes =
      StreamController<AuthUser?>.broadcast();

  AuthUser? _currentUser;

  @override
  AuthUser? get currentUser => _currentUser;

  @override
  Stream<AuthUser?> authStateChanges() async* {
    yield _currentUser;
    yield* _changes.stream;
  }

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    await _simulateNetwork();
    final key = _normalize(email);
    final user = _users[key];
    if (user == null || _passwords[key] != password) {
      throw const AuthException(
        AuthFailureReason.invalidCredentials,
        AuthMessages.invalidCredentials,
      );
    }
    _currentUser = user;
    _changes.add(user);
    return user;
  }

  @override
  Future<AuthUser> register({
    required String email,
    required String password,
  }) async {
    await _simulateNetwork();
    final key = _normalize(email);
    if (_users.containsKey(key)) {
      throw const AuthException(
        AuthFailureReason.emailAlreadyInUse,
        AuthMessages.emailAlreadyInUse,
      );
    }
    if (password.length < 6) {
      throw const AuthException(
        AuthFailureReason.weakPassword,
        AuthMessages.weakPassword,
      );
    }
    final user = AuthUser(uid: 'local-${_users.length + 1}', email: key);
    _users[key] = user;
    _passwords[key] = password;
    _currentUser = user;
    _changes.add(user);
    return user;
  }

  @override
  Future<void> signOut() async {
    await _simulateNetwork();
    _currentUser = null;
    _changes.add(null);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    // Modo local: solo simula el envío. No revela si el correo existe.
    await _simulateNetwork();
  }

  @override
  Future<AuthUser> updateDisplayName(String name) async {
    await _simulateNetwork();
    final current = _currentUser;
    if (current == null) {
      throw const AuthException(
        AuthFailureReason.unknown,
        AuthMessages.unknown,
      );
    }
    final updated = current.copyWith(displayName: name.trim());
    _currentUser = updated;
    _users[current.email] = updated;
    _changes.add(updated);
    return updated;
  }

  String _normalize(String email) => email.trim().toLowerCase();

  Future<void> _simulateNetwork() async {
    if (latency > Duration.zero) {
      await Future<void>.delayed(latency);
    }
  }
}

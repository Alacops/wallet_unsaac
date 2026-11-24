import 'package:wallet_unsaac/features/auth/domain/entities/auth_user.dart';
import 'package:wallet_unsaac/features/auth/domain/failures/auth_failure.dart';
import 'package:wallet_unsaac/features/auth/domain/repositories/auth_repository.dart';

/// Repositorio de autenticación falso para las pruebas.
///
/// Permite controlar el usuario actual, el stream de sesión y los resultados
/// o errores de cada operación, sin depender de Firebase ni de la red.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({
    AuthUser? user,
    this.stream,
    this.signInResult,
    this.registerResult,
  }) : _currentUser = user;

  final Stream<AuthUser?>? stream;
  AuthUser? _currentUser;

  AuthUser? signInResult;
  AuthUser? registerResult;
  AuthException? signInError;
  AuthException? registerError;
  AuthException? signOutError;
  AuthException? resetError;
  int resetCalls = 0;

  @override
  AuthUser? get currentUser => _currentUser;

  @override
  Stream<AuthUser?> authStateChanges() =>
      stream ?? Stream<AuthUser?>.value(_currentUser);

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    if (signInError != null) throw signInError!;
    final user =
        signInResult ?? _currentUser ?? AuthUser(uid: 'uid-fake', email: email);
    _currentUser = user;
    return user;
  }

  @override
  Future<AuthUser> register({
    required String email,
    required String password,
  }) async {
    if (registerError != null) throw registerError!;
    final user = registerResult ?? AuthUser(uid: 'uid-fake', email: email);
    _currentUser = user;
    return user;
  }

  @override
  Future<void> signOut() async {
    if (signOutError != null) throw signOutError!;
    _currentUser = null;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    resetCalls++;
    if (resetError != null) throw resetError!;
  }
}

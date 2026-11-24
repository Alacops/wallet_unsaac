import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:wallet_unsaac/features/auth/data/mappers/firebase_auth_error_mapper.dart';
import 'package:wallet_unsaac/features/auth/domain/entities/auth_user.dart';
import 'package:wallet_unsaac/features/auth/domain/failures/auth_failure.dart';
import 'package:wallet_unsaac/features/auth/domain/repositories/auth_repository.dart';

/// Implementación real sobre Firebase Authentication.
///
/// El resto de la aplicación no importa `firebase_auth`: solo ve el contrato
/// [AuthRepository]. Esta clase traduce usuarios, credenciales y errores.
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({fb.FirebaseAuth? auth})
      : _auth = auth ?? fb.FirebaseAuth.instance;

  final fb.FirebaseAuth _auth;

  @override
  AuthUser? get currentUser => _toAuthUser(_auth.currentUser);

  @override
  Stream<AuthUser?> authStateChanges() {
    return _auth.authStateChanges().map(_toAuthUser);
  }

  @override
  Future<AuthUser> signIn({required String email, required String password}) {
    return _authenticate(
      () => _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      ),
    );
  }

  @override
  Future<AuthUser> register({required String email, required String password}) {
    return _authenticate(
      () => _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      ),
    );
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on fb.FirebaseAuthException catch (error) {
      throw mapFirebaseAuthException(error);
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on fb.FirebaseAuthException catch (error) {
      throw mapFirebaseAuthException(error);
    }
  }

  Future<AuthUser> _authenticate(
    Future<fb.UserCredential> Function() action,
  ) async {
    try {
      final credential = await action();
      final user = credential.user;
      if (user == null) {
        throw const AuthException(
          AuthFailureReason.unknown,
          AuthMessages.unknown,
        );
      }
      return _toAuthUser(user)!;
    } on fb.FirebaseAuthException catch (error) {
      throw mapFirebaseAuthException(error);
    }
  }

  AuthUser? _toAuthUser(fb.User? user) {
    if (user == null) return null;
    return AuthUser(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
    );
  }
}

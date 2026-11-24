import 'package:wallet_unsaac/features/auth/domain/entities/auth_user.dart';

/// Contrato de autenticación.
///
/// La presentación y el dominio dependen de esta abstracción. La implementación
/// con Firebase vive en `data/`; el modo local usa una implementación en
/// memoria con las mismas reglas.
abstract interface class AuthRepository {
  /// Usuario actual, o `null` si no hay sesión.
  AuthUser? get currentUser;

  /// Emite el estado actual y luego cada cambio de sesión.
  Stream<AuthUser?> authStateChanges();

  /// Inicia sesión con correo y contraseña.
  Future<AuthUser> signIn({required String email, required String password});

  /// Registra una cuenta nueva con correo y contraseña.
  Future<AuthUser> register({required String email, required String password});

  /// Cierra la sesión actual.
  Future<void> signOut();
}

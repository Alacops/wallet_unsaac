import 'package:firebase_auth/firebase_auth.dart';
import 'package:wallet_unsaac/features/auth/domain/failures/auth_failure.dart';

/// Traduce un código de Firebase Auth a un fallo de dominio.
///
/// La documentación del SDK indica que `code` no lleva el prefijo `auth/` ni
/// `ERROR_`. Los códigos desconocidos se agrupan en [AuthFailureReason.unknown]
/// para no filtrar detalles internos a la interfaz.
AuthException mapFirebaseAuthException(FirebaseAuthException error) {
  final reason = switch (error.code) {
    'invalid-email' => AuthFailureReason.invalidEmail,
    'user-disabled' => AuthFailureReason.userDisabled,
    'user-not-found' ||
    'wrong-password' ||
    'invalid-credential' =>
      AuthFailureReason.invalidCredentials,
    'email-already-in-use' => AuthFailureReason.emailAlreadyInUse,
    'weak-password' => AuthFailureReason.weakPassword,
    'operation-not-allowed' => AuthFailureReason.operationNotAllowed,
    'too-many-requests' => AuthFailureReason.tooManyRequests,
    'network-request-failed' => AuthFailureReason.network,
    _ => AuthFailureReason.unknown,
  };

  return AuthException(reason, AuthMessages.forReason(reason));
}

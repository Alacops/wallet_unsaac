import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_unsaac/features/auth/data/mappers/firebase_auth_error_mapper.dart';
import 'package:wallet_unsaac/features/auth/domain/failures/auth_failure.dart';

AuthException _map(String code) =>
    mapFirebaseAuthException(FirebaseAuthException(code: code));

void main() {
  group('mapFirebaseAuthException', () {
    test('traduce códigos conocidos a su motivo y mensaje', () {
      expect(_map('invalid-email').reason, AuthFailureReason.invalidEmail);
      expect(
        _map('email-already-in-use').reason,
        AuthFailureReason.emailAlreadyInUse,
      );
      expect(
        _map('operation-not-allowed').reason,
        AuthFailureReason.operationNotAllowed,
      );
      expect(_map('weak-password').message, AuthMessages.weakPassword);
    });

    test('user-not-found y wrong-password dan el mismo mensaje genérico', () {
      final notFound = _map('user-not-found');
      final wrongPassword = _map('wrong-password');
      expect(notFound.reason, AuthFailureReason.invalidCredentials);
      expect(wrongPassword.reason, AuthFailureReason.invalidCredentials);
      expect(notFound.message, wrongPassword.message);
      expect(notFound.message, AuthMessages.invalidCredentials);
    });

    test('un código desconocido se agrupa en unknown', () {
      final result = _map('algo-inesperado');
      expect(result.reason, AuthFailureReason.unknown);
      expect(result.message, AuthMessages.unknown);
    });
  });
}

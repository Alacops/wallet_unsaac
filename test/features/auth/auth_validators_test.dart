import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_unsaac/features/auth/presentation/utils/auth_validators.dart';

void main() {
  group('AuthValidators.email', () {
    test('rechaza vacío y formato inválido, acepta válido', () {
      expect(AuthValidators.email(''), 'Ingresa tu correo.');
      expect(AuthValidators.email('sin-arroba'), 'Ingresa un correo válido.');
      expect(AuthValidators.email('estudiante@unsaac.edu.pe'), isNull);
    });
  });

  group('AuthValidators.password', () {
    test('rechaza vacío y corto, acepta 6+ caracteres', () {
      expect(AuthValidators.password(''), 'Ingresa tu contraseña.');
      expect(AuthValidators.password('123'), 'Usa al menos 6 caracteres.');
      expect(AuthValidators.password('wallet123'), isNull);
    });
  });

  group('AuthValidators.confirmPassword', () {
    test('exige coincidencia con la contraseña', () {
      expect(
        AuthValidators.confirmPassword('', 'wallet123'),
        'Confirma tu contraseña.',
      );
      expect(
        AuthValidators.confirmPassword('wallet124', 'wallet123'),
        'Las contraseñas no coinciden.',
      );
      expect(
        AuthValidators.confirmPassword('wallet123', 'wallet123'),
        isNull,
      );
    });
  });
}

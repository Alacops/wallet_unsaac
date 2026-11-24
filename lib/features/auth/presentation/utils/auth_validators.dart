/// Validaciones compartidas por los formularios de acceso.
abstract final class AuthValidators {
  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? email(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Ingresa tu correo.';
    if (!_emailPattern.hasMatch(email)) return 'Ingresa un correo válido.';
    return null;
  }

  static String? password(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Ingresa tu contraseña.';
    if (password.length < 6) return 'Usa al menos 6 caracteres.';
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    final confirmation = value ?? '';
    if (confirmation.isEmpty) return 'Confirma tu contraseña.';
    if (confirmation != password) return 'Las contraseñas no coinciden.';
    return null;
  }
}

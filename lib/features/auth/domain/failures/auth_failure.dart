/// Motivos de fallo que la interfaz puede distinguir.
enum AuthFailureReason {
  invalidEmail,
  invalidCredentials,
  userDisabled,
  emailAlreadyInUse,
  weakPassword,
  operationNotAllowed,
  tooManyRequests,
  network,
  unknown,
}

/// Excepción de dominio de autenticación.
///
/// La capa de datos traduce los códigos del SDK a un motivo y a un mensaje
/// estable. El bloc nunca muestra el código original de Firebase.
class AuthException implements Exception {
  const AuthException(this.reason, this.message);

  final AuthFailureReason reason;
  final String message;

  @override
  String toString() => 'AuthException(${reason.name}): $message';
}

/// Mensajes estables para el usuario.
abstract final class AuthMessages {
  static const String invalidEmail = 'El correo no tiene un formato válido.';
  static const String invalidCredentials = 'Correo o contraseña incorrectos.';
  static const String userDisabled =
      'Esta cuenta está deshabilitada. Contacta al administrador.';
  static const String emailAlreadyInUse =
      'Ya existe una cuenta con este correo.';
  static const String weakPassword =
      'La contraseña es demasiado débil. Usa al menos 6 caracteres.';
  static const String operationNotAllowed =
      'El acceso con correo y contraseña no está habilitado en Firebase.';
  static const String tooManyRequests =
      'Demasiados intentos. Espera unos minutos y vuelve a intentarlo.';
  static const String network =
      'No se pudo conectar. Revisa tu conexión a Internet.';
  static const String unknown =
      'Ocurrió un error inesperado. Inténtalo de nuevo.';

  /// Mensaje de expiración de sesión (Reto 3). No corresponde a un código de
  /// Firebase: lo produce la app cuando la sesión desaparece sin un cierre
  /// voluntario.
  static const String sessionExpired =
      'Tu sesión expiró. Vuelve a iniciar sesión.';

  static String forReason(AuthFailureReason reason) => switch (reason) {
        AuthFailureReason.invalidEmail => invalidEmail,
        AuthFailureReason.invalidCredentials => invalidCredentials,
        AuthFailureReason.userDisabled => userDisabled,
        AuthFailureReason.emailAlreadyInUse => emailAlreadyInUse,
        AuthFailureReason.weakPassword => weakPassword,
        AuthFailureReason.operationNotAllowed => operationNotAllowed,
        AuthFailureReason.tooManyRequests => tooManyRequests,
        AuthFailureReason.network => network,
        AuthFailureReason.unknown => unknown,
      };
}

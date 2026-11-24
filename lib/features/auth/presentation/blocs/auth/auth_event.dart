import 'package:equatable/equatable.dart';

/// Intenciones del flujo de autenticación.
sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => const [];
}

/// Pide observar el estado de sesión y escuchar sus cambios.
final class AuthStarted extends AuthEvent {
  const AuthStarted();
}

/// Pide iniciar sesión con correo y contraseña.
final class AuthLoginRequested extends AuthEvent {
  const AuthLoginRequested({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

/// Pide registrar una cuenta nueva.
final class AuthRegisterRequested extends AuthEvent {
  const AuthRegisterRequested({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

/// Pide cerrar la sesión actual.
final class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

/// Pide enviar un correo para restablecer la contraseña (Reto 1).
final class AuthPasswordResetRequested extends AuthEvent {
  const AuthPasswordResetRequested(this.email);

  final String email;

  @override
  List<Object?> get props => [email];
}

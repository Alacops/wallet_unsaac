import 'package:equatable/equatable.dart';
import 'package:wallet_unsaac/features/auth/domain/entities/auth_user.dart';

/// Estados del flujo de autenticación.
sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => const [];
}

/// Todavía no se pidió observar la sesión.
final class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Hay una operación de autenticación en curso.
final class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Hay una sesión activa.
final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user, {this.message});

  final AuthUser user;

  /// Mensaje opcional, por ejemplo cuando falla el cierre de sesión.
  final String? message;

  @override
  List<Object?> get props => [user, message];
}

/// No hay sesión activa. [message] explica el último fallo, si existe.
final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated({this.message});

  final String? message;

  @override
  List<Object?> get props => [message];
}

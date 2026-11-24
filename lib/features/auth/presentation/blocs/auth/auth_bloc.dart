import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet_unsaac/features/auth/domain/entities/auth_user.dart';
import 'package:wallet_unsaac/features/auth/domain/failures/auth_failure.dart';
import 'package:wallet_unsaac/features/auth/domain/repositories/auth_repository.dart';
import 'package:wallet_unsaac/features/auth/presentation/blocs/auth/auth_event.dart';
import 'package:wallet_unsaac/features/auth/presentation/blocs/auth/auth_state.dart';

/// Bloc que gobierna la sesión del usuario.
///
/// Escucha el stream del repositorio para reflejar la sesión persistida y
/// traduce las operaciones de acceso a estados que la interfaz puede mostrar.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required this.repository}) : super(const AuthInitial()) {
    on<AuthStarted>(_onStarted);
    on<AuthLoginRequested>(_onLogin);
    on<AuthRegisterRequested>(_onRegister);
    on<AuthLogoutRequested>(_onLogout);
    on<AuthPasswordResetRequested>(_onPasswordReset);
  }

  final AuthRepository repository;

  /// Mensaje genérico de recuperación (Reto 1). No revela si el correo existe.
  static const String resetEmailSentMessage =
      'Si el correo está registrado, te enviamos un enlace para restablecer la '
      'contraseña.';

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      await emit.forEach<AuthUser?>(
        repository.authStateChanges(),
        onData: _stateForUser,
      );
    } on AuthException catch (error) {
      if (emit.isDone) return;
      emit(AuthUnauthenticated(message: error.message));
    } on Exception {
      if (emit.isDone) return;
      emit(const AuthUnauthenticated(message: AuthMessages.network));
    }
  }

  Future<void> _onLogin(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state is AuthLoading) return;
    emit(const AuthLoading());
    try {
      final user = await repository.signIn(
        email: event.email,
        password: event.password,
      );
      if (emit.isDone) return;
      emit(AuthAuthenticated(user));
    } on AuthException catch (error) {
      if (emit.isDone) return;
      emit(AuthUnauthenticated(message: error.message));
    } on Exception {
      if (emit.isDone) return;
      emit(const AuthUnauthenticated(message: AuthMessages.unknown));
    }
  }

  Future<void> _onRegister(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state is AuthLoading) return;
    emit(const AuthLoading());
    try {
      final user = await repository.register(
        email: event.email,
        password: event.password,
      );
      if (emit.isDone) return;
      emit(AuthAuthenticated(user));
    } on AuthException catch (error) {
      if (emit.isDone) return;
      emit(AuthUnauthenticated(message: error.message));
    } on Exception {
      if (emit.isDone) return;
      emit(const AuthUnauthenticated(message: AuthMessages.unknown));
    }
  }

  Future<void> _onLogout(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state is AuthLoading) return;
    final previous = state;
    emit(const AuthLoading());
    try {
      await repository.signOut();
      if (emit.isDone) return;
      emit(const AuthUnauthenticated());
    } on AuthException catch (error) {
      _restoreAfterLogoutFailure(emit, previous, error.message);
    } on Exception {
      _restoreAfterLogoutFailure(emit, previous, AuthMessages.unknown);
    }
  }

  Future<void> _onPasswordReset(
    AuthPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await repository.sendPasswordResetEmail(event.email);
      if (emit.isDone) return;
      emit(const AuthUnauthenticated(message: resetEmailSentMessage));
    } on AuthException catch (error) {
      if (emit.isDone) return;
      // Solo un fallo de red se distingue; los demás no revelan si el correo
      // está registrado, para no enumerar cuentas.
      final message = error.reason == AuthFailureReason.network
          ? error.message
          : resetEmailSentMessage;
      emit(AuthUnauthenticated(message: message));
    } on Exception {
      if (emit.isDone) return;
      emit(const AuthUnauthenticated(message: resetEmailSentMessage));
    }
  }

  AuthState _stateForUser(AuthUser? user) {
    return user == null
        ? const AuthUnauthenticated()
        : AuthAuthenticated(user);
  }

  void _restoreAfterLogoutFailure(
    Emitter<AuthState> emit,
    AuthState previous,
    String message,
  ) {
    if (emit.isDone) return;
    if (previous is AuthAuthenticated) {
      emit(AuthAuthenticated(previous.user, message: message));
    } else {
      emit(AuthUnauthenticated(message: message));
    }
  }
}

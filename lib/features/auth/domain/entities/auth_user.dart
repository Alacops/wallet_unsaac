import 'package:equatable/equatable.dart';

/// Identidad mínima del usuario autenticado. No conoce Firebase: es una
/// entidad propia del dominio, de modo que el resto de la app no dependa del
/// SDK. Implementa [Equatable] para que los estados comparen por valor.
class AuthUser extends Equatable {
  const AuthUser({
    required this.uid,
    required this.email,
    this.displayName,
  });

  final String uid;
  final String email;
  final String? displayName;

  /// Devuelve una copia con el [displayName] cambiado (Reto 2). El [uid] y el
  /// [email] no cambian: siguen identificando a la misma cuenta.
  AuthUser copyWith({String? displayName}) {
    return AuthUser(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
    );
  }

  @override
  List<Object?> get props => [uid, email, displayName];
}

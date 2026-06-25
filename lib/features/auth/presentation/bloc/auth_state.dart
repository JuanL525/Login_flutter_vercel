import 'package:equatable/equatable.dart';
import '../../domain/entities/session_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Sesion activa y password ya definitiva: acceso permitido.
class AuthAuthenticated extends AuthState {
  final SessionEntity session;
  const AuthAuthenticated(this.session);
  @override
  List<Object?> get props => [session];
}

/// Sesion activa pero debe cambiar la contrasena antes de continuar.
class AuthMustChangePassword extends AuthState {
  final SessionEntity session;
  const AuthMustChangePassword(this.session);
  @override
  List<Object?> get props => [session];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object?> get props => [message];
}

class ResetPasswordSent extends AuthState {
  const ResetPasswordSent();
}

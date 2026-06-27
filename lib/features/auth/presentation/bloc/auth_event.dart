import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class SignInRequested extends AuthEvent {
  final String cedula;
  final String password;
  const SignInRequested({required this.cedula, required this.password});
  @override
  List<Object?> get props => [cedula, password];
}

class ResetPasswordRequested extends AuthEvent {
  final String email;
  const ResetPasswordRequested({required this.email});
  @override
  List<Object?> get props => [email];
}

class ChangePasswordRequested extends AuthEvent {
  final String newPassword;
  const ChangePasswordRequested({required this.newPassword});
  @override
  List<Object?> get props => [newPassword];
}

class SignOutRequested extends AuthEvent {
  const SignOutRequested();
}

/// Limpia el estado de error tras mostrarlo al usuario.
class AuthErrorDismissed extends AuthEvent {
  const AuthErrorDismissed();
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/session_entity.dart';
import '../../domain/usecases/change_password.dart';
import '../../domain/usecases/get_current_session.dart';
import '../../domain/usecases/reset_password.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_out.dart';
import 'auth_event.dart';
import 'auth_state.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignIn signIn;
  final SignOut signOut;
  final ResetPassword resetPassword;
  final ChangePassword changePassword;
  final GetCurrentSession getCurrentSession;

  AuthBloc({
    required this.signIn,
    required this.signOut,
    required this.resetPassword,
    required this.changePassword,
    required this.getCurrentSession,
  }) : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheck);
    on<SignInRequested>(_onSignIn);
    on<ResetPasswordRequested>(_onReset);
    on<ChangePasswordRequested>(_onChangePassword);
    on<SignOutRequested>(_onSignOut);
    on<AuthErrorDismissed>(_onDismissError);
  }

  AuthState _resolve(SessionEntity session) {
    if (session.profile.mustChangePassword) {
      return AuthMustChangePassword(session);
    }
    return AuthAuthenticated(session);
  }

  Future<void> _onCheck(AuthCheckRequested e, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await getCurrentSession(NoParams());
    result.fold(
      (_) => emit(const AuthUnauthenticated()),
      (session) => emit(
        session == null ? const AuthUnauthenticated() : _resolve(session),
      ),
    );
  }

  Future<void> _onSignIn(SignInRequested e, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await signIn(
      SignInParams(cedula: e.cedula, password: e.password),
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (session) => emit(_resolve(session)),
    );
  }

  Future<void> _onReset(
    ResetPasswordRequested e,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await resetPassword(ResetPasswordParams(email: e.email));
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const ResetPasswordSent()),
    );
  }

  Future<void> _onChangePassword(
    ChangePasswordRequested e,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await changePassword(
      ChangePasswordParams(newPassword: e.newPassword),
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (session) => emit(AuthAuthenticated(session)),
    );
  }

  Future<void> _onSignOut(SignOutRequested e, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await signOut(NoParams());
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const AuthUnauthenticated()),
    );
  }

  void _onDismissError(AuthErrorDismissed e, Emitter<AuthState> emit) {
    emit(const AuthUnauthenticated());
  }
}

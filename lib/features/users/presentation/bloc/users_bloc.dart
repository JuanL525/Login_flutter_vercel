import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/constants/enums.dart';
import '../../domain/usecases/create_user.dart';

// ----- Eventos -----
abstract class UsersEvent extends Equatable {
  const UsersEvent();
  @override
  List<Object?> get props => [];
}

class CreateUserRequested extends UsersEvent {
  final String cedula;
  final String nombres;
  final String apellidos;
  final String telefono;
  final String email;
  final UserRole role;
  final String? recintoId;

  const CreateUserRequested({
    required this.cedula,
    required this.nombres,
    required this.apellidos,
    required this.telefono,
    required this.email,
    required this.role,
    this.recintoId,
  });

  @override
  List<Object?> get props =>
      [cedula, nombres, apellidos, telefono, email, role, recintoId];
}

// ----- Estados -----
abstract class UsersState extends Equatable {
  const UsersState();
  @override
  List<Object?> get props => [];
}

class UsersInitial extends UsersState {
  const UsersInitial();
}

class UsersLoading extends UsersState {
  const UsersLoading();
}

class UserCreatedSuccess extends UsersState {
  const UserCreatedSuccess();
}

class UsersError extends UsersState {
  final String message;
  const UsersError(this.message);
  @override
  List<Object?> get props => [message];
}

@injectable
class UsersBloc extends Bloc<UsersEvent, UsersState> {
  final CreateUser createUser;

  UsersBloc({required this.createUser}) : super(const UsersInitial()) {
    on<CreateUserRequested>(_onCreate);
  }

  Future<void> _onCreate(
    CreateUserRequested e,
    Emitter<UsersState> emit,
  ) async {
    emit(const UsersLoading());
    final result = await createUser(
      CreateUserParams(
        cedula: e.cedula,
        nombres: e.nombres,
        apellidos: e.apellidos,
        telefono: e.telefono,
        email: e.email,
        role: e.role,
        recintoId: e.recintoId,
      ),
    );
    result.fold(
      (failure) => emit(UsersError(failure.message)),
      (_) => emit(const UserCreatedSuccess()),
    );
  }
}

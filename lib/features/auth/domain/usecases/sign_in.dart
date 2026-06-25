import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/session_entity.dart';
import '../repositories/auth_repository.dart';

@injectable
class SignIn implements UseCase<SessionEntity, SignInParams> {
  final AuthRepository repository;
  SignIn(this.repository);

  @override
  Future<Either<Failure, SessionEntity>> call(SignInParams params) {
    return repository.signInWithCedula(
      cedula: params.cedula,
      password: params.password,
    );
  }
}

class SignInParams extends Equatable {
  final String cedula;
  final String password;
  const SignInParams({required this.cedula, required this.password});

  @override
  List<Object> get props => [cedula, password];
}

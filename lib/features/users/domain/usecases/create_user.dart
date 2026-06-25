import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/validators/cedula_validator.dart';
import '../repositories/users_repository.dart';

@injectable
class CreateUser implements UseCase<void, CreateUserParams> {
  final UsersRepository repository;
  CreateUser(this.repository);

  @override
  Future<Either<Failure, void>> call(CreateUserParams params) async {
    // Validacion de cedula en el cliente (el Edge Function la repite).
    if (!CedulaValidator.isValid(params.cedula)) {
      return const Left(ValidationFailure('La cedula ingresada no es valida'));
    }
    return repository.createUser(
      cedula: params.cedula,
      nombres: params.nombres,
      apellidos: params.apellidos,
      telefono: params.telefono,
      email: params.email,
      role: params.role,
      recintoId: params.recintoId,
    );
  }
}

class CreateUserParams {
  final String cedula;
  final String nombres;
  final String apellidos;
  final String telefono;
  final String email;
  final UserRole role;
  final String? recintoId;

  CreateUserParams({
    required this.cedula,
    required this.nombres,
    required this.apellidos,
    required this.telefono,
    required this.email,
    required this.role,
    this.recintoId,
  });
}

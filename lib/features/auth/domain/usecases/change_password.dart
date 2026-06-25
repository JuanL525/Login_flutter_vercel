import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/session_entity.dart';
import '../repositories/auth_repository.dart';

@injectable
class ChangePassword implements UseCase<SessionEntity, ChangePasswordParams> {
  final AuthRepository repository;
  ChangePassword(this.repository);

  @override
  Future<Either<Failure, SessionEntity>> call(ChangePasswordParams params) {
    return repository.changePassword(newPassword: params.newPassword);
  }
}

class ChangePasswordParams {
  final String newPassword;
  ChangePasswordParams({required this.newPassword});
}

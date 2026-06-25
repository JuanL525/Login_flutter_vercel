import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/session_entity.dart';
import '../repositories/auth_repository.dart';

@injectable
class GetCurrentSession implements UseCase<SessionEntity?, NoParams> {
  final AuthRepository repository;
  GetCurrentSession(this.repository);

  @override
  Future<Either<Failure, SessionEntity?>> call(NoParams params) {
    return repository.getCurrentSession();
  }
}

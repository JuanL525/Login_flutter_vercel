import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/profile_entity.dart';
import '../repositories/users_repository.dart';

@injectable
class GetVeedores implements UseCase<List<ProfileEntity>, String> {
  final UsersRepository repository;
  GetVeedores(this.repository);

  @override
  Future<Either<Failure, List<ProfileEntity>>> call(String recintoId) {
    return repository.getVeedoresByRecinto(recintoId);
  }
}

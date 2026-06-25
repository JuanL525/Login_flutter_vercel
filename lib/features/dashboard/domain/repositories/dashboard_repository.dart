import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/recinto_avance.dart';

abstract class DashboardRepository {
  Future<Either<Failure, List<RecintoAvance>>> getProvincialAvance();
}

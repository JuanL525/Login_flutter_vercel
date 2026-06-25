import 'package:injectable/injectable.dart';
import '../repositories/actas_repository.dart';

@injectable
class GetPhotoUrl {
  final ActasRepository repository;
  GetPhotoUrl(this.repository);

  Future<String?> call(String path) => repository.getPhotoUrl(path);
}

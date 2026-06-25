import '../../../../core/constants/enums.dart';
import '../../domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.id,
    required super.cedula,
    required super.nombres,
    required super.apellidos,
    required super.telefono,
    required super.email,
    required super.role,
    required super.mustChangePassword,
    super.recintoId,
    super.createdAt,
  });

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      id: map['id'] as String,
      cedula: map['cedula'] as String,
      nombres: map['nombres'] as String,
      apellidos: map['apellidos'] as String,
      telefono: map['telefono'] as String,
      email: map['email'] as String,
      role: UserRole.fromDb(map['role'] as String),
      mustChangePassword: map['must_change_password'] as bool? ?? false,
      recintoId: map['recinto_id'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String)
          : null,
    );
  }
}

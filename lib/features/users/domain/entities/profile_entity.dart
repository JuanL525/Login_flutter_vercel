import 'package:equatable/equatable.dart';
import '../../../../core/constants/enums.dart';

class ProfileEntity extends Equatable {
  final String id;
  final String cedula;
  final String nombres;
  final String apellidos;
  final String telefono;
  final String email;
  final UserRole role;
  final bool mustChangePassword;
  final String? recintoId;
  final DateTime? createdAt;

  const ProfileEntity({
    required this.id,
    required this.cedula,
    required this.nombres,
    required this.apellidos,
    required this.telefono,
    required this.email,
    required this.role,
    required this.mustChangePassword,
    this.recintoId,
    this.createdAt,
  });

  String get nombreCompleto => '$nombres $apellidos';

  @override
  List<Object?> get props => [
        id,
        cedula,
        nombres,
        apellidos,
        telefono,
        email,
        role,
        mustChangePassword,
        recintoId,
        createdAt,
      ];
}

import 'package:equatable/equatable.dart';
import '../../../users/domain/entities/profile_entity.dart';

/// Sesion autenticada: identidad de Supabase + perfil de dominio.
class SessionEntity extends Equatable {
  final ProfileEntity profile;

  const SessionEntity({required this.profile});

  @override
  List<Object?> get props => [profile];
}

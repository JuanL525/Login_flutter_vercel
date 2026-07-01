import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/utils/user_error_message.dart';
import '../models/profile_model.dart';

abstract class UsersRemoteDataSource {
  Future<void> createUser({
    required String cedula,
    required String nombres,
    required String apellidos,
    required String telefono,
    required String email,
    required UserRole role,
    String? recintoId,
  });

  Future<List<ProfileModel>> getVeedoresByRecinto(String recintoId);

  /// Coordinadores de recinto sin recinto asignado (recinto_id IS NULL).
  Future<List<ProfileModel>> getCoordinadoresSinRecinto();

  /// Asigna un coordinador libre a un recinto sin coordinador.
  /// Falla si el recinto ya tiene coordinador o si el coordinador ya tiene recinto.
  Future<void> assignCoordinadorToRecinto({
    required String coordinadorId,
    required String recintoId,
  });
}

@LazySingleton(as: UsersRemoteDataSource)
class UsersRemoteDataSourceImpl implements UsersRemoteDataSource {
  final SupabaseClient supabaseClient;
  UsersRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<void> createUser({
    required String cedula,
    required String nombres,
    required String apellidos,
    required String telefono,
    required String email,
    required UserRole role,
    String? recintoId,
  }) async {
    try {
      await supabaseClient.functions.invoke(
        'create-user',
        body: {
          'cedula': cedula,
          'nombres': nombres,
          'apellidos': apellidos,
          'telefono': telefono,
          'email': email,
          'role': role.dbValue,
          if (recintoId != null) 'recinto_id': recintoId,
        },
      );
    } on FunctionException catch (e) {
      throw Exception(humanizeError(e));
    }
  }

  @override
  Future<List<ProfileModel>> getVeedoresByRecinto(String recintoId) async {
    final rows = await supabaseClient
        .from('profiles')
        .select()
        .eq('recinto_id', recintoId)
        .eq('role', UserRole.veedor.dbValue)
        .order('apellidos');
    return (rows as List)
        .map((e) => ProfileModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<ProfileModel>> getCoordinadoresSinRecinto() async {
    final rows = await supabaseClient
        .from('profiles')
        .select()
        .eq('role', UserRole.recinto.dbValue)
        .isFilter('recinto_id', null)
        .order('apellidos');
    return (rows as List)
        .map((e) => ProfileModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> assignCoordinadorToRecinto({
    required String coordinadorId,
    required String recintoId,
  }) async {
    final recintoRow = await supabaseClient
        .from('recintos')
        .select('coordinador_id')
        .eq('id', recintoId)
        .single();
    if (recintoRow['coordinador_id'] != null) {
      throw Exception('Este recinto ya tiene un coordinador asignado');
    }

    final coordRow = await supabaseClient
        .from('profiles')
        .select('recinto_id, role')
        .eq('id', coordinadorId)
        .single();
    if (coordRow['role'] != UserRole.recinto.dbValue) {
      throw Exception('El usuario seleccionado no es coordinador de recinto');
    }
    if (coordRow['recinto_id'] != null) {
      throw Exception('Este coordinador ya esta asignado a otro recinto');
    }

    final assigned = await supabaseClient
        .from('recintos')
        .update({'coordinador_id': coordinadorId})
        .eq('id', recintoId)
        .isFilter('coordinador_id', null)
        .select('id')
        .maybeSingle();
    if (assigned == null) {
      throw Exception('Este recinto ya tiene un coordinador asignado');
    }

    final profileUpdated = await supabaseClient
        .from('profiles')
        .update({'recinto_id': recintoId})
        .eq('id', coordinadorId)
        .isFilter('recinto_id', null)
        .select('id')
        .maybeSingle();
    if (profileUpdated == null) {
      await supabaseClient
          .from('recintos')
          .update({'coordinador_id': null})
          .eq('id', recintoId);
      throw Exception('Este coordinador ya esta asignado a otro recinto');
    }
  }
}

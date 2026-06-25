import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/enums.dart';
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
    final response = await supabaseClient.functions.invoke(
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

    if (response.status >= 400) {
      final data = response.data;
      final message = (data is Map && data['error'] != null)
          ? data['error'].toString()
          : 'No se pudo crear el usuario (codigo ${response.status})';
      throw Exception(message);
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
}

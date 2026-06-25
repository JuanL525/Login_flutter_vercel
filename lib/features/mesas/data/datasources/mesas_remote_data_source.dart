import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/mesa_model.dart';

abstract class MesasRemoteDataSource {
  Future<List<MesaModel>> getMesasByRecinto(String recintoId);
  Future<List<MesaModel>> getMesasByVeedor(String veedorId);
  Future<void> assignVeedor({required String mesaId, required String? veedorId});
}

@LazySingleton(as: MesasRemoteDataSource)
class MesasRemoteDataSourceImpl implements MesasRemoteDataSource {
  final SupabaseClient supabaseClient;
  MesasRemoteDataSourceImpl(this.supabaseClient);

  static const _select =
      '*, veedor:veedor_id (nombres, apellidos), actas(count)';

  @override
  Future<List<MesaModel>> getMesasByRecinto(String recintoId) async {
    final rows = await supabaseClient
        .from('mesas')
        .select(_select)
        .eq('recinto_id', recintoId)
        .order('numero_jrv');
    return (rows as List)
        .map((e) => MesaModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<MesaModel>> getMesasByVeedor(String veedorId) async {
    final rows = await supabaseClient
        .from('mesas')
        .select(_select)
        .eq('veedor_id', veedorId)
        .order('numero_jrv');
    return (rows as List)
        .map((e) => MesaModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> assignVeedor({
    required String mesaId,
    required String? veedorId,
  }) async {
    await supabaseClient
        .from('mesas')
        .update({'veedor_id': veedorId}).eq('id', mesaId);
  }
}

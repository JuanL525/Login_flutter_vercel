import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/recinto_model.dart';

abstract class RecintosRemoteDataSource {
  Future<List<RecintoModel>> getRecintos();
  Future<RecintoModel> createRecinto(RecintoModel recinto, {int cantidadMesas = 0});
  Future<RecintoModel> updateRecinto(RecintoModel recinto);
}

@LazySingleton(as: RecintosRemoteDataSource)
class RecintosRemoteDataSourceImpl implements RecintosRemoteDataSource {
  final SupabaseClient supabaseClient;
  RecintosRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<List<RecintoModel>> getRecintos() async {
    final rows = await supabaseClient
        .from('recintos')
        .select()
        .order('parroquia');
    return (rows as List)
        .map((e) => RecintoModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<RecintoModel> createRecinto(
    RecintoModel recinto, {
    int cantidadMesas = 0,
  }) async {
    final row = await supabaseClient
        .from('recintos')
        .insert(recinto.toInsert())
        .select()
        .single();
    final created = RecintoModel.fromMap(row);

    // Insertar las mesas (JRV) numeradas del 1 al cantidadMesas.
    if (cantidadMesas > 0) {
      final mesas = List.generate(
        cantidadMesas,
        (i) => {'recinto_id': created.id, 'numero_jrv': i + 1},
      );
      await supabaseClient.from('mesas').insert(mesas);
    }

    return created;
  }

  @override
  Future<RecintoModel> updateRecinto(RecintoModel recinto) async {
    final row = await supabaseClient
        .from('recintos')
        .update(recinto.toInsert())
        .eq('id', recinto.id)
        .select()
        .single();
    return RecintoModel.fromMap(row);
  }
}

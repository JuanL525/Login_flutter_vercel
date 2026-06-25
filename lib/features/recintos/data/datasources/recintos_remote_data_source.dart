import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/recinto_model.dart';

abstract class RecintosRemoteDataSource {
  Future<List<RecintoModel>> getRecintos();
  Future<RecintoModel> createRecinto(RecintoModel recinto);
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
  Future<RecintoModel> createRecinto(RecintoModel recinto) async {
    final row = await supabaseClient
        .from('recintos')
        .insert(recinto.toInsert())
        .select()
        .single();
    return RecintoModel.fromMap(row);
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

import 'dart:io';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/acta_model.dart';

abstract class ActasRemoteDataSource {
  Future<List<ActaModel>> getActasByMesa(String mesaId);

  /// Sube la foto (si hay ruta local pendiente) y hace upsert del acta.
  /// Devuelve el acta con la ruta remota ya asignada.
  Future<ActaModel> pushActa(ActaModel acta);

  /// Genera una URL firmada temporal para visualizar la foto.
  Future<String?> getSignedPhotoUrl(String path);
}

@LazySingleton(as: ActasRemoteDataSource)
class ActasRemoteDataSourceImpl implements ActasRemoteDataSource {
  final SupabaseClient supabaseClient;
  ActasRemoteDataSourceImpl(this.supabaseClient);

  static const _bucket = 'actas-photos';

  @override
  Future<List<ActaModel>> getActasByMesa(String mesaId) async {
    final rows =
        await supabaseClient.from('actas').select().eq('mesa_id', mesaId);
    return (rows as List)
        .map((e) => ActaModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ActaModel> pushActa(ActaModel acta) async {
    var fotoPath = acta.fotoPath;

    // Subir la foto si hay una local pendiente.
    if (acta.fotoLocalPath != null && acta.fotoLocalPath!.isNotEmpty) {
      final file = File(acta.fotoLocalPath!);
      if (file.existsSync()) {
        final path = '${acta.mesaId}/${acta.id}.jpg';
        await supabaseClient.storage.from(_bucket).upload(
              path,
              file,
              fileOptions: const FileOptions(upsert: true),
            );
        fotoPath = path;
      }
    }

    final toPush = ActaModel.fromEntity(
      acta,
    );
    final payload = toPush.toRemoteMap()..['foto_path'] = fotoPath;

    final row = await supabaseClient
        .from('actas')
        .upsert(payload, onConflict: 'mesa_id,dignidad')
        .select()
        .single();

    return ActaModel.fromMap(row);
  }

  @override
  Future<String?> getSignedPhotoUrl(String path) async {
    try {
      return await supabaseClient.storage
          .from(_bucket)
          .createSignedUrl(path, 3600);
    } catch (_) {
      return null;
    }
  }
}

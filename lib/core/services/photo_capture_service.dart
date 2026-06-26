import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'blur_detector.dart';

class CapturedPhoto {
  final String localPath;
  final Uint8List bytes;
  final double sharpnessVariance;
  const CapturedPhoto({
    required this.localPath,
    required this.bytes,
    required this.sharpnessVariance,
  });
}

class BlurryPhotoException implements Exception {
  final BlurResult result;
  BlurryPhotoException(this.result);
  @override
  String toString() =>
      'La foto esta borrosa. Sosten el telefono firme y enfoca el acta. '
      '(Laplaciano: ${result.laplacianVariance.toStringAsFixed(0)}, '
      'min ${BlurDetector.minLaplacianVariance.toStringAsFixed(0)}; '
      'bordes: ${(result.edgeRatio * 100).toStringAsFixed(1)}%, '
      'min ${(BlurDetector.minEdgeRatio * 100).toStringAsFixed(0)}%)';
}

/// Orquesta la captura de la foto del acta:
///  1. Abre la camara.
///  2. Valida la nitidez con [BlurDetector] (varianza del Laplaciano).
///  3. Si pasa, copia la imagen a un directorio persistente local
///     (para que sobreviva al modo offline antes del upload).
@lazySingleton
class PhotoCaptureService {
  final BlurDetector _blurDetector;
  final ImagePicker _picker;

  PhotoCaptureService(this._blurDetector) : _picker = ImagePicker();

  /// Devuelve `null` si el usuario cancela la captura.
  /// Lanza [BlurryPhotoException] si la imagen no es suficientemente nitida.
  Future<CapturedPhoto?> capture({
    ImageSource source = ImageSource.camera,
  }) async {
    final xfile = await _picker.pickImage(
      source: source,
      imageQuality: 100,
      maxWidth: 2400,
    );
    if (xfile == null) return null;

    final bytes = await xfile.readAsBytes();
    final blur = _blurDetector.analyze(bytes);
    if (!blur.isSharp) {
      throw BlurryPhotoException(blur);
    }

    final dir = await getApplicationDocumentsDirectory();
    final actasDir = Directory(p.join(dir.path, 'actas'));
    if (!actasDir.existsSync()) {
      actasDir.createSync(recursive: true);
    }
    final fileName = 'acta_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final localPath = p.join(actasDir.path, fileName);
    await File(localPath).writeAsBytes(bytes);

    return CapturedPhoto(
      localPath: localPath,
      bytes: bytes,
      sharpnessVariance: blur.variance,
    );
  }
}

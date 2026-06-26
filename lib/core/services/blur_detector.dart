import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:injectable/injectable.dart';

class BlurResult {
  /// Varianza del Laplaciano (mayor = mas bordes definidos).
  final double laplacianVariance;

  /// Energia media del gradiente Sobel (Tenengrad).
  final double tenengradMean;

  /// Porcentaje de pixeles con bordes fuertes (0.0 - 1.0).
  final double edgeRatio;

  final bool isSharp;

  /// Puntuacion principal mostrada en la UI (varianza del Laplaciano).
  double get variance => laplacianVariance;

  const BlurResult({
    required this.laplacianVariance,
    required this.tenengradMean,
    required this.edgeRatio,
    required this.isSharp,
  });
}

/// Detecta fotos borrosas combinando tres metricas de enfoque.
///
/// 1. **Varianza del Laplaciano**: mide cuanto cambia la imagen en bordes.
///    Fotos nitidas tienen muchos bordes marcados -> alta varianza.
/// 2. **Tenengrad (Sobel)**: energia del gradiente. Fotos borrosas tienen
///    transiciones suaves -> energia baja.
/// 3. **Ratio de bordes fuertes**: % de pixeles con respuesta Laplaciana alta.
///    Evita aprobar fotos donde solo unas pocas zonas tienen contraste
///    (tipico del desenfoque por movimiento).
///
/// La imagen se reescala a 800 px, se convierte a grises y se aplica un
/// suavizado leve (Gaussian blur) para ignorar ruido JPEG de la camara.
@lazySingleton
class BlurDetector {
  static const int _analysisWidth = 800;

  /// Varianza minima del Laplaciano (tras pre-procesado).
  static const double minLaplacianVariance = 180.0;

  /// Energia media minima del gradiente Sobel.
  static const double minTenengradMean = 18.0;

  /// Minimo % de pixeles con borde fuerte (4%).
  static const double minEdgeRatio = 0.04;

  /// |Laplaciano| minimo para contar un pixel como "borde fuerte".
  static const double edgePixelThreshold = 35.0;

  BlurResult analyze(Uint8List bytes) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      return const BlurResult(
        laplacianVariance: 0,
        tenengradMean: 0,
        edgeRatio: 0,
        isSharp: false,
      );
    }

    final resized = decoded.width > _analysisWidth
        ? img.copyResize(decoded, width: _analysisWidth)
        : decoded;
    final gray = img.grayscale(resized);
    // Reduce artefactos de compresion JPEG antes de medir enfoque.
    final denoised = img.gaussianBlur(gray, radius: 1);

    final w = denoised.width;
    final h = denoised.height;
    if (w < 5 || h < 5) {
      return const BlurResult(
        laplacianVariance: 0,
        tenengradMean: 0,
        edgeRatio: 0,
        isSharp: false,
      );
    }

    final lum = List<double>.filled(w * h, 0);
    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        lum[y * w + x] = denoised.getPixel(x, y).r.toDouble();
      }
    }

    final lapStats = _laplacianStats(lum, w, h);
    final tenengradMean = _tenengradMean(lum, w, h);

    final isSharp = lapStats.variance >= minLaplacianVariance &&
        tenengradMean >= minTenengradMean &&
        lapStats.edgeRatio >= minEdgeRatio;

    return BlurResult(
      laplacianVariance: lapStats.variance,
      tenengradMean: tenengradMean,
      edgeRatio: lapStats.edgeRatio,
      isSharp: isSharp,
    );
  }
}

class _LapStats {
  final double variance;
  final double edgeRatio;
  const _LapStats({required this.variance, required this.edgeRatio});
}

_LapStats _laplacianStats(List<double> lum, int w, int h) {
  var sum = 0.0;
  var sumSq = 0.0;
  var count = 0;
  var strongEdges = 0;

  for (var y = 1; y < h - 1; y++) {
    for (var x = 1; x < w - 1; x++) {
      final c = lum[y * w + x];
      final up = lum[(y - 1) * w + x];
      final down = lum[(y + 1) * w + x];
      final left = lum[y * w + (x - 1)];
      final right = lum[y * w + (x + 1)];
      final laplace = (up + down + left + right) - 4 * c;

      sum += laplace;
      sumSq += laplace * laplace;
      count++;

      if (laplace.abs() >= BlurDetector.edgePixelThreshold) {
        strongEdges++;
      }
    }
  }

  if (count == 0) {
    return const _LapStats(variance: 0, edgeRatio: 0);
  }

  final mean = sum / count;
  final variance = (sumSq / count) - (mean * mean);
  return _LapStats(
    variance: variance,
    edgeRatio: strongEdges / count,
  );
}

double _tenengradMean(List<double> lum, int w, int h) {
  var sum = 0.0;
  var count = 0;

  for (var y = 1; y < h - 1; y++) {
    for (var x = 1; x < w - 1; x++) {
      final gx = lum[y * w + (x + 1)] - lum[y * w + (x - 1)];
      final gy = lum[(y + 1) * w + x] - lum[(y - 1) * w + x];
      sum += gx * gx + gy * gy;
      count++;
    }
  }

  return count == 0 ? 0 : sum / count;
}

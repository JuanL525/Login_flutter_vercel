import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:injectable/injectable.dart';

class BlurResult {
  /// Varianza del Laplaciano: a mayor valor, mas nitida la imagen.
  final double variance;
  final bool isSharp;
  const BlurResult({required this.variance, required this.isSharp});
}

/// Detecta si una imagen esta borrosa usando la *varianza del Laplaciano*.
///
/// Tecnica: se convierte la imagen a escala de grises y se aplica el operador
/// Laplaciano (segunda derivada). En una imagen nitida los bordes son marcados,
/// por lo que la respuesta del Laplaciano tiene alta varianza. En una imagen
/// borrosa los bordes se difuminan y la varianza cae. Si la varianza esta por
/// debajo del umbral, la foto se considera borrosa.
@lazySingleton
class BlurDetector {
  /// Umbral por defecto. Calibrable segun el dispositivo/camara.
  static const double defaultThreshold = 120.0;

  BlurResult analyze(Uint8List bytes, {double threshold = defaultThreshold}) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      // Si no se puede decodificar, se considera no apta.
      return const BlurResult(variance: 0, isSharp: false);
    }

    // Reescalar para acelerar el calculo manteniendo informacion de bordes.
    final resized = decoded.width > 600
        ? img.copyResize(decoded, width: 600)
        : decoded;
    final gray = img.grayscale(resized);

    final w = gray.width;
    final h = gray.height;

    // Matriz de luminancia.
    final lum = List<double>.filled(w * h, 0);
    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        lum[y * w + x] = img.getLuminance(gray.getPixel(x, y)).toDouble();
      }
    }

    // Laplaciano 3x3: [0 1 0; 1 -4 1; 0 1 0]
    var sum = 0.0;
    var sumSq = 0.0;
    var count = 0;
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
      }
    }

    if (count == 0) {
      return const BlurResult(variance: 0, isSharp: false);
    }

    final mean = sum / count;
    final variance = (sumSq / count) - (mean * mean);

    return BlurResult(variance: variance, isSharp: variance >= threshold);
  }
}

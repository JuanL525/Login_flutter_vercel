import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:login_pro/core/services/blur_detector.dart';

void main() {
  late BlurDetector detector;

  setUp(() {
    detector = BlurDetector();
  });

  test('acepta imagen nitida con patron de tablero', () {
    final sharp = _encode(_checkerboard(900, 900, cell: 6));
    final result = detector.analyze(sharp);

    expect(result.isSharp, isTrue, reason: 'lap=${result.laplacianVariance}, '
        'ten=${result.tenengradMean}, edges=${result.edgeRatio}');
  });

  test('rechaza imagen con desenfoque gaussiano fuerte', () {
    final sharp = _checkerboard(900, 900, cell: 6);
    final blurred = img.gaussianBlur(sharp, radius: 6);
    final result = detector.analyze(_encode(blurred));

    expect(result.isSharp, isFalse, reason: 'lap=${result.laplacianVariance}, '
        'ten=${result.tenengradMean}, edges=${result.edgeRatio}');
  });

  test('rechaza imagen con desenfoque por movimiento simulado', () {
    final sharp = _checkerboard(900, 900, cell: 6);
    final motion = _motionBlur(sharp, radius: 12);
    final result = detector.analyze(_encode(motion));

    expect(result.isSharp, isFalse, reason: 'lap=${result.laplacianVariance}, '
        'ten=${result.tenengradMean}, edges=${result.edgeRatio}');
  });
}

img.Image _checkerboard(int width, int height, {required int cell}) {
  final image = img.Image(width: width, height: height);
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final value = ((x ~/ cell) + (y ~/ cell)) % 2 == 0 ? 255 : 0;
      image.setPixelRgb(x, y, value, value, value);
    }
  }
  return image;
}

img.Image _motionBlur(img.Image source, {required int radius}) {
  final output = img.Image.from(source);
  final w = source.width;
  final h = source.height;

  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      var rSum = 0;
      var gSum = 0;
      var bSum = 0;
      var count = 0;
      for (var dx = -radius; dx <= radius; dx++) {
        final sx = x + dx;
        if (sx < 0 || sx >= w) continue;
        final pixel = source.getPixel(sx, y);
        rSum += pixel.r.toInt();
        gSum += pixel.g.toInt();
        bSum += pixel.b.toInt();
        count++;
      }
      if (count == 0) continue;
      output.setPixelRgb(
        x,
        y,
        rSum ~/ count,
        gSum ~/ count,
        bSum ~/ count,
      );
    }
  }
  return output;
}

Uint8List _encode(img.Image image) {
  return Uint8List.fromList(img.encodeJpg(image, quality: 95));
}

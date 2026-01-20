import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:qr/qr.dart';

import 'qr_shape.dart';
import 'qr_style.dart';

class QrGenerator {
  QrGenerator._();

  static QrImage generateQrImage(String data, int errorCorrectionLevel) {
    final qrCode = QrCode.fromData(
      data: data,
      errorCorrectLevel: errorCorrectionLevel,
    );
    return QrImage(qrCode);
  }

  static int getModuleCount(String data, int errorCorrectionLevel) {
    final qrCode = QrCode.fromData(
      data: data,
      errorCorrectLevel: errorCorrectionLevel,
    );
    return qrCode.moduleCount;
  }

  /// Generates QR code image as PNG bytes.
  ///
  /// [data] - The text/URL to encode in the QR code.
  /// [size] - The size of the output image in pixels.
  /// [style] - Optional styling configuration.
  /// [logoImage] - Optional pre-loaded logo image.
  static Future<Uint8List> generateImageBytes({
    required String data,
    required double size,
    QrStyle style = const QrStyle(),
    ui.Image? logoImage,
  }) async {
    final qrImage = generateQrImage(data, style.errorCorrectionLevel);
    final moduleCount = qrImage.moduleCount;
    final moduleSize = size / moduleCount;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final backgroundPaint = Paint()
      ..color = style.backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, size, size), backgroundPaint);

    final foregroundPaint = Paint()
      ..color = style.foregroundColor
      ..style = PaintingStyle.fill;

    Rect? logoSafeArea;
    if (logoImage != null || style.logo != null) {
      final logoTotalSize = style.logoSize + (style.logoPadding * 2);
      final logoOffset = (size - logoTotalSize) / 2;
      logoSafeArea = Rect.fromLTWH(
        logoOffset,
        logoOffset,
        logoTotalSize,
        logoTotalSize,
      );
    }

    _drawFinderPatterns(
      canvas,
      foregroundPaint,
      backgroundPaint,
      moduleSize,
      moduleCount,
      style.shape,
    );

    for (int x = 0; x < moduleCount; x++) {
      for (int y = 0; y < moduleCount; y++) {
        if (_isFinderPattern(x, y, moduleCount)) continue;

        if (qrImage.isDark(y, x)) {
          final px = x * moduleSize;
          final py = y * moduleSize;
          final moduleRect = Rect.fromLTWH(px, py, moduleSize, moduleSize);

          if (logoSafeArea != null && logoSafeArea.overlaps(moduleRect)) {
            continue;
          }

          final gapOffset = style.gapless ? 0.0 : moduleSize * 0.05;
          final adjustedSize = style.gapless ? moduleSize : moduleSize * 0.9;

          style.shape.paintModule(
            canvas,
            foregroundPaint,
            px + gapOffset,
            py + gapOffset,
            adjustedSize,
          );
        }
      }
    }

    if (logoImage != null) {
      final logoOffset = (size - style.logoSize) / 2;

      final logoBgPaint = Paint()
        ..color = style.backgroundColor
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            logoOffset - style.logoPadding,
            logoOffset - style.logoPadding,
            style.logoSize + (style.logoPadding * 2),
            style.logoSize + (style.logoPadding * 2),
          ),
          Radius.circular(style.logoPadding),
        ),
        logoBgPaint,
      );

      // Draw the logo
      final srcRect = Rect.fromLTWH(
        0,
        0,
        logoImage.width.toDouble(),
        logoImage.height.toDouble(),
      );
      final dstRect = Rect.fromLTWH(
        logoOffset,
        logoOffset,
        style.logoSize,
        style.logoSize,
      );
      canvas.drawImageRect(logoImage, srcRect, dstRect, Paint());
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    return byteData!.buffer.asUint8List();
  }

  static bool _isFinderPattern(int x, int y, int moduleCount) {
    if (x < 7 && y < 7) return true;
    if (x >= moduleCount - 7 && y < 7) return true;
    if (x < 7 && y >= moduleCount - 7) return true;
    return false;
  }

  static void _drawFinderPatterns(
    Canvas canvas,
    Paint foregroundPaint,
    Paint backgroundPaint,
    double moduleSize,
    int moduleCount,
    QrShape shape,
  ) {
    // Top-left
    shape.paintFinderPattern(
      canvas,
      foregroundPaint,
      backgroundPaint,
      0,
      0,
      moduleSize,
    );

    // Top-right
    shape.paintFinderPattern(
      canvas,
      foregroundPaint,
      backgroundPaint,
      (moduleCount - 7) * moduleSize,
      0,
      moduleSize,
    );

    // Bottom-left
    shape.paintFinderPattern(
      canvas,
      foregroundPaint,
      backgroundPaint,
      0,
      (moduleCount - 7) * moduleSize,
      moduleSize,
    );
  }
}

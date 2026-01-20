import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:qr/qr.dart';

import 'qr_shape.dart';
import 'qr_style.dart';

/// A utility class for generating QR codes programmatically.
class QrGenerator {
  QrGenerator._();

  /// Generates a QR code image from the given data.
  static QrImage generateQrImage(String data, int errorCorrectionLevel) {
    final qrCode = QrCode.fromData(
      data: data,
      errorCorrectLevel: errorCorrectionLevel,
    );
    return QrImage(qrCode);
  }

  /// Gets the module count for a QR code with given data.
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

    // Draw background
    final backgroundPaint = Paint()
      ..color = style.backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, size, size), backgroundPaint);

    // Draw QR modules
    final foregroundPaint = Paint()
      ..color = style.foregroundColor
      ..style = PaintingStyle.fill;

    // Calculate logo safe area if logo is present
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

    // Draw finder patterns first
    _drawFinderPatterns(
      canvas,
      foregroundPaint,
      backgroundPaint,
      moduleSize,
      moduleCount,
      style.shape,
    );

    // Draw regular modules (excluding finder patterns and logo area)
    for (int x = 0; x < moduleCount; x++) {
      for (int y = 0; y < moduleCount; y++) {
        // Skip finder pattern areas
        if (_isFinderPattern(x, y, moduleCount)) continue;

        if (qrImage.isDark(y, x)) {
          final px = x * moduleSize;
          final py = y * moduleSize;
          final moduleRect = Rect.fromLTWH(px, py, moduleSize, moduleSize);

          // Skip if module is in logo safe area
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

    // Draw logo if provided
    if (logoImage != null) {
      final logoOffset = (size - style.logoSize) / 2;

      // Draw white background behind logo
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

  /// Checks if the given coordinates are part of a finder pattern.
  static bool _isFinderPattern(int x, int y, int moduleCount) {
    // Top-left finder pattern
    if (x < 7 && y < 7) return true;
    // Top-right finder pattern
    if (x >= moduleCount - 7 && y < 7) return true;
    // Bottom-left finder pattern
    if (x < 7 && y >= moduleCount - 7) return true;
    return false;
  }

  /// Draws the three finder patterns (the large squares in corners).
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

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'qr_generator.dart';
import 'qr_style.dart';

/// Result of a QR code share operation.
class QrShareResult {
  const QrShareResult({
    required this.success,
    this.bytes,
    this.errorMessage,
  });

  final bool success;

  /// The raw image bytes.
  final Uint8List? bytes;

  final String? errorMessage;
}


class QrSharer {
  QrSharer._();

  static Future<QrShareResult> share({
    required String data,
    required double size,
    QrStyle style = const QrStyle(),
    String fileName = 'qr_code',
    String? shareText,
    ui.Image? logoImage,
  }) async {
    try {
      // Generate QR code bytes
      final bytes = await QrGenerator.generateImageBytes(
        data: data,
        size: size,
        style: style,
        logoImage: logoImage,
      );

      if (kIsWeb) {
        // Web platform - share using XFile from bytes
        final xFile = XFile.fromData(
          bytes,
          name: '$fileName.png',
          mimeType: 'image/png',
        );

        await SharePlus.instance.share(
          ShareParams(
            files: [xFile],
            text: shareText,
          )
        );

        return QrShareResult(success: true, bytes: bytes);
      }

      // Native platforms - save to temp file first, then share
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/$fileName.png';
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(filePath)],
          text: shareText,
        )

      );

      return QrShareResult(success: true, bytes: bytes);
    } catch (e) {
      return QrShareResult(
        success: false,
        errorMessage: e.toString(),
      );
    }
  }


  static Future<Uint8List> getImageBytes({
    required String data,
    required double size,
    QrStyle style = const QrStyle(),
    ui.Image? logoImage,
  }) async {
    return QrGenerator.generateImageBytes(
      data: data,
      size: size,
      style: style,
      logoImage: logoImage,
    );
  }
}

import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'qr_generator.dart';
import 'qr_shape.dart';
import 'qr_style.dart';

/// A widget that displays a customizable QR code.
///
/// Example:
/// ```dart
/// SimpleQrGen(
///   data: 'https://example.com',
///   size: 250,
///   style: QrStyle(
///     foregroundColor: Colors.indigo,
///     backgroundColor: Colors.white,
///     shape: QrShape.rounded,
///   ),
/// )
/// ```
class SimpleQrGen extends StatefulWidget {
  /// Creates a QR code widget.
  const SimpleQrGen({
    super.key,
    required this.data,
    this.size = 200,
    this.style = const QrStyle(),
    this.padding = EdgeInsets.zero,
    this.semanticsLabel,
  });

  /// The data to encode in the QR code (text, URL, etc.).
  final String data;

  /// The size of the QR code widget.
  final double size;

  /// Styling configuration for the QR code.
  final QrStyle style;

  /// Padding around the QR code.
  final EdgeInsets padding;

  /// Semantic label for accessibility.
  final String? semanticsLabel;

  @override
  State<SimpleQrGen> createState() => _SimpleQrGenState();
}

class _SimpleQrGenState extends State<SimpleQrGen> {
  ui.Image? _logoImage;

  @override
  void initState() {
    super.initState();
    _loadLogo();
  }

  @override
  void didUpdateWidget(SimpleQrGen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.style.logo != widget.style.logo) {
      _loadLogo();
    }
  }

  Future<void> _loadLogo() async {
    if (widget.style.logo == null) {
      setState(() {
        _logoImage = null;
      });
      return;
    }

    try {
      final imageStream = widget.style.logo!.resolve(ImageConfiguration.empty);

      imageStream.addListener(
        ImageStreamListener(
          (ImageInfo info, bool _) {
            if (mounted) {
              setState(() {
                _logoImage = info.image;
              });
            }
          },
          onError: (exception, stackTrace) {
            // Logo failed to load, continue without it
          },
        ),
      );
    } catch (e) {
      // Logo failed to load, continue without it
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.semanticsLabel ?? 'QR Code for ${widget.data}',
      child: Padding(
        padding: widget.padding,
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _QrPainter(
              data: widget.data,
              style: widget.style,
              logoImage: _logoImage,
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom painter for rendering QR codes.
class _QrPainter extends CustomPainter {
  _QrPainter({
    required this.data,
    required this.style,
    this.logoImage,
  });

  final String data;
  final QrStyle style;
  final ui.Image? logoImage;

  @override
  void paint(Canvas canvas, Size size) {
    final qrImage = QrGenerator.generateQrImage(data, style.errorCorrectionLevel);
    final moduleCount = qrImage.moduleCount;
    final moduleSize = size.width / moduleCount;

    // Draw background
    final backgroundPaint = Paint()
      ..color = style.backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

    // Draw QR modules
    final foregroundPaint = Paint()
      ..color = style.foregroundColor
      ..style = PaintingStyle.fill;

    // Calculate logo safe area if logo is present
    Rect? logoSafeArea;
    if (logoImage != null) {
      final logoTotalSize = style.logoSize + (style.logoPadding * 2);
      final logoOffset = (size.width - logoTotalSize) / 2;
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
      final logoOffset = (size.width - style.logoSize) / 2;

      // Draw background behind logo
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
        logoImage!.width.toDouble(),
        logoImage!.height.toDouble(),
      );
      final dstRect = Rect.fromLTWH(
        logoOffset,
        logoOffset,
        style.logoSize,
        style.logoSize,
      );
      canvas.drawImageRect(logoImage!, srcRect, dstRect, Paint());
    }
  }

  bool _isFinderPattern(int x, int y, int moduleCount) {
    // Top-left finder pattern
    if (x < 7 && y < 7) return true;
    // Top-right finder pattern
    if (x >= moduleCount - 7 && y < 7) return true;
    // Bottom-left finder pattern
    if (x < 7 && y >= moduleCount - 7) return true;
    return false;
  }

  void _drawFinderPatterns(
    Canvas canvas,
    Paint foregroundPaint,
    Paint backgroundPaint,
    double moduleSize,
    int moduleCount,
  ) {
    // Top-left
    style.shape.paintFinderPattern(
      canvas,
      foregroundPaint,
      backgroundPaint,
      0,
      0,
      moduleSize,
    );

    // Top-right
    style.shape.paintFinderPattern(
      canvas,
      foregroundPaint,
      backgroundPaint,
      (moduleCount - 7) * moduleSize,
      0,
      moduleSize,
    );

    // Bottom-left
    style.shape.paintFinderPattern(
      canvas,
      foregroundPaint,
      backgroundPaint,
      0,
      (moduleCount - 7) * moduleSize,
      moduleSize,
    );
  }

  @override
  bool shouldRepaint(_QrPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.style != style ||
        oldDelegate.logoImage != logoImage;
  }
}

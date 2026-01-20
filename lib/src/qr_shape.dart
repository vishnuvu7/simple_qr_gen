import 'package:flutter/material.dart';

/// Defines the shape style for QR code modules.
enum QrShape {
  /// Standard square modules
  square,

  /// Rounded corner square modules
  rounded,

  /// Circular dot modules
  dots,

  /// Fully circular modules
  circle,
}

/// Extension methods for [QrShape] to provide painting functionality.
extension QrShapePainter on QrShape {
  /// Paints a single QR module at the given position.
  void paintModule(
    Canvas canvas,
    Paint paint,
    double x,
    double y,
    double size,
  ) {
    switch (this) {
      case QrShape.square:
        canvas.drawRect(
          Rect.fromLTWH(x, y, size, size),
          paint,
        );
        break;

      case QrShape.rounded:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y, size, size),
            Radius.circular(size * 0.3),
          ),
          paint,
        );
        break;

      case QrShape.dots:
        final center = Offset(x + size / 2, y + size / 2);
        canvas.drawCircle(center, size * 0.4, paint);
        break;

      case QrShape.circle:
        final center = Offset(x + size / 2, y + size / 2);
        canvas.drawCircle(center, size / 2, paint);
        break;
    }
  }

  /// Paints a finder pattern (the large squares in corners) at the given position.
  void paintFinderPattern(
    Canvas canvas,
    Paint foregroundPaint,
    Paint backgroundPaint,
    double x,
    double y,
    double moduleSize,
  ) {
    final outerSize = moduleSize * 7;
    final middleSize = moduleSize * 5;
    final innerSize = moduleSize * 3;

    final middleOffset = moduleSize;
    final innerOffset = moduleSize * 2;

    switch (this) {
      case QrShape.square:
        // Outer square
        canvas.drawRect(
          Rect.fromLTWH(x, y, outerSize, outerSize),
          foregroundPaint,
        );
        // Middle square (background)
        canvas.drawRect(
          Rect.fromLTWH(x + middleOffset, y + middleOffset, middleSize, middleSize),
          backgroundPaint,
        );
        // Inner square
        canvas.drawRect(
          Rect.fromLTWH(x + innerOffset, y + innerOffset, innerSize, innerSize),
          foregroundPaint,
        );
        break;

      case QrShape.rounded:
        final outerRadius = Radius.circular(moduleSize);
        final middleRadius = Radius.circular(moduleSize * 0.7);
        final innerRadius = Radius.circular(moduleSize * 0.5);

        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y, outerSize, outerSize),
            outerRadius,
          ),
          foregroundPaint,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x + middleOffset, y + middleOffset, middleSize, middleSize),
            middleRadius,
          ),
          backgroundPaint,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x + innerOffset, y + innerOffset, innerSize, innerSize),
            innerRadius,
          ),
          foregroundPaint,
        );
        break;

      case QrShape.dots:
      case QrShape.circle:
        final outerCenter = Offset(x + outerSize / 2, y + outerSize / 2);
        canvas.drawCircle(outerCenter, outerSize / 2, foregroundPaint);
        canvas.drawCircle(outerCenter, middleSize / 2, backgroundPaint);
        canvas.drawCircle(outerCenter, innerSize / 2, foregroundPaint);
        break;
    }
  }
}

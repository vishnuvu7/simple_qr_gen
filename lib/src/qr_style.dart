import 'package:flutter/material.dart';
import 'package:qr/qr.dart';

import 'qr_shape.dart';

/// Configuration class for customizing QR code appearance.
class QrStyle {
  /// Creates a new [QrStyle] with the specified options.
  const QrStyle({
    this.foregroundColor = Colors.black,
    this.backgroundColor = Colors.white,
    this.shape = QrShape.square,
    this.logo,
    this.logoSize = 50,
    this.logoPadding = 8,
    this.errorCorrectionLevel = QrErrorCorrectLevel.H,
    this.gapless = true,
  });

  /// The color of the QR code modules (dark parts).
  final Color foregroundColor;

  /// The background color of the QR code.
  final Color backgroundColor;

  /// The shape style for QR code modules.
  final QrShape shape;

  /// Optional logo image to display in the center of the QR code.
  final ImageProvider? logo;

  /// The size of the logo in logical pixels.
  final double logoSize;

  /// Padding around the logo to ensure QR code readability.
  final double logoPadding;

  /// Error correction level for the QR code.
  /// Higher levels allow more damage but increase QR code size.
  /// - L: ~7% correction
  /// - M: ~15% correction
  /// - Q: ~25% correction
  /// - H: ~30% correction (recommended when using logos)
  final int errorCorrectionLevel;

  /// Whether to render modules without gaps (gapless).
  /// When true, modules are rendered edge-to-edge.
  /// When false, small gaps are left between modules.
  final bool gapless;

  /// Creates a copy of this [QrStyle] with the given fields replaced.
  QrStyle copyWith({
    Color? foregroundColor,
    Color? backgroundColor,
    QrShape? shape,
    ImageProvider? logo,
    double? logoSize,
    double? logoPadding,
    int? errorCorrectionLevel,
    bool? gapless,
  }) {
    return QrStyle(
      foregroundColor: foregroundColor ?? this.foregroundColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      shape: shape ?? this.shape,
      logo: logo ?? this.logo,
      logoSize: logoSize ?? this.logoSize,
      logoPadding: logoPadding ?? this.logoPadding,
      errorCorrectionLevel: errorCorrectionLevel ?? this.errorCorrectionLevel,
      gapless: gapless ?? this.gapless,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QrStyle &&
        other.foregroundColor == foregroundColor &&
        other.backgroundColor == backgroundColor &&
        other.shape == shape &&
        other.logo == logo &&
        other.logoSize == logoSize &&
        other.logoPadding == logoPadding &&
        other.errorCorrectionLevel == errorCorrectionLevel &&
        other.gapless == gapless;
  }

  @override
  int get hashCode {
    return Object.hash(
      foregroundColor,
      backgroundColor,
      shape,
      logo,
      logoSize,
      logoPadding,
      errorCorrectionLevel,
      gapless,
    );
  }
}

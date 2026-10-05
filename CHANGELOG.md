## 2.0.0

* **Breaking:** `QrStyle.errorCorrectionLevel` is now a `QrErrorCorrectLevel` enum (`low`, `medium`, `quartile`, `high`) instead of an `int`. `QrErrorCorrectLevel` is re-exported from `simple_qr_gen`.
* Updated dependencies: `qr` ^4.0.0, `share_plus` ^13.3.1, `path_provider` ^2.1.6
* Requires Dart 3.11 / Flutter 3.41 or newer

## 1.0.1

* Removed unused `image` dependency to fix compatibility issues with packages like `pdf`

## 1.0.0

* Initial release
* QR code generation from text data
* Customizable styling with QrStyle (colors, shapes, logo)
* Multiple shape options: square, rounded, dots, circle
* Logo embedding with automatic safe area
* Cross-platform share support via native share dialog
* SimpleQrGen widget for easy integration
* QrSharer utility for sharing QR codes

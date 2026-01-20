# Simple QR Gen

A Flutter package for generating customizable QR codes with advanced styling options and cross-platform share functionality.

[![pub package](https://img.shields.io/pub/v/simple_qr_gen.svg)](https://pub.dev/packages/simple_qr_gen)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

## Features

- ✨ Generate QR codes from any text or URL
- 🎨 Customizable colors (foreground & background)
- 🔷 Multiple shape styles (square, rounded, dots, circle)
- 🖼️ Embed logos in the center
- 📱 Cross-platform share support via native share dialog
- 🔧 High error correction for logo embedding
- ⚡ Fast and lightweight

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  simple_qr_gen: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Platform Setup

No special permissions required! The package uses the native share dialog which handles permissions automatically.

## Usage

### Basic QR Code

```dart
import 'package:simple_qr_gen/simple_qr_gen.dart';

// Display a simple QR code
SimpleQrGen(
  data: 'https://flutter.dev',
  size: 250,
)
```

### Styled QR Code

```dart
SimpleQrGen(
  data: 'https://example.com',
  size: 250,
  style: QrStyle(
    foregroundColor: Colors.indigo,
    backgroundColor: Colors.white,
    shape: QrShape.rounded,
  ),
)
```

### QR Code with Logo

```dart
SimpleQrGen(
  data: 'https://example.com',
  size: 250,
  style: QrStyle(
    foregroundColor: Colors.black,
    backgroundColor: Colors.white,
    shape: QrShape.dots,
    logo: AssetImage('assets/logo.png'),
    logoSize: 50,
    logoPadding: 8,
  ),
)
```

### Share QR Code

```dart
// Share via native share dialog
final result = await QrSharer.share(
  data: 'https://example.com',
  size: 1024,
  style: QrStyle(
    foregroundColor: Colors.indigo,
    backgroundColor: Colors.white,
    shape: QrShape.rounded,
  ),
  fileName: 'my_qr_code',
  shareText: 'Check out this QR code!',
);

if (!result.success) {
  print('Error: ${result.errorMessage}');
}
```

### Get Raw Image Bytes

```dart
// Get image bytes for custom handling
final bytes = await QrSharer.getImageBytes(
  data: 'https://example.com',
  size: 512,
  style: QrStyle(shape: QrShape.circle),
);

// Use bytes for uploading, custom processing, etc.
```

## API Reference

### SimpleQrGen Widget

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `data` | `String` | required | The text/URL to encode |
| `size` | `double` | `200` | Widget size in logical pixels |
| `style` | `QrStyle` | `QrStyle()` | Styling configuration |
| `padding` | `EdgeInsets` | `EdgeInsets.zero` | Padding around QR code |
| `semanticsLabel` | `String?` | `null` | Accessibility label |

### QrStyle

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `foregroundColor` | `Color` | `Colors.black` | QR modules color |
| `backgroundColor` | `Color` | `Colors.white` | Background color |
| `shape` | `QrShape` | `QrShape.square` | Module shape style |
| `logo` | `ImageProvider?` | `null` | Logo image |
| `logoSize` | `double` | `50` | Logo size in pixels |
| `logoPadding` | `double` | `8` | Padding around logo |
| `errorCorrectionLevel` | `int` | `QrErrorCorrectLevel.H` | Error correction (L/M/Q/H) |
| `gapless` | `bool` | `true` | Render modules edge-to-edge |

### QrShape

| Value | Description |
|-------|-------------|
| `QrShape.square` | Standard square modules |
| `QrShape.rounded` | Rounded corner squares |
| `QrShape.dots` | Small circular dots |
| `QrShape.circle` | Full circular modules |

### QrSharer

| Method | Description |
|--------|-------------|
| `share()` | Share QR code via native share dialog |
| `getImageBytes()` | Get raw PNG bytes |

## Example App

Check out the [example](example/) directory for a complete demo app with:
- Live QR preview
- Color pickers
- Shape selector
- Download functionality

## License

MIT License - see [LICENSE](LICENSE) for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

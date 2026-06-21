// Generates the fintr launcher icon PNGs from code (no design tool needed).
// Run with: dart run tool/generate_icon.dart
//
// Draws the same brand mark as lib/widgets/app_logo.dart: a rounded-square
// badge with three ascending bars. Produces:
//   assets/icon/app_icon.png            (full icon: accent bg + white bars)
//   assets/icon/app_icon_foreground.png (transparent + padded bars, adaptive)

import 'dart:io';
import 'dart:math';

import 'package:image/image.dart' as img;

const int _size = 1024;

// fintr accent (matches theme primary).
final img.Color _accent = img.ColorRgb8(0xD9, 0x77, 0x57);
final img.Color _white = img.ColorRgb8(0xFF, 0xFF, 0xFF);
final img.Color _transparent = img.ColorRgba8(0, 0, 0, 0);

void main() {
  Directory('assets/icon').createSync(recursive: true);

  // Full icon: rounded accent square with bars.
  final full = img.Image(width: _size, height: _size, numChannels: 4);
  img.fill(full, color: _transparent);
  img.fillRect(full,
      x1: 0,
      y1: 0,
      x2: _size - 1,
      y2: _size - 1,
      radius: (_size * 0.22).round(),
      color: _accent);
  _drawBars(full, _white, scale: 1.0);
  File('assets/icon/app_icon.png').writeAsBytesSync(img.encodePng(full));

  // Adaptive foreground: transparent, bars scaled into the safe zone.
  final fg = img.Image(width: _size, height: _size, numChannels: 4);
  img.fill(fg, color: _transparent);
  _drawBars(fg, _white, scale: 0.74);
  File('assets/icon/app_icon_foreground.png')
      .writeAsBytesSync(img.encodePng(fg));

  stdout.writeln('Wrote assets/icon/app_icon.png and app_icon_foreground.png');
}

void _drawBars(img.Image image, img.Color color, {required double scale}) {
  final center = _size / 2;
  final barW = _size * 0.15 * scale;
  final gap = _size * 0.08 * scale;
  final heights = [0.28, 0.44, 0.60].map((h) => h * _size * scale).toList();
  final maxH = heights.reduce(max);
  final totalW = barW * 3 + gap * 2;
  final baseY = center + maxH / 2;

  var x = center - totalW / 2;
  for (final h in heights) {
    img.fillRect(image,
        x1: x.round(),
        y1: (baseY - h).round(),
        x2: (x + barW).round(),
        y2: baseY.round(),
        radius: (barW * 0.32).round(),
        color: color);
    x += barW + gap;
  }
}

import 'package:flutter/material.dart';

/// The fintr brand mark: a rounded-square badge with three ascending bars,
/// echoing the app's budget progress bars. Colors default to the theme accent.
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 40,
    this.backgroundColor,
    this.barColor,
  });

  final double size;
  final Color? backgroundColor;
  final Color? barColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _LogoPainter(
          background: backgroundColor ?? scheme.primary,
          bars: barColor ?? scheme.onPrimary,
        ),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  _LogoPainter({required this.background, required this.bars});

  final Color background;
  final Color bars;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width;

    final bgPaint = Paint()..color = background;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(r * 0.28)),
      bgPaint,
    );

    final barPaint = Paint()..color = bars;
    final barW = r * 0.15;
    final gap = r * 0.08;
    final heights = [0.28, 0.44, 0.60].map((h) => h * r).toList();
    final maxH = heights.last;
    final totalW = barW * 3 + gap * 2;
    final baseY = (size.height + maxH) / 2;
    final corner = Radius.circular(barW * 0.35);

    var x = (r - totalW) / 2;
    for (final h in heights) {
      final rect = Rect.fromLTWH(x, baseY - h, barW, h);
      canvas.drawRRect(
        RRect.fromRectAndCorners(rect, topLeft: corner, topRight: corner),
        barPaint,
      );
      x += barW + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _LogoPainter old) =>
      old.background != background || old.bars != bars;
}

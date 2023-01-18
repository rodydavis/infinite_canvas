import 'package:flutter/material.dart';

import 'inline_painter.dart';

/// A marquee widget that allows you to select multiple nodes.
class Marquee extends StatelessWidget {
  const Marquee({
    super.key,
    required this.start,
    required this.end,
  });

  final Offset start, end;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return CustomPaint(
      painter: InlinePainter(
        brush: Paint()
          ..color = colors.secondary.withOpacity(0.3)
          ..style = PaintingStyle.fill,
        builder: (brush, canvas, rect) {
          final marqueeRect = Rect.fromPoints(start, end);
          canvas.drawRect(marqueeRect, brush);
        },
      ),
    );
  }
}

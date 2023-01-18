import 'package:flutter/material.dart';

import 'controller.dart';
import 'inline_painter.dart';

/// A widget that renders all the edges in the [InfiniteCanvas].
class InfiniteCanvasEdgeRenderer extends StatelessWidget {
  const InfiniteCanvasEdgeRenderer({
    super.key,
    required this.controller,
  });

  final InfiniteCanvasController controller;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return CustomPaint(
      painter: InlinePainter(
        brush: Paint()
          ..color = colors.outlineVariant
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
        builder: (brush, canvas, rect) {
          for (final edge in controller.edges) {
            final from =
                controller.nodes.firstWhere((node) => node.key == edge.from);
            final to =
                controller.nodes.firstWhere((node) => node.key == edge.to);
            final fromRect = from.rect;
            final toRect = to.rect;
            // Draw bezier curve from fromRect.center to toRect.center
            final path = Path();
            path.moveTo(fromRect.center.dx, fromRect.center.dy);
            path.cubicTo(
              fromRect.center.dx,
              fromRect.center.dy,
              fromRect.center.dx,
              toRect.center.dy,
              toRect.center.dx,
              toRect.center.dy,
            );
            canvas.drawPath(path, brush);
            if (edge.label != null) {
              final textPainter = TextPainter(
                text: TextSpan(
                  text: edge.label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurface,
                    shadows: [
                      Shadow(
                        offset: const Offset(0.8, 0.8),
                        blurRadius: 3,
                        color: colors.surface,
                      ),
                    ],
                  ),
                ),
                textDirection: TextDirection.ltr,
              )..layout();
              // Render label on bezier curve
              Offset textOffset = Offset(
                (fromRect.center.dx + toRect.center.dx) / 2,
                (fromRect.center.dy + toRect.center.dy) / 2,
              );
              // Center on curve
              final pathMetrics = path.computeMetrics();
              final pathMetric = pathMetrics.first;
              final pathLength = pathMetric.length;
              final middle = pathMetric.getTangentForOffset(pathLength / 2);
              textOffset = middle?.position ?? textOffset;
              // Offset to top left
              textOffset = textOffset.translate(
                -textPainter.width / 2,
                -textPainter.height / 2,
              );
              textPainter.paint(canvas, textOffset);
            }
          }
        },
      ),
    );
  }
}

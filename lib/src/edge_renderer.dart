import 'package:flutter/material.dart';

import 'controller.dart';
import 'edge.dart';
import 'inline_painter.dart';

/// A widget that renders all the edges in the [InfiniteCanvas].
class InfiniteCanvasEdgeRenderer extends StatelessWidget {
  const InfiniteCanvasEdgeRenderer({
    super.key,
    required this.controller,
    required this.edges,
    this.linkStart,
    this.linkEnd,
  });

  final InfiniteCanvasController controller;
  final List<InfiniteCanvasEdge> edges;
  final Offset? linkStart, linkEnd;

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
          for (final edge in edges) {
            final from =
                controller.nodes.firstWhere((node) => node.key == edge.from);
            final to =
                controller.nodes.firstWhere((node) => node.key == edge.to);
            drawEdge(
              context,
              canvas,
              from.rect.center,
              to.rect.center,
              brush,
              label: edge.label,
            );
          }
        },
      ),
      foregroundPainter: InlinePainter(
        brush: Paint()
          ..color = colors.primary
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
        builder: (brush, canvas, child) {
          if (linkStart != null && linkEnd != null) {
            drawEdge(
              context,
              canvas,
              linkStart!,
              controller.toLocal(linkEnd!),
              brush,
            );
          }
        },
      ),
    );
  }

  void drawEdge(
    BuildContext context,
    Canvas canvas,
    Offset fromOffset,
    Offset toOffset,
    Paint brush, {
    String? label,
  }) {
    final colors = Theme.of(context).colorScheme;
    // Draw bezier curve from fromRect.center to toRect.center
    final path = Path();
    path.moveTo(fromOffset.dx, fromOffset.dy);
    path.cubicTo(
      fromOffset.dx,
      fromOffset.dy,
      fromOffset.dx,
      toOffset.dy,
      toOffset.dx,
      toOffset.dy,
    );
    canvas.drawPath(path, brush);
    if (label != null) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: label,
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
        (fromOffset.dx + toOffset.dx) / 2,
        (fromOffset.dy + toOffset.dy) / 2,
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
}

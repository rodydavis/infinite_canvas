import 'dart:math';

import 'package:flutter/material.dart';
import 'package:infinite_canvas/infinite_canvas.dart';
import 'package:random_color/random_color.dart';

class GeneratedNodes extends StatefulWidget {
  const GeneratedNodes({super.key});

  @override
  State<GeneratedNodes> createState() => _GeneratedNodesState();
}

class _GeneratedNodesState extends State<GeneratedNodes> {
  late InfiniteCanvasController controller;

  @override
  void initState() {
    super.initState();
    // Generate random nodes
    final colors = RandomColor();
    final nodes = List.generate(100, (index) {
      final color = colors.randomColor();
      return InfiniteCanvasNode(
        key: UniqueKey(),
        label: 'Node $index',
        allowResize: true,
        offset: Offset(
          Random().nextDouble() * 5000,
          Random().nextDouble() * 5000,
        ),
        size: Size(
          Random().nextDouble() * 200 + 100,
          Random().nextDouble() * 200 + 100,
        ),
        child: Builder(
          builder: (context) {
            return CustomPaint(
              painter: InlineCustomPainter(
                brush: Paint()..color = color,
                builder: (brush, canvas, rect) {
                  // Draw circle
                  canvas.drawCircle(rect.center, rect.width / 2, brush);
                },
              ),
            );
          },
        ),
      );
    });
    // Generate random edges
    final edges = <InfiniteCanvasEdge>[];
    for (var i = 0; i < nodes.length; i++) {
      final from = nodes[i];
      final to = nodes[Random().nextInt(nodes.length)];
      if (from != to) {
        edges.add(InfiniteCanvasEdge(
          from: from.key,
          to: to.key,
          label: 'Edge $i',
        ));
      }
    }
    controller = InfiniteCanvasController(nodes: nodes, edges: edges);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Infinite Canvas Example'),
        centerTitle: false,
      ),
      body: InfiniteCanvas(
        drawVisibleOnly: true,
        canAddEdges: true,
        controller: controller,
      ),
    );
  }
}

class InlineCustomPainter extends CustomPainter {
  const InlineCustomPainter({
    required this.brush,
    required this.builder,
    this.isAntiAlias = true,
  });
  final Paint brush;
  final bool isAntiAlias;
  final void Function(Paint paint, Canvas canvas, Rect rect) builder;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    brush.isAntiAlias = isAntiAlias;
    canvas.save();
    builder(brush, canvas, rect);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

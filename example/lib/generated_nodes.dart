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
      final size = Random().nextDouble() * 200 + 100;
      return InfiniteCanvasNode(
        key: UniqueKey(),
        label: 'Node $index',
        allowResize: true,
        offset: Offset(
          Random().nextDouble() * 5000,
          Random().nextDouble() * 5000,
        ),
        size: Size.square(size),
        child: Builder(
          builder: (context) {
            return CustomPaint(
              painter: InlineCustomPainter(
                brush: Paint()..color = color,
                builder: (brush, canvas, rect) {
                  // Draw circle
                  final diameter = min(rect.width, rect.height);
                  final radius = diameter / 2;
                  canvas.drawCircle(rect.center, radius, brush);
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
        menus: [
          MenuEntry(
            label: 'Create',
            menuChildren: [
              MenuEntry(
                label: 'Circle',
                onPressed: () {
                  final color = RandomColor().randomColor();
                  final node = InfiniteCanvasNode(
                    key: UniqueKey(),
                    label: 'Node ${controller.nodes.length}',
                    allowResize: true,
                    offset: controller.mousePosition,
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
                              final diameter = min(rect.width, rect.height);
                              final radius = diameter / 2;
                              canvas.drawCircle(rect.center, radius, brush);
                            },
                          ),
                        );
                      },
                    ),
                  );
                  controller.add(node);
                },
              ),
              MenuEntry(
                label: 'Triangle',
                onPressed: () {
                  final color = RandomColor().randomColor();
                  final node = InfiniteCanvasNode(
                    key: UniqueKey(),
                    label: 'Node ${controller.nodes.length}',
                    allowResize: true,
                    offset: controller.mousePosition,
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
                              // Draw triangle
                              final path = Path()
                                ..moveTo(rect.left, rect.bottom)
                                ..lineTo(rect.right, rect.bottom)
                                ..lineTo(rect.center.dx, rect.top)
                                ..close();
                              canvas.drawPath(path, brush);
                            },
                          ),
                        );
                      },
                    ),
                  );
                  controller.add(node);
                },
              ),
              MenuEntry(
                label: 'Rectangle',
                onPressed: () {
                  final color = RandomColor().randomColor();
                  final node = InfiniteCanvasNode(
                    key: UniqueKey(),
                    label: 'Node ${controller.nodes.length}',
                    allowResize: true,
                    offset: controller.mousePosition,
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
                              // Draw rectangle
                              canvas.drawRect(rect, brush);
                            },
                          ),
                        );
                      },
                    ),
                  );
                  controller.add(node);
                },
              ),
            ],
          ),
        ],
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

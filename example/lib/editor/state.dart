import 'dart:math';

import 'package:flutter/material.dart';
import 'package:infinite_canvas/infinite_canvas.dart';
import 'package:random_color/random_color.dart';

import 'widgets/canvas_widget.dart';
import 'widgets/inline_painter.dart';

class EditorController extends InfiniteCanvasController {
  Size gridSize = const Size.square(50);

  bool _formattingEnabled = false;
  bool get formattingEnabled => _formattingEnabled;
  set formattingEnabled(bool value) {
    _formattingEnabled = value;
    if (value) {
      formatter = (node) {
        // snap to grid
        node.offset = Offset(
          (node.offset.dx / gridSize.width).roundToDouble() * gridSize.width,
          (node.offset.dy / gridSize.height).roundToDouble() * gridSize.height,
        );
      };
    } else {
      formatter = null;
    }
    notifyListeners();
  }
}

extension EditorControllerExtension on EditorController {
  List<MenuEntry> buildMenus(BuildContext context) {
    return [
      MenuEntry(
        label: 'File',
        menuChildren: [
          MenuEntry(
            label: 'Create',
            menuChildren: [
              MenuEntry(
                label: 'Circle',
                onPressed: () {
                  final color = RandomColor().randomColor();
                  final node = InfiniteCanvasNode(
                    key: UniqueKey(),
                    label: 'Node ${nodes.length}',
                    allowResize: true,
                    offset: mousePosition,
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
                  add(node);
                },
              ),
              MenuEntry(
                label: 'Triangle',
                onPressed: () {
                  final color = RandomColor().randomColor();
                  final node = InfiniteCanvasNode(
                    key: UniqueKey(),
                    label: 'Node ${nodes.length}',
                    allowResize: true,
                    offset: mousePosition,
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
                  add(node);
                },
              ),
              MenuEntry(
                label: 'Rectangle',
                onPressed: () {
                  final color = RandomColor().randomColor();
                  final node = InfiniteCanvasNode(
                    key: UniqueKey(),
                    label: 'Node ${nodes.length}',
                    allowResize: true,
                    offset: mousePosition,
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
                  add(node);
                },
              ),
              MenuEntry(
                label: 'Rounded Rectangle',
                onPressed: () {
                  final color = RandomColor().randomColor();
                  final nodeKey = GlobalKey();
                  final node = InfiniteCanvasNode(
                    key: ValueKey(nodeKey),
                    label: 'Node ${nodes.length}',
                    allowResize: true,
                    offset: mousePosition,
                    size: Size(
                      Random().nextDouble() * 200 + 100,
                      Random().nextDouble() * 200 + 100,
                    ),
                    value: {
                      'type': ReadOnlyKnob<String>(
                        type: KnobType.string,
                        label: 'Type',
                        value: 'Rounded Rectangle',
                      ),
                      'borderRadius': Knob<double>(
                        type: KnobType.double,
                        label: 'Border Radius',
                        value: 10.0,
                      ),
                      'borderColor': Knob<int>(
                        type: KnobType.color,
                        label: 'Border Color',
                        value: Colors.black.value,
                      ),
                    },
                    child: Builder(
                      builder: (context) {
                        // Get widget by widget key
                        final widget =
                            nodeKey.currentWidget as InfiniteCanvasNode<Knobs>;
                        final knobs = widget.value!;
                        return CustomPaint(
                          painter: InlineCustomPainter(
                            brush: Paint()..color = color,
                            builder: (brush, canvas, rect) {
                              // Draw rectangle
                              final borderRadius =
                                  knobs.value<double>('borderRadius');
                              final borderColor =
                                  Color(knobs.value<int>('borderColor'));
                              final path = Path()
                                ..moveTo(rect.left + borderRadius, rect.top)
                                ..lineTo(rect.right - borderRadius, rect.top)
                                ..quadraticBezierTo(
                                  rect.right,
                                  rect.top,
                                  rect.right,
                                  rect.top + borderRadius,
                                )
                                ..lineTo(rect.right, rect.bottom - borderRadius)
                                ..quadraticBezierTo(
                                  rect.right,
                                  rect.bottom,
                                  rect.right - borderRadius,
                                  rect.bottom,
                                )
                                ..lineTo(rect.left + borderRadius, rect.bottom)
                                ..quadraticBezierTo(
                                  rect.left,
                                  rect.bottom,
                                  rect.left,
                                  rect.bottom - borderRadius,
                                )
                                ..lineTo(rect.left, rect.top + borderRadius)
                                ..quadraticBezierTo(
                                  rect.left,
                                  rect.top,
                                  rect.left + borderRadius,
                                  rect.top,
                                )
                                ..close();
                              brush
                                ..color = borderColor
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = 2;
                              canvas.drawPath(path, brush);
                            },
                          ),
                        );
                      },
                    ),
                  );
                  add(node);
                },
              ),
            ],
          ),
        ],
      ),
      MenuEntry(
        label: 'View',
        menuChildren: [
          MenuEntry(
            label: '${!formattingEnabled ? 'Enable' : 'Disable'} Formatting',
            onPressed: () {
              formattingEnabled = !formattingEnabled;
            },
          ),
        ],
      ),
    ];
  }
}

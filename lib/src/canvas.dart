import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

import 'controller.dart';
import 'delegate.dart';
import 'edge_renderer.dart';
import 'grid_background.dart';
import 'marquee.dart';
import 'menu.dart';

/// A Widget that renders a canvas that can be panned and zoomed.
class InfiniteCanvas extends StatefulWidget {
  const InfiniteCanvas({
    super.key,
    required this.controller,
    this.gridSize = const Size.square(50),
    this.minScale = 0.4,
    this.maxScale = 4,
    this.borderInset = 2,
    this.menuVisible = true,
  });

  final InfiniteCanvasController controller;
  final Size gridSize;
  final double minScale, maxScale;
  final double borderInset;
  final bool menuVisible;

  @override
  State<InfiniteCanvas> createState() => InfiniteCanvasState();
}

class InfiniteCanvasState extends State<InfiniteCanvas> {
  @override
  void initState() {
    super.initState();
    controller.addListener(onUpdate);
    controller.focusNode.requestFocus();
  }

  @override
  void dispose() {
    controller.removeListener(onUpdate);
    controller.focusNode.dispose();
    super.dispose();
  }

  void onUpdate() {
    if (mounted) setState(() {});
  }

  InfiniteCanvasController get controller => widget.controller;

  Rect axisAlignedBoundingBox(Quad quad) {
    double xMin = quad.point0.x;
    double xMax = quad.point0.x;
    double yMin = quad.point0.y;
    double yMax = quad.point0.y;

    for (final Vector3 point in <Vector3>[
      quad.point1,
      quad.point2,
      quad.point3,
    ]) {
      if (point.x < xMin) {
        xMin = point.x;
      } else if (point.x > xMax) {
        xMax = point.x;
      }

      if (point.y < yMin) {
        yMin = point.y;
      } else if (point.y > yMax) {
        yMax = point.y;
      }
    }

    return Rect.fromLTRB(xMin, yMin, xMax, yMax);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final fonts = Theme.of(context).textTheme;
    return InfiniteCanvasMenu(
      controller: widget.controller,
      visible: widget.menuVisible,
      child: KeyboardListener(
        focusNode: controller.focusNode,
        onKeyEvent: (event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.shiftLeft ||
                event.logicalKey == LogicalKeyboardKey.shiftRight) {
              controller.shiftPressed = true;
            }
          }
          if (event is KeyUpEvent) {
            if (event.logicalKey == LogicalKeyboardKey.shiftLeft ||
                event.logicalKey == LogicalKeyboardKey.shiftRight) {
              controller.shiftPressed = false;
            }
          }
        },
        child: Listener(
          onPointerDown: (details) {
            controller.mouseDown = true;
            controller.checkSelection(details.localPosition);
            if (controller.selection.isEmpty) {
              controller.marqueeStart = details.localPosition;
              controller.marqueeEnd = details.localPosition;
            }
          },
          onPointerUp: (details) {
            controller.mouseDown = false;
            if (controller.marqueeStart != null &&
                controller.marqueeEnd != null) {
              controller.checkMarqueeSelection();
            }
            controller.marqueeStart = null;
            controller.marqueeEnd = null;
          },
          onPointerCancel: (details) {
            controller.mouseDown = false;
          },
          onPointerHover: (details) {
            controller.mousePosition = details.localPosition;
            controller.checkSelection(controller.mousePosition, true);
          },
          onPointerMove: (details) {
            controller.marqueeEnd = details.localPosition;
            if (controller.marqueeStart != null &&
                controller.marqueeEnd != null) {
              controller.checkMarqueeSelection(true);
            }
          },
          child: LayoutBuilder(
            builder: (context, constraints) => InteractiveViewer.builder(
              transformationController: controller.transform,
              panEnabled: controller.canvasMoveEnabled,
              scaleEnabled: controller.canvasMoveEnabled,
              onInteractionStart: (details) {
                controller.mousePosition = details.focalPoint;
              },
              onInteractionUpdate: (details) {
                if (!controller.mouseDown) {
                  controller.scale = details.scale;
                } else {
                  controller.moveSelection(details.focalPoint);
                }
                controller.mousePosition = details.focalPoint;
              },
              minScale: widget.minScale,
              maxScale: widget.maxScale,
              boundaryMargin: const EdgeInsets.all(double.infinity),
              builder: (context, viewport) {
                return SizedBox.fromSize(
                  size: controller.getMaxSize().size,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(
                        child: GridBackgroundBuilder(
                          cellWidth: widget.gridSize.width,
                          cellHeight: widget.gridSize.height,
                          viewport: axisAlignedBoundingBox(viewport),
                        ),
                      ),
                      Positioned.fill(
                        child: InfiniteCanvasEdgeRenderer(
                          controller: controller,
                        ),
                      ),
                      Positioned.fill(
                        child: CustomMultiChildLayout(
                          delegate: InfiniteCanvasNodesDelegate(controller),
                          children: controller.nodes
                              .map((e) => LayoutId(
                                  id: e,
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      if (e.label != null)
                                        Positioned(
                                          top: -25,
                                          left: 0,
                                          child: Text(
                                            e.label!,
                                            style: fonts.bodyMedium?.copyWith(
                                              color: colors.onSurface,
                                              shadows: [
                                                Shadow(
                                                  offset:
                                                      const Offset(0.8, 0.8),
                                                  blurRadius: 3,
                                                  color: colors.surface,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      if (controller.isSelected(e.key!) ||
                                          controller.isHovered(e.key!))
                                        Positioned(
                                          top: -widget.borderInset,
                                          left: -widget.borderInset,
                                          right: -widget.borderInset,
                                          bottom: -widget.borderInset,
                                          child: IgnorePointer(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: controller
                                                          .isSelected(e.key!)
                                                      ? colors.primary
                                                      : colors.outline,
                                                  width: 1,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      Positioned.fill(child: e),
                                    ],
                                  )))
                              .toList(),
                        ),
                      ),
                      if (controller.marqueeStart != null &&
                          controller.marqueeEnd != null)
                        Positioned.fill(
                          child: Marquee(
                            start: controller.toLocal(controller.marqueeStart!),
                            end: controller.toLocal(controller.marqueeEnd!),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

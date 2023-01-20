import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

import 'controller.dart';
import 'delegate.dart';
import 'edge.dart';
import 'edge_renderer.dart';
import 'grid_background.dart';
import 'marquee.dart';
import 'menu.dart';
import 'node.dart';

/// A Widget that renders a canvas that can be panned and zoomed.
class InfiniteCanvas extends StatefulWidget {
  const InfiniteCanvas({
    super.key,
    required this.controller,
    this.gridSize = const Size.square(50),
    this.minScale = 0.4,
    this.maxScale = 4,
    this.menuVisible = true,
    this.menus = const <MenuEntry>[],
    this.backgroundBuilder,
    this.drawVisibleOnly = false,
    this.canAddEdges = false,
  });

  final InfiniteCanvasController controller;
  final Size gridSize;
  final double minScale, maxScale;
  final bool menuVisible;
  final List<MenuEntry> menus;
  final bool drawVisibleOnly;
  final bool canAddEdges;
  final Widget Function(BuildContext, Rect)? backgroundBuilder;

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

  Widget buildBackground(BuildContext context, Quad quad) {
    final viewport = axisAlignedBoundingBox(quad);
    if (widget.backgroundBuilder != null) {
      return widget.backgroundBuilder!(context, viewport);
    }
    return GridBackgroundBuilder(
      cellWidth: widget.gridSize.width,
      cellHeight: widget.gridSize.height,
      viewport: viewport,
    );
  }

  List<InfiniteCanvasNode> getNodes(BoxConstraints constraints) {
    if (widget.drawVisibleOnly) {
      final nodes = <InfiniteCanvasNode>[];
      final viewport = controller.getRect(constraints);
      for (final node in controller.nodes) {
        if (node.rect.overlaps(viewport)) {
          nodes.add(node);
        }
      }
      return nodes;
    }
    return controller.nodes;
  }

  List<InfiniteCanvasEdge> getEdges(BoxConstraints constraints) {
    if (widget.drawVisibleOnly) {
      final nodes = getNodes(constraints);
      final nodeKeys = nodes.map((e) => e.key).toSet();
      final edges = <InfiniteCanvasEdge>[];
      for (final edge in controller.edges) {
        if (nodeKeys.contains(edge.from) || nodeKeys.contains(edge.to)) {
          edges.add(edge);
        }
      }
      return edges;
    }
    return controller.edges;
  }

  @override
  Widget build(BuildContext context) {
    return InfiniteCanvasMenu(
      controller: widget.controller,
      visible: widget.menuVisible,
      menus: widget.menus,
      child: KeyboardListener(
        focusNode: controller.focusNode,
        onKeyEvent: (event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.shiftLeft ||
                event.logicalKey == LogicalKeyboardKey.shiftRight) {
              controller.shiftPressed = true;
            }
            if (event.logicalKey == LogicalKeyboardKey.controlLeft ||
                event.logicalKey == LogicalKeyboardKey.controlRight) {
              controller.controlPressed = true;
            }
            if (event.logicalKey == LogicalKeyboardKey.metaLeft ||
                event.logicalKey == LogicalKeyboardKey.metaRight) {
              controller.metaPressed = true;
            }
            if (event.logicalKey == LogicalKeyboardKey.space) {
              controller.spacePressed = true;
            }
          }
          if (event is KeyUpEvent) {
            if (event.logicalKey == LogicalKeyboardKey.shiftLeft ||
                event.logicalKey == LogicalKeyboardKey.shiftRight) {
              controller.shiftPressed = false;
            }
            if (event.logicalKey == LogicalKeyboardKey.metaLeft ||
                event.logicalKey == LogicalKeyboardKey.metaRight) {
              controller.metaPressed = false;
            }
            if (event.logicalKey == LogicalKeyboardKey.controlLeft ||
                event.logicalKey == LogicalKeyboardKey.controlRight) {
              controller.controlPressed = false;
              controller.linkStart = null;
              controller.linkEnd = null;
            }
            if (event.logicalKey == LogicalKeyboardKey.space) {
              controller.spacePressed = false;
            }
            if (event.logicalKey == LogicalKeyboardKey.delete ||
                event.logicalKey == LogicalKeyboardKey.backspace) {
              if (controller.focusNode.hasFocus) {
                controller.deleteSelection();
              }
            }
          }
        },
        child: Listener(
          onPointerDown: (details) {
            controller.mouseDown = true;
            controller.checkSelection(details.localPosition);
            if (controller.selection.isEmpty) {
              if (!controller.spacePressed) {
                controller.marqueeStart = details.localPosition;
                controller.marqueeEnd = details.localPosition;
              }
            } else {
              if (controller.controlPressed && widget.canAddEdges) {
                final selected = controller.selection.last;
                controller.linkStart = selected.key;
                controller.linkEnd = null;
              }
            }
          },
          onPointerUp: (details) {
            controller.mouseDown = false;
            if (controller.marqueeStart != null &&
                controller.marqueeEnd != null) {
              controller.checkMarqueeSelection();
            }
            if (controller.linkStart != null && controller.linkEnd != null) {
              controller.checkSelection(controller.linkEnd!);
              if (controller.selection.isNotEmpty) {
                final selected = controller.selection.last;
                controller.addLink(controller.linkStart!, selected.key);
              }
            }
            controller.marqueeStart = null;
            controller.marqueeEnd = null;
            controller.linkStart = null;
            controller.linkEnd = null;
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
            if (controller.linkStart != null) {
              controller.linkEnd = details.localPosition;
              controller.checkSelection(controller.linkEnd!, true);
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
                } else if (controller.spacePressed) {
                  controller.pan(details.focalPointDelta);
                } else if (controller.controlPressed) {
                } else {
                  controller.moveSelection(details.focalPoint);
                }
                controller.mousePosition = details.focalPoint;
              },
              minScale: widget.minScale,
              maxScale: widget.maxScale,
              boundaryMargin: const EdgeInsets.all(double.infinity),
              builder: (context, quad) {
                final nodes = getNodes(constraints);
                final edges = getEdges(constraints);
                return SizedBox.fromSize(
                  size: controller.getMaxSize().size,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(
                        child: buildBackground(context, quad),
                      ),
                      Positioned.fill(
                        child: InfiniteCanvasEdgeRenderer(
                          controller: controller,
                          edges: edges,
                          linkStart: controller
                              .getNode(controller.linkStart)
                              ?.rect
                              .center,
                          linkEnd: controller.linkEnd,
                        ),
                      ),
                      Positioned.fill(
                        child: CustomMultiChildLayout(
                          delegate: InfiniteCanvasNodesDelegate(nodes),
                          children: nodes
                              .map((e) => LayoutId(
                                    key: e.key,
                                    id: e,
                                    child: e.build(context, controller),
                                  ))
                              .toList(),
                        ),
                      ),
                      if (controller.marqueeStart != null &&
                          controller.marqueeEnd != null) ...[
                        Positioned.fill(
                          child: Marquee(
                            start: controller.toLocal(controller.marqueeStart!),
                            end: controller.toLocal(controller.marqueeEnd!),
                          ),
                        ),
                      ],
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

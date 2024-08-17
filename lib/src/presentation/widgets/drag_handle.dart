import 'dart:math';

import 'package:flutter/material.dart';
import 'package:infinite_canvas/infinite_canvas.dart';

class DragHandle extends StatefulWidget {
  final InfiniteCanvasController controller;
  final InfiniteCanvasNode node;
  final DragHandleAlignment alignment;
  final double size;
  final Size gridSize;
  final bool snapToGrid;
  final Size minimumNodeSize;

  const DragHandle({
    super.key,
    required this.controller,
    required this.node,
    required this.alignment,
    this.size = 10,
    required this.gridSize,
    this.snapToGrid = false,
    this.minimumNodeSize = const Size(InfiniteCanvasNode.dragHandleSize * 2, InfiniteCanvasNode.dragHandleSize * 2),
  });

  @override
  State<DragHandle> createState() => _DragHandleState();
}

class _DragHandleState extends State<DragHandle> {
  late final InfiniteCanvasController controller;
  late final InfiniteCanvasNode node;
  late final DragHandleAlignment al;
  late final double size;
  late final Size gridSize;
  late final bool snapToGrid;
  late final Size minimumNodeSize;

  late Rect initialBounds;
  late Offset draggingOffset;

  @override
  void initState() {
    super.initState();
    controller = widget.controller;
    node = widget.node;
    al = widget.alignment;
    size = widget.size;
    gridSize = widget.gridSize;
    snapToGrid = widget.snapToGrid;
    minimumNodeSize = widget.minimumNodeSize;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Listener(
        onPointerDown: (details) {
          initialBounds = Rect.fromLTWH(node.offset.dx, node.offset.dy, node.size.width, node.size.height);
          draggingOffset = Offset.zero;
        },
        onPointerUp: (details) {
          node.update(setCurrentlyResizing: false);
        },
        onPointerCancel: (details) {
          node.update(setCurrentlyResizing: false);
        },
        onPointerMove: (details) {
          if (!widget.controller.mouseDown) return;

          draggingOffset = draggingOffset + details.delta;
          Rect newBounds = initialBounds;

          if (al.isLeft) {
            final maxLeft = initialBounds.right - minimumNodeSize.width;
            newBounds = Rect.fromLTRB(
                min(maxLeft, newBounds.left + draggingOffset.dx), newBounds.top, newBounds.right, newBounds.bottom);
          }
          if (al.isTop) {
            final maxTop = initialBounds.bottom - minimumNodeSize.height;
            newBounds = Rect.fromLTRB(
                newBounds.left, min(maxTop, newBounds.top + draggingOffset.dy), newBounds.right, newBounds.bottom);
          }
          if (al.isRight) {
            newBounds = Rect.fromLTWH(newBounds.left, newBounds.top,
                max(minimumNodeSize.width, newBounds.width + draggingOffset.dx), newBounds.height);
          }
          if (al.isBottom) {
            newBounds = Rect.fromLTWH(newBounds.left, newBounds.top, newBounds.width,
                max(minimumNodeSize.height, newBounds.height + draggingOffset.dy));
          }

          // if (!snapToGrid) {
          //   // node.update(size: newSize, offset: newTopLeftCorner);
          // } else {
          //   // print(draggingOffset);
          //   final newTopLeftCorner = Offset(
          //       al.isLeft ? _adjustOffsetXToGrid(initialNodeOffset.dx + draggingOffset.dx) : initialNodeOffset.dx,
          //       al.isTop ? _adjustOffsetYToGrid(initialNodeOffset.dy + draggingOffset.dy) : initialNodeOffset.dy);
          //   final newBottomRightCorner = Offset(
          //       al.isRight
          //           ? _adjustOffsetXToGrid(newTopLeftCorner.dx + initialNodeSize.width + draggingOffset.dx)
          //           : node.offset.dx + node.size.width,
          //       al.isBottom
          //           ? _adjustOffsetYToGrid(newTopLeftCorner.dy + initialNodeSize.height + draggingOffset.dy)
          //           : node.offset.dy + node.size.height);
          //   final newSize =
          //       Size(newBottomRightCorner.dx - newTopLeftCorner.dx, newBottomRightCorner.dy - newTopLeftCorner.dy);

          // print(newBottomRightCorner);
          // print(newSize);
          node.update(size: newBounds.size, offset: newBounds.topLeft, setCurrentlyResizing: true);

          controller.edit(node);
        },
        child: Container(
          height: size,
          width: size,
          decoration: BoxDecoration(
            color: colors.surfaceVariant,
            border: Border.all(
              color: colors.onSurfaceVariant,
              width: 1,
            ),
          ),
        ));
  }

  Offset _adjustOffsetToGrid(Offset rawOffset) {
    return Offset(_adjustEdgeToGrid(rawOffset.dx, gridSize.width), _adjustEdgeToGrid(rawOffset.dy, gridSize.height));
  }

  double _adjustEdgeToGrid(double rawOffsetEdge, double gridEdge) {
    return (rawOffsetEdge / gridEdge).roundToDouble() * gridEdge;
  }
}

class DragHandleAlignment {
  final Alignment alignment;

  const DragHandleAlignment(this.alignment);

  bool get isLeft => alignment.x < 0;
  bool get isRight => alignment.x > 0;
  bool get isTop => alignment.y < 0;
  bool get isBottom => alignment.y > 0;
  bool get isHorizontalCenter => alignment.x == 0;
  bool get isVerticalCenter => alignment.y == 0;
}

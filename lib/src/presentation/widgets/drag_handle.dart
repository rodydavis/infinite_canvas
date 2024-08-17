import 'package:flutter/material.dart';
import 'package:infinite_canvas/infinite_canvas.dart';

class DragHandle extends StatefulWidget {
  final InfiniteCanvasController controller;
  final InfiniteCanvasNode node;
  final DragHandleAlignment alignment;
  final double size;
  final Size gridSize;
  final bool snapToGrid;

  const DragHandle({
    super.key,
    required this.controller,
    required this.node,
    required this.alignment,
    this.size = 10,
    required this.gridSize,
    this.snapToGrid = false,
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

  late Offset initialNodeOffset;
  late Size initialNodeSize;
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
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Listener(
        onPointerDown: (details) {
          initialNodeOffset = node.offset;
          initialNodeSize = node.size;
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
          Offset newTopLeftCorner = initialNodeOffset;
          Size newSize = initialNodeSize;

          if (al.isLeft) {
            newTopLeftCorner = newTopLeftCorner.translate(draggingOffset.dx, 0);
            newSize = Size(initialNodeOffset.dx + newSize.width - newTopLeftCorner.dx, newSize.height);
          }
          if (al.isTop) {
            newTopLeftCorner = newTopLeftCorner.translate(0, draggingOffset.dy);
            newSize = Size(newSize.width, initialNodeOffset.dy + newSize.height - newTopLeftCorner.dy);
          }
          if (al.isRight) {
            newSize = Size(newSize.width + draggingOffset.dx, newSize.height);
          }
          if (al.isBottom) {
            newSize = Size(newSize.width, newSize.height + draggingOffset.dy);
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
          node.update(size: newSize, offset: newTopLeftCorner, setCurrentlyResizing: true);

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

  double _adjustOffsetXToGrid(double rawOffset) {
    return (rawOffset / gridSize.width).roundToDouble() * gridSize.width;
  }

  double _adjustOffsetYToGrid(double rawOffset) {
    return (rawOffset / gridSize.height).roundToDouble() * gridSize.height;
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

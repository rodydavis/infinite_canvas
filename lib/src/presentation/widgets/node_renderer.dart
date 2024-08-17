import 'package:flutter/material.dart';

import '../../domain/model/node.dart';
import '../state/controller.dart';
import 'clipper.dart';
import 'drag_handle.dart';

class NodeRenderer extends StatelessWidget {
  const NodeRenderer({
    super.key,
    required this.node,
    required this.controller,
  });

  final InfiniteCanvasNode node;
  final InfiniteCanvasController controller;

  static const double borderInset = 2;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final fonts = Theme.of(context).textTheme;
    final showCornerHandles = node.resizeMode.containsCornerHandles && controller.isSelected(node.key);
    final showEdgeHandles = node.resizeMode.containsEdgeHandles && controller.isSelected(node.key);
    return SizedBox.fromSize(
      size: node.size,
      child: Stack(clipBehavior: Clip.none, children: [
        if (node.label != null)
          Positioned(
            top: -25,
            left: 0,
            child: Text(
              node.label!,
              style: fonts.bodyMedium?.copyWith(
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
          ),
        if (controller.isSelected(node.key) || controller.isHovered(node.key))
          Positioned(
            top: -borderInset,
            left: -borderInset,
            right: -borderInset,
            bottom: -borderInset,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: controller.isSelected(node.key) ? colors.primary : colors.outline,
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
        Positioned.fill(
          key: key,
          child: node.clipBehavior != Clip.none
              ? ClipRect(
                  clipper: Clipper(node.rect),
                  clipBehavior: node.clipBehavior,
                  child: node.child,
                )
              : node.child,
        ),
        if (showCornerHandles) ...[
          _buildDragHandle(Alignment.bottomRight),
          _buildDragHandle(Alignment.bottomLeft),
          _buildDragHandle(Alignment.topRight),
          _buildDragHandle(Alignment.topLeft),
        ],
        if (showEdgeHandles) ...[
          _buildDragHandle(Alignment.centerLeft),
          _buildDragHandle(Alignment.centerRight),
          _buildDragHandle(Alignment.topCenter),
          _buildDragHandle(Alignment.bottomCenter),
        ],
      ]),
    );
  }

  static const gridSize = Size.square(50);

  Positioned _buildDragHandle(Alignment alignment) {
    final dragHandleAlignment = DragHandleAlignment(alignment);
    return Positioned(
        left: dragHandleAlignment.isLeft
            ? 0
            : dragHandleAlignment.isHorizontalCenter
                ? node.size.width / 2
                : null,
        right: dragHandleAlignment.isRight ? 0 : null,
        top: dragHandleAlignment.isTop
            ? 0
            : dragHandleAlignment.isVerticalCenter
                ? node.size.height / 2
                : null,
        bottom: dragHandleAlignment.isBottom ? 0 : null,
        child: DragHandle(
          controller: controller,
          node: node,
          alignment: dragHandleAlignment,
          gridSize: gridSize,
          snapToGrid: controller.snapResizeToGrid,
        ));
  }
}

import 'package:flutter/material.dart';

import 'controller.dart';

/// A node in the [InfiniteCanvas].
class InfiniteCanvasNode {
  InfiniteCanvasNode({
    required this.key,
    required this.size,
    required this.offset,
    required this.child,
    this.label,
    this.allowResize = false,
    this.allowMove = true,
    this.clipBehavior = Clip.none,
  });

  final Key key;
  late Size size;
  late Offset offset;
  String? label;
  final Widget child;
  final bool allowResize, allowMove;
  final Clip clipBehavior;
  Rect get rect => offset & size;
  static const double dragHandleSize = 10;
  static const double borderInset = 2;

  void update({
    Size? size,
    Offset? offset,
    String? label,
  }) {
    if (offset != null && allowMove) this.offset = offset;
    if (size != null && allowResize) {
      if (size.width < dragHandleSize * 2) {
        size = Size(dragHandleSize * 2, size.height);
      }
      if (size.height < dragHandleSize * 2) {
        size = Size(size.width, dragHandleSize * 2);
      }
      this.size = size;
    }
    if (label != null) this.label = label;
  }

  Widget build(
    BuildContext context,
    InfiniteCanvasController controller,
  ) {
    final colors = Theme.of(context).colorScheme;
    final fonts = Theme.of(context).textTheme;
    final showHandles = allowResize && controller.isSelected(key);
    return SizedBox.fromSize(
      size: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (label != null)
            Positioned(
              top: -25,
              left: 0,
              child: Text(
                label!,
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
          if (controller.isSelected(key) || controller.isHovered(key))
            Positioned(
              top: -borderInset,
              left: -borderInset,
              right: -borderInset,
              bottom: -borderInset,
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: controller.isSelected(key)
                          ? colors.primary
                          : colors.outline,
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
          Positioned.fill(
            key: key,
            child: clipBehavior != Clip.none
                ? ClipRect(
                    clipper: _Clipper(rect),
                    clipBehavior: clipBehavior,
                    child: child,
                  )
                : child,
          ),
          if (showHandles) ...[
            // bottom right
            Positioned(
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onPanUpdate: (details) {
                  if (!controller.mouseDown) return;
                  update(size: size + details.delta);
                  controller.edit(this);
                },
                child: dragHandle(context),
              ),
            ),
            // bottom left
            Positioned(
              left: 0,
              bottom: 0,
              child: GestureDetector(
                onPanUpdate: (details) {
                  if (!controller.mouseDown) return;
                  update(
                    size: size + Offset(-details.delta.dx, details.delta.dy),
                    offset: offset + Offset(details.delta.dx, 0),
                  );
                  controller.edit(this);
                },
                child: dragHandle(context),
              ),
            ),
            // top right
            Positioned(
              right: 0,
              top: 0,
              child: GestureDetector(
                onPanUpdate: (details) {
                  if (!controller.mouseDown) return;
                  update(
                    size: size + Offset(details.delta.dx, -details.delta.dy),
                    offset: offset + Offset(0, details.delta.dy),
                  );
                  controller.edit(this);
                },
                child: dragHandle(context),
              ),
            ),
            // top left
            Positioned(
              left: 0,
              top: 0,
              child: GestureDetector(
                onPanUpdate: (details) {
                  if (!controller.mouseDown) return;
                  update(
                    size: size + -details.delta,
                    offset: offset + details.delta,
                  );
                  controller.edit(this);
                },
                child: dragHandle(context),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget dragHandle(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      height: dragHandleSize,
      width: dragHandleSize,
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        border: Border.all(
          color: colors.onSurfaceVariant,
          width: 1,
        ),
      ),
    );
  }
}

class _Clipper extends CustomClipper<Rect> {
  const _Clipper(this.rect);

  final Rect rect;

  @override
  Rect getClip(Size size) => rect;

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) => false;
}

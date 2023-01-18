import 'package:flutter/material.dart';

import 'controller.dart';

/// A node in the [InfiniteCanvas].
class InfiniteCanvasNode {
  const InfiniteCanvasNode({
    required this.key,
    required this.size,
    required this.offset,
    required this.builder,
    this.label,
  });

  final Key key;
  final Size size;
  final Offset offset;
  final WidgetBuilder builder;
  final String? label;
  Rect get rect => offset & size;

  InfiniteCanvasNode copyWith({
    Size? size,
    Offset? offset,
    String? label,
  }) {
    return InfiniteCanvasNode(
      key: key,
      builder: builder,
      label: label ?? this.label,
      size: size ?? this.size,
      offset: offset ?? this.offset,
    );
  }

  InfiniteCanvasNode clone() {
    return InfiniteCanvasNode(
      key: UniqueKey(),
      builder: builder,
      label: label,
      size: size,
      offset: offset,
    );
  }

  Widget build(BuildContext context, InfiniteCanvasController controller) {
    final colors = Theme.of(context).colorScheme;
    final fonts = Theme.of(context).textTheme;
    const double borderInset = 2;
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
          Positioned.fill(child: builder(context)),
        ],
      ),
    );
  }
}

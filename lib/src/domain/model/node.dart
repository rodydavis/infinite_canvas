import 'package:flutter/material.dart';

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
    Object? data,
  });

  String get id => key.toString();

  final LocalKey key;
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
}

import 'package:flutter/material.dart';

/// A node in the [InfiniteCanvas].
class InfiniteCanvasNode extends StatelessWidget {
  const InfiniteCanvasNode({
    required Key key,
    required this.size,
    required this.offset,
    required this.builder,
    this.label,
  }) : super(key: key);

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
      key: key!,
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

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: size,
      child: builder(context),
    );
  }
}

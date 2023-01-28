import 'package:flutter/material.dart';

/// An edge in the [InfiniteCanvas].
class InfiniteCanvasEdge {
  const InfiniteCanvasEdge({
    required this.from,
    required this.to,
    this.label,
  });

  final LocalKey from;
  final LocalKey to;
  final String? label;
}

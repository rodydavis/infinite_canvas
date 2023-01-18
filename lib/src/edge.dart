import 'package:flutter/material.dart';

/// An edge in the [InfiniteCanvas].
class InfiniteCanvasEdge {
  const InfiniteCanvasEdge({
    required this.from,
    required this.to,
    this.label,
  });

  final Key from;
  final Key to;
  final String? label;
}

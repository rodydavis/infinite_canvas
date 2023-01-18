import 'package:flutter/material.dart';

import 'node.dart';
import 'controller.dart';

/// A [CustomMultiChildLayout] delegate that renders the nodes in the [InfiniteCanvas].
class InfiniteCanvasNodesDelegate extends MultiChildLayoutDelegate {
  InfiniteCanvasNodesDelegate(this.controller);
  final InfiniteCanvasController controller;
  List<InfiniteCanvasNode> get children => controller.nodes;

  @override
  void performLayout(Size size) {
    for (final widget in children) {
      layoutChild(widget, BoxConstraints.tight(widget.size));
      positionChild(widget, widget.offset);
    }
  }

  @override
  bool shouldRelayout(InfiniteCanvasNodesDelegate oldDelegate) => true;
}

import 'package:flutter/material.dart';
import 'package:infinite_canvas/src/presentation/utils/helpers.dart';

/// A node in the [InfiniteCanvas].
class InfiniteCanvasNode<T> {
  InfiniteCanvasNode({
    required this.key,
    required this.size,
    required this.offset,
    required this.child,
    this.label,
    this.resizeMode = ResizeMode.disabled,
    this.allowMove = true,
    this.clipBehavior = Clip.none,
    this.value,
  });

  String get id => key.toString();

  final LocalKey key;
  late Size size;
  late Offset offset;
  String? label;
  T? value;
  final Widget child;
  final ResizeMode resizeMode;
  bool currentlyResizing = false;
  final bool allowMove;
  final Clip clipBehavior;
  Rect get rect => offset & size;
  static const double dragHandleSize = 10;
  static const double borderInset = 2;

  void update(
      {Size? size,
      Offset? offset,
      String? label,
      bool? setCurrentlyResizing,
      bool? snapMovementToGrid,
      Size? gridSize}) {
    if (setCurrentlyResizing != null) {
      currentlyResizing = setCurrentlyResizing;
    }

    if (offset != null && setCurrentlyResizing == true) {
      this.offset = offset;
    } else if (offset != null &&
        setCurrentlyResizing == null &&
        allowMove &&
        !currentlyResizing) {
      if (snapMovementToGrid == true && gridSize != null) {
        final snappedX = _getClosestSnapPosition(
            offset.dx, size?.width ?? this.size.width, gridSize.width);
        final snappedY = _getClosestSnapPosition(
            offset.dy, size?.height ?? this.size.height, gridSize.height);
        this.offset = Offset(snappedX, snappedY);
      } else {
        this.offset = offset;
      }
    }

    if (size != null && resizeMode.isEnabled) {
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

  double _getClosestSnapPosition(
      double rawEdge, double nodeLength, double gridEdge) {
    final snapAtStartPos = adjustEdgeToGrid(rawEdge, gridEdge);
    final snapAtStartDelta = (snapAtStartPos - rawEdge).abs();
    final snapAtEndPos =
        adjustEdgeToGrid(rawEdge + nodeLength, gridEdge) - nodeLength;
    final snapAtEndDelta = (snapAtEndPos - rawEdge).abs();

    if (snapAtEndDelta < snapAtStartDelta) {
      return snapAtEndPos;
    }
    return snapAtStartPos;
  }
}

enum ResizeMode {
  disabled,
  corners,
  edges,
  cornersAndEdges;

  bool get isEnabled => this != ResizeMode.disabled;
  bool get containsCornerHandles =>
      this == ResizeMode.corners || this == ResizeMode.cornersAndEdges;
  bool get containsEdgeHandles =>
      this == ResizeMode.edges || this == ResizeMode.cornersAndEdges;
}

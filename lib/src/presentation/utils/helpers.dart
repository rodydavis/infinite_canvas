double adjustEdgeToGrid(double rawOffsetEdge, double gridEdge,
    {double? minimum, double? maximum}) {
  double snappedBound = (rawOffsetEdge / gridEdge).roundToDouble() * gridEdge;
  if (minimum != null && snappedBound < minimum) {
    return minimum;
  }
  if (maximum != null && snappedBound > maximum) {
    return maximum;
  }
  return snappedBound;
}

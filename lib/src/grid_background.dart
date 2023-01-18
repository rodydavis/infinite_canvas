import 'package:flutter/material.dart';

/// Background grid for the [InfiniteCanvas].
class GridBackgroundBuilder extends StatelessWidget {
  const GridBackgroundBuilder({
    super.key,
    required this.cellWidth,
    required this.cellHeight,
    required this.viewport,
  });

  final double cellWidth;
  final double cellHeight;
  final Rect viewport;

  @override
  Widget build(BuildContext context) {
    final int firstRow = (viewport.top / cellHeight).floor();
    final int lastRow = (viewport.bottom / cellHeight).ceil();
    final int firstCol = (viewport.left / cellWidth).floor();
    final int lastCol = (viewport.right / cellWidth).ceil();

    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.background,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          for (int row = firstRow; row < lastRow; row++)
            for (int col = firstCol; col < lastCol; col++)
              Positioned(
                left: col * cellWidth,
                top: row * cellHeight,
                child: Container(
                  height: cellHeight,
                  width: cellWidth,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: colors.onBackground.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

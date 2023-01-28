import 'package:flutter/material.dart';

class DragHandel extends StatelessWidget {
  const DragHandel({
    super.key,
    this.size = 10,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      height: size,
      width: size,
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

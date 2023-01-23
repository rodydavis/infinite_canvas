import 'dart:math';

import 'package:flutter/material.dart';
import 'package:infinite_canvas/infinite_canvas.dart';

class LevelOfDetail extends StatefulWidget {
  const LevelOfDetail({super.key});

  @override
  State<LevelOfDetail> createState() => _LevelOfDetailState();
}

class _LevelOfDetailState extends State<LevelOfDetail> {
  late InfiniteCanvasController controller;

  @override
  void initState() {
    super.initState();
    controller = InfiniteCanvasController();
    controller.add(InfiniteCanvasNode(
      key: UniqueKey(),
      size: const Size(400, 800),
      offset: Offset.zero,
      child: Builder(
        builder: (context) => DynamicChild(
          controller: controller,
          builder: (context, scale) {
            final colors = Theme.of(context).colorScheme;
            // Min scale: 0.4, Max scale: 4.0
            if (scale >= 1) {
              return Scaffold(
                appBar: AppBar(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                  title: const Text('Scaffold'),
                  centerTitle: false,
                ),
                body: Center(
                  child: Text(
                    'Scale: ${scale.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                floatingActionButton: FloatingActionButton(
                  child: const Icon(Icons.add),
                  onPressed: () {},
                ),
              );
            }
            if (scale >= 0.5) {
              return Scaffold(
                appBar: AppBar(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                  title: const Text('Scaffold'),
                  centerTitle: false,
                ),
                floatingActionButton: FloatingActionButton(
                  child: const Icon(Icons.add),
                  onPressed: () {},
                ),
              );
            }
            return Scaffold(
              appBar: AppBar(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                title: Container(),
              ),
              floatingActionButton: FloatingActionButton(
                child: Container(),
                onPressed: () {},
              ),
            );
          },
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Level of Detail Example'),
        centerTitle: false,
      ),
      body: InfiniteCanvas(
        drawVisibleOnly: true,
        canAddEdges: true,
        controller: controller,
      ),
    );
  }
}

class DynamicChild extends StatelessWidget {
  const DynamicChild({
    Key? key,
    required this.controller,
    required this.builder,
  }) : super(key: key);

  final InfiniteCanvasController controller;
  final Widget Function(BuildContext context, double scale) builder;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final scale = controller.getScale();
        return builder(context, scale);
      },
    );
  }
}

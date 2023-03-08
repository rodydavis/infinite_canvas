import 'package:flutter/material.dart';
import 'package:infinite_canvas/infinite_canvas.dart';

import 'widgets/canvas_widget.dart';
import 'state.dart';

class Editor extends StatefulWidget {
  const Editor({super.key});

  @override
  State<Editor> createState() => _EditorState();
}

class _EditorState extends State<Editor> {
  final controller = EditorController();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Infinite Canvas Example'),
        centerTitle: false,
      ),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return Row(
            children: [
              Expanded(
                child: InfiniteCanvas(
                  drawVisibleOnly: true,
                  canAddEdges: true,
                  controller: controller,
                  gridSize: controller.gridSize,
                  menus: controller.buildMenus(context),
                ),
              ),
              const VerticalDivider(width: 0),
              Container(
                width: 300,
                color: colors.surfaceVariant,
                child: Builder(
                  builder: (context) {
                    final selection = controller.selection;
                    if (selection.isEmpty) {
                      return const Center(
                        child: Text('No selection'),
                      );
                    }
                    if (selection.length > 1) {
                      return const Center(
                        child: Text('Multiple selection'),
                      );
                    }
                    final selected = selection.first.child;
                    if (selected is! CanvasWidget) {
                      return const Center(
                        child: Text('Unknown selection'),
                      );
                    }
                    final knobKeys =
                        (selected as CanvasWidget).value!.keys.toList();
                    final typeKnob = (selected as CanvasWidget)
                        .value!
                        .knob<ReadOnlyKnob<String>>('type');
                    knobKeys.remove('label');
                    return ListView(
                      children: [
                        ListTile(
                          title: const Text('Type'),
                          subtitle: Text(typeKnob.value),
                        ),
                        for (final key in knobKeys)
                          ListTile(
                            title: Text(key),
                            subtitle: Text((selected as CanvasWidget)
                                .value!
                                .knob(key)
                                .value
                                .toString()),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

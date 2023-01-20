import 'package:easy_web_view/easy_web_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:infinite_canvas/infinite_canvas.dart';

class WebViews extends StatefulWidget {
  const WebViews({super.key});

  @override
  State<WebViews> createState() => _WebViewsState();
}

class _WebViewsState extends State<WebViews> {
  late InfiniteCanvasController controller;

  @override
  void initState() {
    super.initState();
    controller = InfiniteCanvasController(nodes: [
      createNode(),
    ]);
  }

  InfiniteCanvasNode createNode() {
    final Key key = UniqueKey();
    final Key webKey = UniqueKey();
    return InfiniteCanvasNode(
      key: key,
      size: const Size(800, 800),
      offset: Offset.zero,
      child: Column(
        children: [
          Builder(builder: (context) {
            final colors = Theme.of(context).colorScheme;
            return Container(
              color: colors.surfaceVariant,
              child: Row(
                children: [
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      controller.remove(key);
                    },
                  ),
                ],
              ),
            );
          }),
          Expanded(
            child: EasyWebView(
              key: webKey,
              src: 'https://flutter.dev',
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Infinite Canvas Example'),
        centerTitle: false,
      ),
      body: InfiniteCanvas(
        controller: controller,
        menus: [
          MenuEntry(
            label: 'Add New',
            shortcut: const SingleActivator(
              LogicalKeyboardKey.keyN,
              meta: true,
            ),
            onPressed: () {
              controller.add(createNode());
            },
          ),
        ],
      ),
    );
  }
}

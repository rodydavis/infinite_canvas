import 'dart:math';

import 'package:flutter/material.dart';
import 'package:infinite_canvas/infinite_canvas.dart';
import 'package:random_color/random_color.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const Home(),
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: ThemeMode.system,
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late InfiniteCanvasController controller;

  @override
  void initState() {
    super.initState();
    // Generate random nodes
    final colors = RandomColor();
    final nodes = List.generate(100, (index) {
      final color = colors.randomColor();
      return InfiniteCanvasNode(
        key: UniqueKey(),
        label: 'Node $index',
        allowResize: true,
        offset: Offset(
          Random().nextDouble() * 5000,
          Random().nextDouble() * 5000,
        ),
        size: Size(
          Random().nextDouble() * 200 + 100,
          Random().nextDouble() * 200 + 100,
        ),
        child: Builder(
          builder: (context) {
            return CustomPaint(
              painter: InlineCustomPainter(
                brush: Paint()..color = color,
                builder: (brush, canvas, rect) {
                  // Draw circle
                  canvas.drawCircle(rect.center, rect.width / 2, brush);
                },
              ),
            );
          },
        ),
      );
    });
    // Generate random edges
    final edges = <InfiniteCanvasEdge>[];
    for (var i = 0; i < nodes.length; i++) {
      final from = nodes[i];
      final to = nodes[Random().nextInt(nodes.length)];
      if (from != to) {
        edges.add(InfiniteCanvasEdge(
          from: from.key,
          to: to.key,
          label: 'Edge $i',
        ));
      }
    }
    controller = InfiniteCanvasController(nodes: nodes, edges: edges);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Infinite Canvas Example'),
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

class InlineCustomPainter extends CustomPainter {
  const InlineCustomPainter({
    required this.brush,
    required this.builder,
    this.isAntiAlias = true,
  });
  final Paint brush;
  final bool isAntiAlias;
  final void Function(Paint paint, Canvas canvas, Rect rect) builder;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    brush.isAntiAlias = isAntiAlias;
    canvas.save();
    builder(brush, canvas, rect);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class CounterExample extends StatefulWidget {
  const CounterExample({super.key});

  @override
  State<CounterExample> createState() => _CounterExampleState();
}

class _CounterExampleState extends State<CounterExample> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Demo Home Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (mounted) {
            setState(() {
              _counter++;
            });
          }
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class DraggableExample extends StatefulWidget {
  const DraggableExample({super.key});

  @override
  State<DraggableExample> createState() => _DraggableExampleState();
}

class _DraggableExampleState extends State<DraggableExample> {
  double _amount = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Draggable Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Slider(
              value: _amount,
              onChanged: (value) {
                if (mounted) {
                  setState(() {
                    _amount = value;
                  });
                }
              },
            ),
            Text('Value: $_amount'),
          ],
        ),
      ),
    );
  }
}

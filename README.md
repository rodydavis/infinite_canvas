# Infinite Canvas

Flutter infinite canvas that can be zoomed and panned.

> There is also a menu for common actions and marquee for multiple selection.

## Example

```dart
import 'package:flutter/material.dart';
import 'package:infinite_canvas/infinite_canvas.dart';

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
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    final nodes = [
      InfiniteCanvasNode(
        label: 'Flutter Counter',
        key: UniqueKey(),
        offset: Offset.zero,
        size: const Size(400, 800),
        builder: (context) => StatefulBuilder(
          builder: (context, setState) => Scaffold(
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
          ),
        ),
      ),
      InfiniteCanvasNode(
        key: UniqueKey(),
        offset: const Offset(600, 100),
        size: const Size(400, 800),
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Gradient'),
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                  Theme.of(context).colorScheme.tertiary,
                ],
              ),
            ),
          ),
        ),
      ),
      InfiniteCanvasNode(
        key: UniqueKey(),
        label: 'Rectangle',
        offset: const Offset(400, 300),
        size: const Size(200, 200),
        builder: (context) => CustomPaint(
          isComplex: true,
          willChange: true,
          painter: InlineCustomPainter(
            brush: Paint(),
            builder: (brush, canvas, rect) {
              // Draw rect
              brush.color = Theme.of(context).colorScheme.secondary;
              canvas.drawRect(rect, brush);
            },
          ),
        ),
      ),
      InfiniteCanvasNode(
        key: UniqueKey(),
        label: 'Triangle',
        offset: const Offset(550, 300),
        size: const Size(200, 200),
        builder: (context) => CustomPaint(
          painter: InlineCustomPainter(
            brush: Paint(),
            builder: (brush, canvas, rect) {
              // Draw triangle
              brush.color = Theme.of(context).colorScheme.secondaryContainer;
              final path = Path();
              path.addPolygon([
                rect.topCenter,
                rect.bottomLeft,
                rect.bottomRight,
              ], true);
              canvas.drawPath(path, brush);
            },
          ),
        ),
      ),
      InfiniteCanvasNode(
        key: UniqueKey(),
        label: 'Circle',
        offset: const Offset(500, 450),
        size: const Size(200, 200),
        builder: (context) => CustomPaint(
          painter: InlineCustomPainter(
            brush: Paint(),
            builder: (brush, canvas, rect) {
              // Draw circle
              brush.color = Theme.of(context).colorScheme.tertiary;
              canvas.drawCircle(rect.center, rect.width / 2, brush);
            },
          ),
        ),
      ),
    ];
    controller = InfiniteCanvasController(nodes: nodes, edges: [
      InfiniteCanvasEdge(
        from: nodes[2].key!,
        to: nodes[3].key!,
        label: 'Edge 1',
      ),
      InfiniteCanvasEdge(
        from: nodes[2].key!,
        to: nodes[4].key!,
        label: 'Edge 1',
      ),
    ]);
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
```

## Links

- [Source Code](https://github.com/rodydavis/infinite_canvas)
- [Online Demo](https://rodydavis.github.io/infinite_canvas/)

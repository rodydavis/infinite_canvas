import 'package:collection/collection.dart';
import 'package:directed_graph/directed_graph.dart';
export 'package:directed_graph/directed_graph.dart';

import 'node.dart';
import 'edge.dart';

class Graph {
  const Graph(this.nodes, this.edges);

  final List<InfiniteCanvasNode> nodes;
  final List<InfiniteCanvasEdge> edges;
}

extension GraphUtils on Graph {
  InfiniteCanvasNode? getNodeById(String id) {
    return nodes.firstWhereOrNull((node) => node.key.toString() == id);
  }

  List<InfiniteCanvasNode> getEdgesByNode(InfiniteCanvasNode node) {
    return edges
        .where((edge) {
          return edge.from.toString() == node.key.toString() ||
              edge.to.toString() == node.key.toString();
        })
        .map((edge) {
          final from = getNodeById(edge.from.toString());
          final to = getNodeById(edge.to.toString());
          return [from, to];
        })
        .expand((element) => element)
        .whereNotNull()
        .toList();
  }

  int comparator(InfiniteCanvasNode s1, InfiniteCanvasNode s2) {
    return s1.key.toString().compareTo(s2.key.toString());
  }

  int inverseComparator(InfiniteCanvasNode s1, InfiniteCanvasNode s2) {
    return -comparator(s1, s2);
  }

  DirectedGraph<InfiniteCanvasNode> getDirectedGraph({bool reverse = false}) {
    final graph = DirectedGraph<InfiniteCanvasNode>(
      {
        for (final node in nodes) node: getEdgesByNode(node).toSet(),
      },
    );
    if (reverse) {
      graph.comparator = inverseComparator;
    } else {
      graph.comparator = comparator;
    }
    return graph;
  }
}

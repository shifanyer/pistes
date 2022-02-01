import 'dart:collection';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pistes/graph/resort_point.dart';

class ResortGraph {
  Map<int, List<ResortPoint>> connections;

  ResortGraph(this.connections);

  void addConnection(ResortPoint startPoint, ResortPoint endPoint) {
    if (connections[startPoint.pointId] == null) {
      connections[startPoint.pointId] = [endPoint];
    } else {
      connections[startPoint.pointId]!.add(endPoint);
    }
  }

  List findRoute(int startId, int endId) {
    var q = Queue<int>();
    q.add(startId);
    Map<int, bool> isUsed = {};
    Map<int, int> parent = {};
    Map<int, int> weight = {};
    isUsed[startId] = true;
    parent[startId] = -1;
    while (q.isNotEmpty) {
      int vertex = q.first;
      q.removeFirst();
      for (int i = 0; i < (connections[vertex]?.length ?? 0); i++) {
        int nextVertex = connections[vertex]![i].pointId;
        if ((isUsed[nextVertex] == null) || (isUsed[nextVertex] == false)) {
          isUsed[nextVertex] = true;
          q.add(nextVertex);
          parent[nextVertex] = vertex;
        }
      }
    }

    if ((isUsed[endId] == null) || (isUsed[endId] == false)) {
      return [];
    } else {
      var path = <int>[];
      for (var vertex = endId; vertex != -1; vertex = parent[vertex]!) {
        path.add(vertex);
      }
      return path;
    }
  }

  void display() {
    print(connections);
  }
}

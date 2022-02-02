import 'dart:collection';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pistes/graph/resort_point.dart';

class ResortGraph {
  Map<int, List<ResortPoint>> _connections = {};
  Map<int, List<int>> _connectionDifficulty = {};
  int? startPointId;
  int? endPointId;
  int lastDifficulty = 2;

  ResortGraph._privateConstructor();

  static final ResortGraph _instance = ResortGraph._privateConstructor();

  factory ResortGraph() {
    return _instance;
  }

  void addConnection(ResortPoint startPoint, ResortPoint endPoint, {int difficulty = 0}) {
    if (_connections[startPoint.pointId] == null) {
      _connections[startPoint.pointId] = [endPoint];
      _connectionDifficulty[startPoint.pointId] = [difficulty];
    } else {
      _connections[startPoint.pointId]!.add(endPoint);
      _connectionDifficulty[startPoint.pointId]!.add(difficulty);
    }
  }

  List findRoute() {
    if ((startPointId == null) || (endPointId == null)){
      return [];
    }

    var startId = startPointId!;
    var endId = endPointId!;
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
      for (int i = 0; i < (_connections[vertex]?.length ?? 0); i++) {
        int nextVertex = _connections[vertex]![i].pointId;
        if (((isUsed[nextVertex] == null) || (isUsed[nextVertex] == false)) && (_connectionDifficulty[vertex]![i] <= lastDifficulty)) {
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
    print(_connections);
  }
}

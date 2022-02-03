import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pistes/graph/resort_point.dart';

import '../graph/resort_graph.dart';

class PolyLinesHandler {
  final StreamController<String> mapUpdController;

  PolyLinesHandler(this.mapUpdController);

  var polyLines = <String, Polyline>{};

  void _pisteTap(Polyline line) {
    int lineWidth = 0;

    if ((polyLines[line.polylineId.value + 'selected'] == null) || (polyLines[line.polylineId.value + 'selected']!.width == 0)) {
      lineWidth = 12;
    }

    polyLines[line.polylineId.value + 'selected'] = Polyline(
        polylineId: PolylineId(line.polylineId.value + 'selected'),
        points: line.points,
        width: lineWidth,
        color: Colors.orange.withOpacity(0.4),
        consumeTapEvents: true,
        endCap: Cap.roundCap,
        startCap: Cap.roundCap,
        onTap: () {
          _pisteTap(polyLines[line.polylineId.value]!);
        });

    mapUpdController.add('piste tap');
    // setState(() {});
  }

  void addPiste(String pisteKey, List<LatLng> geoList, Color pisteColor) {
    polyLines[pisteKey] = (Polyline(
        polylineId: PolylineId(pisteKey),
        points: geoList,
        width: 3,
        color: pisteColor,
        consumeTapEvents: false,
        onTap: () {
          _pisteTap(polyLines[pisteKey]!);
        }));
  }

  void addAerialway(String aerialwayKey, List<LatLng> geoList, Color aerialwayColor) {
    polyLines[aerialwayKey] = (Polyline(
        polylineId: PolylineId(aerialwayKey),
        points: geoList,
        width: 4,
        color: aerialwayColor,
        patterns: [PatternItem.dash(10), PatternItem.gap(10)],
        consumeTapEvents: false,
        onTap: () {}));
  }

  void drawPath() {
    var newGraph = ResortGraph();
    var path = newGraph.findRoute();
    polyLines['selected path'] = Polyline(
      polylineId: PolylineId('selected path'),
      points: path,
      width: 12,
      color: Colors.orange.withOpacity(0.4),
      consumeTapEvents: false,
    );
    mapUpdController.add('draw path');
  }

  void erasePath() {
    if (polyLines['selected path'] != null) {
      polyLines.remove('selected path');

      mapUpdController.add('erase path');
    }
  }

  void clear() {
    polyLines.clear();
  }
}

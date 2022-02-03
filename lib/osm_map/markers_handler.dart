import 'dart:async';
import 'dart:ui';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pistes/graph/resort_graph.dart';
import 'package:pistes/osm_map/polylines_handler.dart';

import '../enums/marker_types.dart';

class MarkersHandler {

  Map<MarkerType, BitmapDescriptor> customMarkers;
  final PolyLinesHandler polyLinesHandler;
  final StreamController<String> mapUpdController;

  MarkersHandler(this.customMarkers, this.polyLinesHandler, this.mapUpdController);

  var markers = <String, Marker>{};

  void createMarker(String pointKey, Map points, int markerType) {
    var tmpMarker = customMarkers[MarkerType.tmpMarker]!;
    switch (markerType) {
      case (0):
        tmpMarker = customMarkers[MarkerType.aerialway]!;
        break;
      case (1):
        tmpMarker = customMarkers[MarkerType.green]!;
        break;
      case (2):
        tmpMarker = customMarkers[MarkerType.blue]!;
        break;
      case (3):
        tmpMarker = customMarkers[MarkerType.red]!;
        break;
      case (4):
        tmpMarker = customMarkers[MarkerType.black]!;
        break;
      case (5):
        tmpMarker = customMarkers[MarkerType.yellow]!;
        break;
    }
    markers[pointKey] = Marker(
        markerId: MarkerId(pointKey),
        position: LatLng(double.parse(points[pointKey]['lat']), double.parse(points[pointKey]['lon'])),
        icon: tmpMarker,
        anchor: const Offset(0.5, 0.5),
        onTap: () {
          _markerTap(markers[pointKey]!);
        });
  }

  void createMarkers(List<String> pointsKeyList, Map points, int markerType) {
    var tmpMarker = customMarkers[MarkerType.tmpMarker]!;
    switch (markerType) {
      case (0):
        tmpMarker = customMarkers[MarkerType.aerialway]!;
        break;
      case (1):
        tmpMarker = customMarkers[MarkerType.green]!;
        break;
      case (2):
        tmpMarker = customMarkers[MarkerType.blue]!;
        break;
      case (3):
        tmpMarker = customMarkers[MarkerType.red]!;
        break;
      case (4):
        tmpMarker = customMarkers[MarkerType.black]!;
        break;
      case (5):
        tmpMarker = customMarkers[MarkerType.yellow]!;
        break;
    }
    for (var pointKey in pointsKeyList) {
      markers[pointKey] = Marker(
          markerId: MarkerId(pointKey),
          position: LatLng(double.parse(points[pointKey]['lat']), double.parse(points[pointKey]['lon'])),
          icon: tmpMarker,
          anchor: const Offset(0.5, 0.5),
          onTap: () {
            _markerTap(markers[pointKey]!);
          });
    }
  }

  void _markerTap(Marker marker) {
    var resortGraph = ResortGraph();
    if (int.parse(marker.markerId.value) == resortGraph.startPointId) {
      resortGraph.startPointId = null;
      _deselectMarker(marker.markerId.value);
      polyLinesHandler.erasePath();
      mapUpdController.add('deselect start');
      return;
    }
    if (int.parse(marker.markerId.value) == resortGraph.endPointId) {
      resortGraph.endPointId = null;
      _deselectMarker(marker.markerId.value);
      polyLinesHandler.erasePath();

      mapUpdController.add('deselect end');
      return;
    }
    if (resortGraph.startPointId == null) {
      resortGraph.startPointId = int.parse(marker.markerId.value);
      _selectMarker(marker.markerId.value);
      polyLinesHandler.drawPath();

      mapUpdController.add('select start');
      return;
    }
    if (resortGraph.endPointId == null) {
      resortGraph.endPointId = int.parse(marker.markerId.value);
      _selectMarker(marker.markerId.value);
      polyLinesHandler.drawPath();
      mapUpdController.add('select end');
      return;
    }
    if ((resortGraph.startPointId != null) && (resortGraph.endPointId != null)) {
      _deselectMarker(resortGraph.endPointId.toString());
      _selectMarker(marker.markerId.value);
      resortGraph.endPointId = int.parse(marker.markerId.value);
      polyLinesHandler.drawPath();
      mapUpdController.add('replace end');
      return;
    }
  }

  void _selectMarker(String markerId) {
    var newIcon = customMarkers[MarkerType.tmpMarkerChose];
    if (markers[markerId]!.icon == customMarkers[MarkerType.aerialway]) {
      newIcon = customMarkers[MarkerType.aerialwayChose];
    }
    if (markers[markerId]!.icon == customMarkers[MarkerType.green]) {
      newIcon = customMarkers[MarkerType.greenChose];
    }
    if (markers[markerId]!.icon == customMarkers[MarkerType.blue]) {
      newIcon = customMarkers[MarkerType.blueChose];
    }
    if (markers[markerId]!.icon == customMarkers[MarkerType.red]) {
      newIcon = customMarkers[MarkerType.redChose];
    }
    if (markers[markerId]!.icon == customMarkers[MarkerType.black]) {
      newIcon = customMarkers[MarkerType.blackChose];
    }
    if (markers[markerId]!.icon == customMarkers[MarkerType.yellow]) {
      newIcon = customMarkers[MarkerType.yellowChose];
    }
    markers[markerId] = Marker(
        markerId: markers[markerId]!.markerId,
        position: markers[markerId]!.position,
        icon: newIcon!,
        anchor: const Offset(0.5, 0.5),
        onTap: () {
          _markerTap(markers[markerId]!);
        });
  }

  void _deselectMarker(String markerId) {
    var newIcon = customMarkers[MarkerType.tmpMarker];
    if (markers[markerId]!.icon == customMarkers[MarkerType.aerialwayChose]) {
      newIcon = customMarkers[MarkerType.aerialway];
    }
    if (markers[markerId]!.icon == customMarkers[MarkerType.greenChose]) {
      newIcon = customMarkers[MarkerType.green];
    }
    if (markers[markerId]!.icon == customMarkers[MarkerType.blueChose]) {
      newIcon = customMarkers[MarkerType.blue];
    }
    if (markers[markerId]!.icon == customMarkers[MarkerType.redChose]) {
      newIcon = customMarkers[MarkerType.red];
    }
    if (markers[markerId]!.icon == customMarkers[MarkerType.blackChose]) {
      newIcon = customMarkers[MarkerType.black];
    }
    if (markers[markerId]!.icon == customMarkers[MarkerType.yellowChose]) {
      newIcon = customMarkers[MarkerType.yellow];
    }

    markers[markerId] = Marker(
        markerId: markers[markerId]!.markerId,
        position: markers[markerId]!.position,
        icon: newIcon!,
        anchor: const Offset(0.5, 0.5),
        onTap: () {
          _markerTap(markers[markerId]!);
        });
  }

}

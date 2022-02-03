import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pistes/device_description/size_config.dart';
import 'package:pistes/enums/marker_types.dart';
import 'package:pistes/graph/resort_graph.dart';
import 'package:pistes/osm_map/map_field.dart';
import 'package:pistes/osm_map/polylines_handler.dart';

import '../graph/resort_point.dart';
import 'difficulty_slider.dart';

class DefaultMap extends StatefulWidget {
  const DefaultMap({Key? key}) : super(key: key);

  @override
  State<DefaultMap> createState() => _DefaultMapState();
}

class _DefaultMapState extends State<DefaultMap> {
  var mapUpdateController = StreamController<String>();
  late PolyLinesHandler polyLinesHandler;
  var _markers = <String, Marker>{};
  var _resortPoints = <int, ResortPoint>{};
  Map<MarkerType, BitmapDescriptor> customMarkers = {};
  late ResortGraph resortGraph;

  Future<Map<MarkerType, BitmapDescriptor>> _loadMarkers() async {
    customMarkers[MarkerType.tmpMarker] = BitmapDescriptor.fromBytes(await getBytesFromAsset('assets/markers/tmp2.png', 80));
    customMarkers[MarkerType.tmpMarkerChose] = BitmapDescriptor.fromBytes(await getBytesFromAsset('assets/markers/tmp3.png', 80));
    customMarkers[MarkerType.green] = BitmapDescriptor.fromBytes(await getBytesFromAsset('assets/markers/green.png', 80));
    customMarkers[MarkerType.greenChose] = BitmapDescriptor.fromBytes(await getBytesFromAsset('assets/markers/green_chose.png', 80));
    customMarkers[MarkerType.blue] = BitmapDescriptor.fromBytes(await getBytesFromAsset('assets/markers/blue.png', 80));
    customMarkers[MarkerType.blueChose] = BitmapDescriptor.fromBytes(await getBytesFromAsset('assets/markers/blue_chose.png', 80));
    customMarkers[MarkerType.red] = BitmapDescriptor.fromBytes(await getBytesFromAsset('assets/markers/red.png', 80));
    customMarkers[MarkerType.redChose] = BitmapDescriptor.fromBytes(await getBytesFromAsset('assets/markers/red_chose.png', 80));
    customMarkers[MarkerType.black] = BitmapDescriptor.fromBytes(await getBytesFromAsset('assets/markers/black.png', 80));
    customMarkers[MarkerType.blackChose] = BitmapDescriptor.fromBytes(await getBytesFromAsset('assets/markers/black_chose.png', 80));
    customMarkers[MarkerType.yellow] = BitmapDescriptor.fromBytes(await getBytesFromAsset('assets/markers/yellow.png', 80));
    customMarkers[MarkerType.yellowChose] = BitmapDescriptor.fromBytes(await getBytesFromAsset('assets/markers/yellow_chose.png', 80));
    customMarkers[MarkerType.aerialway] = BitmapDescriptor.fromBytes(await getBytesFromAsset('assets/markers/aerialway.png', 80));
    customMarkers[MarkerType.aerialwayChose] = BitmapDescriptor.fromBytes(await getBytesFromAsset('assets/markers/aerialway_chose.png', 80));
    return customMarkers;
  }

  @override
  void initState() {
    polyLinesHandler = PolyLinesHandler(mapUpdateController);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder(
          future: _loadMarkers(),
          builder: (context, snapshot) {
            return Column(
              children: [
                SizedBox(
                  width: SizeConfig.screenWidth,
                  height: SizeConfig.screenHeight * 0.8,
                  child: (snapshot.data != null)
                      ? SafeArea(
                          child: MainMap(
                            markers: _markers,
                            polyLines: polyLinesHandler.polyLines,
                            mapUpdController: mapUpdateController,
                          ),
                        )
                      : const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                ),
                Flexible(
                  child: Container(
                    width: SizeConfig.screenWidth,
                    height: SizeConfig.screenHeight * 0.2,
                    color: Colors.white,
                    child: DifficultySlider(
                      polyLines: polyLinesHandler.polyLines,
                      resortPoints: _resortPoints,
                      mapUpdController: mapUpdateController,
                    ),
                  ),
                )
              ],
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var resorts = await loadResortsData();
          resortGraph = ResortGraph();
          var redLake = resorts['resorts']['red lake'];
          var _pistes = redLake['pistes'];
          var _aerialways = redLake['aerialways'];
          var _points = redLake['points'];

          polyLinesHandler.clear();

          _createPistes(_pistes, _points);
          _createAerialways(_aerialways, _points);

          mapUpdateController.add('draw resort');
        },
        child: Text('Build'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
    );
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  Future<Map<String, dynamic>> loadResortsData() async {
    String jsonString = await rootBundle.loadString('assets/resorts.json');
    Map<String, dynamic> data = json.decode(jsonString);
    return data;
  }

  void _createPistes(Map pistes, Map points) {

    var startPoints = <String>[];
    var endPoints = <String>[];
    for (var pisteKey in pistes.keys) {
      var piste = pistes[pisteKey];
      var geoList = [for (var point in piste['points'].values) LatLng(double.parse(points[point]['lat']), double.parse(points[point]['lon']))];

      var firstPointKey = piste['points'].values.first;
      var lastPointKey = piste['points'].values.last;
      startPoints.add(firstPointKey);
      endPoints.add(lastPointKey);

      Color pisteColor = Colors.purple;
      int difficulty = 6;

      switch (piste['difficulty']) {
        case 'novice':
          difficulty = 1;
          pisteColor = Colors.green;
          break;
        case 'easy':
          difficulty = 2;
          pisteColor = Colors.blue;
          break;
        case 'intermediate':
          difficulty = 3;
          pisteColor = Colors.red;
          break;
        case 'advanced':
          difficulty = 4;
          pisteColor = Colors.black;
          break;
        case 'expert':
          difficulty = 5;
          pisteColor = Colors.yellow;
          break;
      }

      _createMarker(firstPointKey, points, difficulty);
      _createMarker(lastPointKey, points, difficulty);

      polyLinesHandler.addPiste(pisteKey, geoList, pisteColor);

      for (var i = 0; i < geoList.length - 1; i++) {
        var fromPoint = _createResortPoint(piste['points'].keys.toList()[i], geoList[i], isEdge: (i == 0) || (i == geoList.length - 1));
        var toPoint = _createResortPoint(piste['points'].keys.toList()[i + 1], geoList[i + 1], isEdge: (i + 1 == 0) || (i + 1 == geoList.length - 1));
        resortGraph.addConnection(fromPoint, toPoint, difficulty: difficulty);
      }
    }

    // _createMarkers(startPoints, points, difficulty);
    // _createMarkers(endPoints, points, difficulty);
  }

  void _createAerialways(Map aerialways, Map points) {
    var startPoints = <String>[];
    var endPoints = <String>[];

    for (var aerialwayKey in aerialways.keys) {
      var aerialway = aerialways[aerialwayKey];
      var firstPointKey = aerialway['points'].values.first;
      var lastPointKey = aerialway['points'].values.last;
      startPoints.add(firstPointKey);
      endPoints.add(lastPointKey);

      var geoList = [for (var point in aerialway['points'].values) LatLng(double.parse(points[point]['lat']), double.parse(points[point]['lon']))];

      Color aerialwayColor = Colors.black;

      polyLinesHandler.addAerialway(aerialwayKey, geoList, aerialwayColor);

      for (var i = 0; i < geoList.length - 1; i++) {
        var fromPoint = _createResortPoint(aerialway['points'].keys.toList()[i], geoList[i], isEdge: (i == 0) || (i == geoList.length - 1));
        var toPoint =
            _createResortPoint(aerialway['points'].keys.toList()[i + 1], geoList[i + 1], isEdge: (i + 1 == 0) || (i + 1 == geoList.length - 1));
        resortGraph.addConnection(fromPoint, toPoint);
      }
    }

    _createMarkers(startPoints, points, 0);
    _createMarkers(endPoints, points, 0);
  }

  void _createMarker(String pointKey, Map points, int markerType) {
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
    _markers[pointKey] = Marker(
        markerId: MarkerId(pointKey),
        position: LatLng(double.parse(points[pointKey]['lat']), double.parse(points[pointKey]['lon'])),
        icon: tmpMarker,
        anchor: const Offset(0.5, 0.5),
        onTap: () {
          _markerTap(_markers[pointKey]!);
        });
  }

  void _createMarkers(List<String> pointsKeyList, Map points, int markerType) {
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
      _markers[pointKey] = Marker(
          markerId: MarkerId(pointKey),
          position: LatLng(double.parse(points[pointKey]['lat']), double.parse(points[pointKey]['lon'])),
          icon: tmpMarker,
          anchor: const Offset(0.5, 0.5),
          onTap: () {
            _markerTap(_markers[pointKey]!);
          });
    }
  }

  void _markerTap(Marker marker) {
    if (int.parse(marker.markerId.value) == resortGraph.startPointId) {
      resortGraph.startPointId = null;
      _deselectMarker(marker.markerId.value);
      polyLinesHandler.erasePath();
      mapUpdateController.add('deselect start');
      return;
    }
    if (int.parse(marker.markerId.value) == resortGraph.endPointId) {
      resortGraph.endPointId = null;
      _deselectMarker(marker.markerId.value);
      polyLinesHandler.erasePath();

      mapUpdateController.add('deselect end');
      return;
    }
    if (resortGraph.startPointId == null) {
      resortGraph.startPointId = int.parse(marker.markerId.value);
      _selectMarker(marker.markerId.value);
      polyLinesHandler.drawPath(_resortPoints);

      mapUpdateController.add('select start');
      return;
    }
    if (resortGraph.endPointId == null) {
      resortGraph.endPointId = int.parse(marker.markerId.value);
      _selectMarker(marker.markerId.value);
      polyLinesHandler.drawPath(_resortPoints);
      mapUpdateController.add('select end');
      return;
    }
    if ((resortGraph.startPointId != null) && (resortGraph.endPointId != null)) {
      _deselectMarker(resortGraph.endPointId.toString());
      _selectMarker(marker.markerId.value);
      resortGraph.endPointId = int.parse(marker.markerId.value);
      polyLinesHandler.drawPath(_resortPoints);
      mapUpdateController.add('replace end');
      return;
    }
  }

  void _selectMarker(String markerId) {
    var newIcon = customMarkers[MarkerType.tmpMarkerChose];
    if (_markers[markerId]!.icon == customMarkers[MarkerType.aerialway]) {
      newIcon = customMarkers[MarkerType.aerialwayChose];
    }
    if (_markers[markerId]!.icon == customMarkers[MarkerType.green]) {
      newIcon = customMarkers[MarkerType.greenChose];
    }
    if (_markers[markerId]!.icon == customMarkers[MarkerType.blue]) {
      newIcon = customMarkers[MarkerType.blueChose];
    }
    if (_markers[markerId]!.icon == customMarkers[MarkerType.red]) {
      newIcon = customMarkers[MarkerType.redChose];
    }
    if (_markers[markerId]!.icon == customMarkers[MarkerType.black]) {
      newIcon = customMarkers[MarkerType.blackChose];
    }
    if (_markers[markerId]!.icon == customMarkers[MarkerType.yellow]) {
      newIcon = customMarkers[MarkerType.yellowChose];
    }
    _markers[markerId] = Marker(
        markerId: _markers[markerId]!.markerId,
        position: _markers[markerId]!.position,
        icon: newIcon!,
        anchor: const Offset(0.5, 0.5),
        onTap: () {
          _markerTap(_markers[markerId]!);
        });
  }

  void _deselectMarker(String markerId) {

    var newIcon = customMarkers[MarkerType.tmpMarker];
    if (_markers[markerId]!.icon == customMarkers[MarkerType.aerialwayChose]) {
      newIcon = customMarkers[MarkerType.aerialway];
    }
    if (_markers[markerId]!.icon == customMarkers[MarkerType.greenChose]) {
      newIcon = customMarkers[MarkerType.green];
    }
    if (_markers[markerId]!.icon == customMarkers[MarkerType.blueChose]) {
      newIcon = customMarkers[MarkerType.blue];
    }
    if (_markers[markerId]!.icon == customMarkers[MarkerType.redChose]) {
      newIcon = customMarkers[MarkerType.red];
    }
    if (_markers[markerId]!.icon == customMarkers[MarkerType.blackChose]) {
      newIcon = customMarkers[MarkerType.black];
    }
    if (_markers[markerId]!.icon == customMarkers[MarkerType.yellowChose]) {
      newIcon = customMarkers[MarkerType.yellow];
    }

    _markers[markerId] = Marker(
        markerId: _markers[markerId]!.markerId,
        position: _markers[markerId]!.position,
        icon: newIcon!,
        anchor: const Offset(0.5, 0.5),
        onTap: () {
          _markerTap(_markers[markerId]!);
        });
  }

  ResortPoint _createResortPoint(String pointId, LatLng point, {bool isEdge = false}) {
    var newPoint = ResortPoint(int.parse(pointId), point, isEdge: isEdge);

    _resortPoints[int.parse(pointId)] = newPoint;

    if (newPoint.isEdge) {
      for (int i = 0; i < _resortPoints.values.length; i++) {
        var resortPoint = _resortPoints.values.toList()[i];
        if (resortPoint.isEdge) {
          if (ResortPoint.calculateDistance(resortPoint, newPoint) <= 55.0) {
            resortGraph.addConnection(resortPoint, newPoint);
            resortGraph.addConnection(newPoint, resortPoint);
          }
        }
      }
    }

    return newPoint;
  }
}

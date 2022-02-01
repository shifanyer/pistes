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

import '../graph/resort_point.dart';

class DefaultMap extends StatefulWidget {
  const DefaultMap({Key? key}) : super(key: key);

  @override
  State<DefaultMap> createState() => _DefaultMapState();
}

class _DefaultMapState extends State<DefaultMap> {
  var _polyLines = <String, Polyline>{};
  var _markers = <String, Marker>{};
  var _resortPoints = <int, ResortPoint>{};
  Map<MarkerType, BitmapDescriptor> customMarkers = {};
  late ResortGraph resortGraph;
  String? startPoint;
  String? endPoint;
  double sliderDifficulty = 2.0;

  Completer<GoogleMapController> _googleMapController = Completer();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(60.5366352, 29.7506576),
    zoom: 14.4746,
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<Map<MarkerType, BitmapDescriptor>> _loadMarkers() async {
    customMarkers[MarkerType.tmpMarker] = BitmapDescriptor.fromBytes(await getBytesFromAsset('assets/markers/tmp2.png', 80));
    customMarkers[MarkerType.tmpMarkerChosen] = BitmapDescriptor.fromBytes(await getBytesFromAsset('assets/markers/tmp3.png', 80));
    return customMarkers;
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
                          child: GoogleMap(
                            mapType: MapType.hybrid,
                            initialCameraPosition: _kGooglePlex,
                            polylines: _polyLines.values.toSet(),
                            markers: _markers.values.toSet(),
                            mapToolbarEnabled: false,
                            onMapCreated: (GoogleMapController controller) {
                              _googleMapController.complete(controller);
                            },
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
                    child: Center(
                      child: Slider(
                        value: sliderDifficulty,
                        onChanged: (double value) {
                          setState(() {
                            sliderDifficulty = value;
                            _drawPath(startPoint, endPoint, sliderDifficulty.floor());
                          });
                        },
                        divisions: 6,
                        label: _difficultyByNum(sliderDifficulty.round()),
                        min: 0,
                        max: 6,
                      ),
                    ),
                  ),
                )
              ],
            );
          }),
      floatingActionButton: FloatingActionButton(onPressed: () async {
        var resorts = await loadResortsData();
        resortGraph = ResortGraph({});
        var redLake = resorts['resorts']['red lake'];
        var _pistes = redLake['pistes'];
        var _aerialways = redLake['aerialways'];
        var _points = redLake['points'];

        _polyLines.clear();

        _createPistes(_pistes, _points);
        _createAerialways(_aerialways, _points);

        setState(() {});
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

  void _pisteTap(Polyline line) {
    int lineWidth = 0;

    if ((_polyLines[line.polylineId.value + 'selected'] == null) || (_polyLines[line.polylineId.value + 'selected']!.width == 0)) {
      lineWidth = 12;
    }

    _polyLines[line.polylineId.value + 'selected'] = Polyline(
        polylineId: PolylineId(line.polylineId.value + 'selected'),
        points: line.points,
        width: lineWidth,
        color: Colors.orange.withOpacity(0.4),
        consumeTapEvents: true,
        endCap: Cap.roundCap,
        startCap: Cap.roundCap,
        onTap: () {
          _pisteTap(_polyLines[line.polylineId.value]!);
        });
    setState(() {});
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

      int difficulty = 6;
      Color pisteColor = Colors.purple;

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

      _polyLines[pisteKey] = (Polyline(
          polylineId: PolylineId(pisteKey),
          points: geoList,
          width: 3,
          color: pisteColor,
          consumeTapEvents: false,
          onTap: () {
            _pisteTap(_polyLines[pisteKey]!);
          }));

      for (var i = 0; i < geoList.length - 1; i++) {
        var fromPoint = _createResortPoint(piste['points'].keys.toList()[i], geoList[i], isEdge: (i == 0) || (i == geoList.length - 1));
        var toPoint = _createResortPoint(piste['points'].keys.toList()[i + 1], geoList[i + 1], isEdge: (i + 1 == 0) || (i + 1 == geoList.length - 1));
        resortGraph.addConnection(fromPoint, toPoint, difficulty: difficulty);
      }
    }

    _createMarkers(startPoints, points);
    _createMarkers(endPoints, points);
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

      _polyLines[aerialwayKey] = (Polyline(
          polylineId: PolylineId(aerialwayKey),
          points: geoList,
          width: 4,
          color: aerialwayColor,
          patterns: [PatternItem.dash(10), PatternItem.gap(10)],
          consumeTapEvents: false,
          onTap: () {}));

      for (var i = 0; i < geoList.length - 1; i++) {
        var fromPoint = _createResortPoint(aerialway['points'].keys.toList()[i], geoList[i], isEdge: (i == 0) || (i == geoList.length - 1));
        var toPoint =
            _createResortPoint(aerialway['points'].keys.toList()[i + 1], geoList[i + 1], isEdge: (i + 1 == 0) || (i + 1 == geoList.length - 1));
        resortGraph.addConnection(fromPoint, toPoint);
      }
    }

    _createMarkers(startPoints, points);
    _createMarkers(endPoints, points);
  }

  void _createMarkers(List<String> pointsKeyList, Map points) {
    var tmpMarker = customMarkers[MarkerType.tmpMarker]!;
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
    if (marker.markerId.value == startPoint) {
      startPoint = null;
      _deselectMarker(marker.markerId.value);
      _erasePath();
      setState(() {});
      return;
    }
    if (marker.markerId.value == endPoint) {
      endPoint = null;
      _deselectMarker(marker.markerId.value);
      _erasePath();
      setState(() {});
      return;
    }
    if (startPoint == null) {
      startPoint = marker.markerId.value;
      _selectMarker(marker.markerId.value);
      _drawPath(startPoint, endPoint, sliderDifficulty.floor());
      setState(() {});
      return;
    }
    if (endPoint == null) {
      endPoint = marker.markerId.value;
      _selectMarker(marker.markerId.value);
      _drawPath(startPoint, endPoint, sliderDifficulty.floor());
      setState(() {});
      return;
    }
    if ((startPoint != null) && (endPoint != null)) {
      _deselectMarker(endPoint!);
      _selectMarker(marker.markerId.value);
      endPoint = marker.markerId.value;
      _drawPath(startPoint, endPoint, sliderDifficulty.floor());
      setState(() {});
      return;
    }
  }

  void _selectMarker(String markerId) {
    _markers[markerId] = Marker(
        markerId: _markers[markerId]!.markerId,
        position: _markers[markerId]!.position,
        icon: customMarkers[MarkerType.tmpMarkerChosen]!,
        anchor: const Offset(0.5, 0.5),
        onTap: () {
          _markerTap(_markers[markerId]!);
        });
  }

  void _deselectMarker(String markerId) {
    _markers[markerId] = Marker(
        markerId: _markers[markerId]!.markerId,
        position: _markers[markerId]!.position,
        icon: customMarkers[MarkerType.tmpMarker]!,
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

  void _drawPath(String? startPoint, String? endPoint, int difficulty) {
    if ((startPoint != null) && (endPoint != null)) {
      var path = resortGraph.findRoute(int.parse(startPoint), int.parse(endPoint), difficulty: difficulty);
      _polyLines['selected path'] = Polyline(
        polylineId: PolylineId('selected path'),
        points: path.map((e) {
          return _resortPoints[e]!.position;
        }).toList(),
        width: 12,
        color: Colors.orange.withOpacity(0.4),
        consumeTapEvents: false,
      );
      setState(() {});
    }
  }

  void _erasePath() {
    if (_polyLines['selected path'] != null) {
      _polyLines.remove('selected path');
      setState(() {});
    }
  }

  String _difficultyByNum(int value ) {
    String res = 'extra hard';
    switch (value) {
      case 0:
        res = 'pedestrian';
        break;
      case 1:
        res = 'novice';
        break;
      case 2:
        res = 'easy';
        break;
      case 3:
        res = 'intermediate';
        break;
      case 4:
        res = 'advanced';
        break;
      case 5:
        res = 'expert';
        break;
      case 6:
        res = 'god';
        break;
    }
    return res;
  }

}

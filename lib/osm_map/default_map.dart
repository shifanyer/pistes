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
  Map<MarkerType, BitmapDescriptor> customMarkers = {};
  late ResortGraph resortGraph;
  String? startPoint;
  String? endPoint;

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
        backgroundColor: Colors.transparent,
      ),
      body: FutureBuilder(
          future: _loadMarkers(),
          builder: (context, snapshot) {
            return SizedBox(
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

        resortGraph.display();
        setState(() {});
      }),
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
    int lineWidth = 3;
    if (line.width == 3) {
      lineWidth = 7;
    }
    _polyLines[line.polylineId.value] = Polyline(
        polylineId: PolylineId(line.polylineId.value),
        points: line.points,
        width: lineWidth,
        color: line.color,
        consumeTapEvents: true,
        endCap: Cap.roundCap,
        startCap: Cap.roundCap,
        onTap: () {
          _pisteTap(_polyLines[line.polylineId.value]!);
        });
    setState(() {});
  }

  void _createPistes(Map pistes, Map points) {
    for (var pisteKey in pistes.keys) {
      var piste = pistes[pisteKey];
      var geoList = [for (var point in piste['points'].values) LatLng(double.parse(points[point]['lat']), double.parse(points[point]['lon']))];

      Color pisteColor = Colors.purple;

      switch (piste['difficulty']) {
        case 'novice':
          pisteColor = Colors.green;
          break;
        case 'easy':
          pisteColor = Colors.blue;
          break;
        case 'intermediate':
          pisteColor = Colors.red;
          break;
        case 'advanced':
          pisteColor = Colors.black;
          break;
        case 'expert':
          pisteColor = Colors.yellow;
          break;
      }

      _polyLines[pisteKey] = (Polyline(
          polylineId: PolylineId(pisteKey),
          points: geoList,
          width: 3,
          color: pisteColor,
          consumeTapEvents: true,
          onTap: () {
            _pisteTap(_polyLines[pisteKey]!);
          }));

      for (var i = 0; i < geoList.length - 1; i++) {
        resortGraph.addConnection(ResortPoint(int.parse((piste['points'].keys.toList())[i]), geoList[i]),
            ResortPoint(int.parse((piste['points'].keys.toList())[i + 1]), geoList[i + 1]));
      }
    }
  }

  void _createAerialways(Map aerialways, Map points) {
    var startPoints = [];
    var endPoints = [];

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
          consumeTapEvents: true,
          onTap: () {
            print('aerialwayKey: ${aerialwayKey}');
          }));

      for (var i = 0; i < geoList.length - 1; i++) {
        resortGraph.addConnection(ResortPoint(int.parse((aerialway['points'].keys.toList())[i]), geoList[i]),
            ResortPoint(int.parse((aerialway['points'].keys.toList())[i + 1]), geoList[i + 1]));
      }
    }

    _createMarkers(startPoints, points);
    _createMarkers(endPoints, points);
  }

  void _createMarkers(List pointsKeyList, Map points) {
    var tmpMarker = customMarkers[MarkerType.tmpMarker]!;
    var tmpMarkerChosen = customMarkers[MarkerType.tmpMarkerChosen]!;
    for (var pointKey in pointsKeyList) {
      _markers[pointKey] = Marker(
          markerId: MarkerId(pointKey),
          position: LatLng(double.parse(points[pointKey]['lat']), double.parse(points[pointKey]['lon'])),
          icon: tmpMarker,
          anchor: const Offset(0.5, 0.5),
          onTap: () {
            if (startPoint == null) {
              startPoint = pointKey;
            } else {
              endPoint = pointKey;
              print('startPoint: ${startPoint}, endPoint: ${endPoint}');
            }
            _markerTap(_markers[pointKey]!);

            if ((startPoint != null) && (endPoint != null)) {
              resortGraph.findRoute(int.parse(startPoint!), int.parse(endPoint!));
            }
            setState(() {});
          });
    }
  }

  void _markerTap(Marker marker) {
    var markerType = customMarkers[MarkerType.tmpMarker];
    // if (_markers[marker.markerId.value]!.icon == customMarkers[MarkerType.tmpMarker]) {
    if ((marker.markerId.value == startPoint) || (marker.markerId.value == endPoint)) {
      markerType = customMarkers[MarkerType.tmpMarkerChosen];
    }
    _markers[marker.markerId.value] = Marker(
        markerId: MarkerId(marker.markerId.value),
        position: LatLng(marker.position.latitude, marker.position.longitude),
        icon: markerType!,
        anchor: const Offset(0.5, 0.5),
        onTap: () {
          if (startPoint == null) {
            startPoint = marker.markerId.value;
          } else {
            endPoint = marker.markerId.value;
            print('startPoint: ${startPoint}, endPoint: ${endPoint}');
          }
          _markerTap(_markers[marker.markerId.value]!);
          if ((startPoint != null) && (endPoint != null)) {
            resortGraph.findRoute(int.parse(startPoint!), int.parse(endPoint!));
          }
          setState(() {});
        });
  }
}

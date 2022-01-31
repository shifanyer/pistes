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

class DefaultMap extends StatefulWidget {
  const DefaultMap({Key? key}) : super(key: key);

  @override
  State<DefaultMap> createState() => _DefaultMapState();
}

class _DefaultMapState extends State<DefaultMap> {
  var _polyLines = <String, Polyline>{};
  var _markers = <String, Marker>{};

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

  void _pisteTap(Polyline line) {
    int lineWidth = 3;
    if (line.width == 3) {
      lineWidth = 7;
    }
    print('${line.polylineId.value}, ${line.width}');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        width: SizeConfig.screenWidth,
        height: SizeConfig.screenHeight * 0.8,
        child: SafeArea(
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
        ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: () async {
        var resorts = await loadResortsData();
        var byteIcon = await getBytesFromAsset('assets/markers/tmp2.png', 80);
        var byteIconChose = await getBytesFromAsset('assets/markers/tmp3.png', 80);
        var tmpMarker = BitmapDescriptor.fromBytes(byteIcon);
        var tmpMarkerChosen = BitmapDescriptor.fromBytes(byteIconChose);

        var redLake = resorts['resorts']['red lake'];
        var _pistes = redLake['pistes'];
        var _aerialways = redLake['aerialways'];
        var _points = redLake['points'];

        _polyLines.clear();
        for (var pisteKey in _pistes.keys) {
          var piste = _pistes[pisteKey];
          var geoList = [for (var point in piste['points'].values) LatLng(double.parse(_points[point]['lat']), double.parse(_points[point]['lon']))];

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
              endCap: Cap.roundCap,
              startCap: Cap.roundCap,
              onTap: () {
                _pisteTap(_polyLines[pisteKey]!);
              }));
        }

        for (var aerialwayKey in _aerialways.keys) {
          var aerialway = _aerialways[aerialwayKey];
          var firstPointKey = aerialway['points'].values.first;
          _markers[firstPointKey] = Marker(
              markerId: MarkerId(firstPointKey),
              position: LatLng(double.parse(_points[firstPointKey]['lat']), double.parse(_points[firstPointKey]['lon'])),
              icon: tmpMarker,
              anchor: const Offset(0.5, 0.5),
            onTap: () {
              _markers[firstPointKey] = Marker(
                  markerId: MarkerId(firstPointKey),
                  position: LatLng(double.parse(_points[firstPointKey]['lat']), double.parse(_points[firstPointKey]['lon'])),
                  icon: tmpMarkerChosen,
                  anchor: const Offset(0.5, 0.5),
                  onTap: () {
                    print('chosen');
                  }
              );
              setState(() {

              });
            }
          );

          var geoList = [
            for (var point in aerialway['points'].values) LatLng(double.parse(_points[point]['lat']), double.parse(_points[point]['lon']))
          ];

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
        }

        setState(() {});
      }),
    );
  }
}

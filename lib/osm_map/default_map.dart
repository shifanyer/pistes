import 'dart:async';
import 'dart:convert';
import 'dart:math';

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
  var polyLines = <Polyline>{};

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

  static final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799, target: LatLng(37.43296265331129, -122.08832357078792), tilt: 59.440717697143555, zoom: 19.151926040649414);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
            polylines: polyLines,
            onMapCreated: (GoogleMapController controller) {
              _googleMapController.complete(controller);
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: () async {
        var resorts = await loadResortsData();
        var redLake = resorts['resorts']['red lake'];
        var pistes = redLake['pistes'];
        var aerialways = redLake['aerialways'];
        var points = redLake['points'];

        polyLines.clear();
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

          polyLines.add(Polyline(
              polylineId: PolylineId(pisteKey),
              points: geoList,
              width: 3,
              color: pisteColor,
              consumeTapEvents: true,
              endCap: Cap.roundCap,
              onTap: () {
                print('pisteKey: ${pisteKey}');
              }));
        }

        for (var aerialwayKey in aerialways.keys) {
          var aerialway = aerialways[aerialwayKey];
          var geoList = [
            for (var point in aerialway['points'].values) LatLng(double.parse(points[point]['lat']), double.parse(points[point]['lon']))
          ];

          Color aerialwayColor = Colors.black;

          polyLines.add(Polyline(
              polylineId: PolylineId(aerialwayKey),
              points: geoList,
              width: 2,
              color: aerialwayColor,
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

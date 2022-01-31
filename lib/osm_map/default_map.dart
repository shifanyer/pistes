import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:pistes/device_description/size_config.dart';

class DefaultMap extends StatefulWidget {
  const DefaultMap({Key? key}) : super(key: key);

  @override
  State<DefaultMap> createState() => _DefaultMapState();
}

class _DefaultMapState extends State<DefaultMap> {
  MapController mapController = MapController(
    initMapWithUserPosition: false,
    initPosition:
    GeoPoint(latitude: 60.53475333320823, longitude: 29.738908330678612),
    areaLimit: BoundingBox(
      east: 58.0,
      north: 28.0,
      south: 30.0,
      west: 62.0,
    ),
  );

  Future<Map<String, dynamic>> loadResortsData() async {
    String jsonString = await rootBundle.loadString('assets/resorts.json');
    Map<String, dynamic> data = json.decode(jsonString);
    return data;
  }

  @override
  void initState() {
    mapController.listenerRegionIsChanging.addListener(() async {
      var currentGeoPoint = await mapController.centerMap;
      print('currentGeoPoint.toString(): ${currentGeoPoint.toString()}');
    });
    mapController.listenerMapSingleTapping.addListener(() async {
      if (mapController.listenerMapSingleTapping.value != null) {
        print('here: ${mapController.listenerMapSingleTapping.value}');
        // var currentGeoPoint = await mapController.centerMap;

        await mapController.addMarker(
            mapController.listenerMapSingleTapping.value!,
            markerIcon: const MarkerIcon(
                icon: Icon(
                  Icons.location_on_sharp,
                  color: Colors.blue,
                  size: 90,
                )),
            angle: pi * 0);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    mapController.dispose();
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
          child: OSMFlutter(
            controller: mapController,
            trackMyPosition: false,
            initZoom: 12,
            minZoomLevel: 2,
            maxZoomLevel: 19,
            stepZoom: 1.0,
            userLocationMarker: UserLocationMaker(
              personMarker: const MarkerIcon(
                icon: Icon(
                  Icons.location_history_rounded,
                  color: Colors.red,
                  size: 48,
                ),
              ),
              directionArrowMarker: const MarkerIcon(
                icon: Icon(
                  Icons.double_arrow,
                  size: 48,
                ),
              ),
            ),
            roadConfiguration: RoadConfiguration(
              startIcon: const MarkerIcon(
                icon: Icon(
                  Icons.person,
                  size: 64,
                  color: Colors.brown,
                ),
              ),
              roadColor: Colors.yellowAccent,
            ),
            markerOption: MarkerOption(
                defaultMarker: const MarkerIcon(
                  icon: Icon(
                    Icons.person_pin_circle,
                    color: Colors.blue,
                    size: 56,
                  ),
                )),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: () async {
        var resorts = await loadResortsData();
        var redLake = resorts['resorts']['red lake'];
        var pistes = redLake['pistes'];
        var points = redLake['points'];
/*
        for (var piste in pistes.values) {
          // print('piste: ${piste}');
          // print(piste['points'].values);
          var geoList = [
            for (var point in piste['points'].values)
              GeoPoint(
                  latitude: double.parse(points[point]['lat']),
                  longitude: double.parse(points[point]['lon']))
          ];
          // print('geoList: ${geoList}');
          await mapController.drawRoadManually(geoList, Colors.red, 5.0);
        }

 */
        mapController.osmBaseController.drawRoadManually([
          GeoPoint(latitude: 60.534748724055504, longitude: 29.73907391022948),
          GeoPoint(latitude: 60.536748724055504, longitude: 29.74007391022948),
          GeoPoint(latitude: 60.538748724055504, longitude: 29.75007391022948),
          GeoPoint(latitude: 60.53956622736207, longitude: 29.74616447156012)
        ], Colors.red, 5.0).then((value) => {
          print('done')
        });
        // mapController.dr
/*
        mapController.drawRoad(
            GeoPoint(
                latitude: 60.534748724055504, longitude: 29.73907391022948),
            GeoPoint(latitude: 60.53956622736207, longitude: 29.74616447156012),
            roadType: RoadType.foot);
*/

      }
        // mapController.
      ),
    );
  }
}

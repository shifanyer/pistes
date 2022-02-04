import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../graph/resort_point.dart';

class MainMap extends StatefulWidget {
  Map<String, Polyline> polyLines;
  Map<String, Marker> markers;
  final StreamController<String> mapUpdController;

  MainMap({Key? key, required this.markers, required this.polyLines, required this.mapUpdController}) : super(key: key);

  @override
  State<MainMap> createState() => _MainMapState();
}

class _MainMapState extends State<MainMap> {
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(60.5366352, 29.7506576),
    zoom: 15
  );

  Completer<GoogleMapController> _googleMapController = Completer();
  late GoogleMapController mapController;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
        stream: widget.mapUpdController.stream,
        builder: (context, snapshot) {
          if (snapshot.data?.contains('camera') ?? false) {
            var lat = double.parse(snapshot.data!.split('camera ').last.split(' ').first);
            var lon = double.parse(snapshot.data!.split('camera ').last.split(' ').last);
            mapController.animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lon), 14));
          }
          return GoogleMap(
            mapType: MapType.hybrid,
            initialCameraPosition: _kGooglePlex,
            polylines: widget.polyLines.values.toSet(),
            markers: widget.markers.values.toSet(),
            mapToolbarEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              _googleMapController.complete(controller);
              mapController = controller;
            },
          );
        });
  }
}

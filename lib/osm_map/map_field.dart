import 'dart:async';

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
    zoom: 14.4746,
  );

  Completer<GoogleMapController> _googleMapController = Completer();

  // widget.mapUpdController.stream.listen((item) => setState(() {}));

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
        stream: widget.mapUpdController.stream,
        builder: (context, snapshot) {
          return GoogleMap(
            mapType: MapType.hybrid,
            initialCameraPosition: _kGooglePlex,
            polylines: widget.polyLines.values.toSet(),
            markers: widget.markers.values.toSet(),
            mapToolbarEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              _googleMapController.complete(controller);
            },
          );
        });
  }
}

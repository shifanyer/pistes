import 'package:google_maps_flutter/google_maps_flutter.dart';

class ResortPoint {
  final int pointId;
  final LatLng position;

  ResortPoint(this.pointId, this.position);

  @override
  String toString() {
    return pointId.toString() + ': ' + position.toString();
  }

}
import 'dart:math';

import 'package:google_maps_flutter/google_maps_flutter.dart';

class ResortPoint {
  final int pointId;
  final LatLng position;
  final bool isEdge;

  ResortPoint(this.pointId, this.position, {this.isEdge = false});

  static double calculateDistance(ResortPoint point1, ResortPoint point2) {
    var lat1 = point1.position.latitude;
    var lon1 = point1.position.longitude;
    var lat2 = point2.position.latitude;
    var lon2 = point2.position.longitude;
    var p = 0.017453292519943295;
    var a = 0.5 - cos((lat2 - lat1) * p) / 2 + cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742000 * asin(sqrt(a));
  }

  @override
  String toString() {
    return pointId.toString() + ': ' + position.toString();
  }
}

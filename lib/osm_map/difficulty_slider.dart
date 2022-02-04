import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../graph/resort_graph.dart';
import '../graph/resort_point.dart';

class DifficultySlider extends StatefulWidget {
  double sliderDifficulty = 2.0;
  var polyLines = <String, Polyline>{};
  final StreamController<String> mapUpdController;

  DifficultySlider({Key? key, required this.polyLines, required this.mapUpdController}) : super(key: key);

  @override
  State<DifficultySlider> createState() => _DifficultySliderState();
}

class _DifficultySliderState extends State<DifficultySlider> {
  var resortGraph = ResortGraph();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Slider(
        value: widget.sliderDifficulty,
        onChanged: (double value) {
          setState(() {
            widget.sliderDifficulty = value;
            resortGraph.lastDifficulty = widget.sliderDifficulty.floor();
            _drawPath(widget.sliderDifficulty.floor());
          });
        },
        divisions: 6,
        label: _difficultyByNum(widget.sliderDifficulty.round()),
        min: 0,
        max: 6,
      ),
    );
  }

  String _difficultyByNum(int value) {
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

  void _drawPath(int difficulty) {
    var newGraph = ResortGraph();
    var path = newGraph.findRoute();
    widget.polyLines['selected path'] = Polyline(
      polylineId: PolylineId('selected path'),
      points: path,
      width: 12,
      color: Colors.orange.withOpacity(0.4),
      consumeTapEvents: false,
    );
    widget.mapUpdController.add('draw path');
  }
}

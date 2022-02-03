import 'dart:convert';

import 'package:flutter/services.dart';

class ResortData {
  static Future<Map<String, dynamic>> loadResortsData({dataPath = ''}) async {
    var assetPath = 'assets/resorts' + (dataPath.length > 0 ? '_' : '') + dataPath + '.json';
    String jsonString = await rootBundle.loadString(assetPath);
    Map<String, dynamic> data = json.decode(jsonString);
    return data;
  }
}

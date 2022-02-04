import 'dart:convert';

import 'package:flutter/services.dart';

class ResortsStorage {
  static Future<Map<String, dynamic>> downloadedResorts() async {
    var assetPath = 'assets/resorts.json';
    String jsonString = await rootBundle.loadString(assetPath);
    Map<String, dynamic> data = json.decode(jsonString);
    return data;
  }

  static List<String> allResorts() {
    return ['redLake', 'Sheregesh', 'sunny valley'];
  }

  static Future<List<DataResort>> resortsData() async {
    var res = <DataResort>[];
    var deviceResorts = (await downloadedResorts())['resorts'].values.map((v) => v['name']);
    var anyResorts = allResorts();
    for (var resort in anyResorts) {
      if (deviceResorts.contains(resort)) {
        res.add(DataResort(resort, true));
      }
      else {
        res.add(DataResort(resort));
      }
    }
    return res;
  }
}

class DataResort {
  bool isLoaded;
  bool isLastVersion;
  final String fileName;

  DataResort(this.fileName, [this.isLoaded = false, this.isLastVersion = false]);
}

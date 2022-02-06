import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;

class ResortsStorage {
  static Future<Map<String, dynamic>> downloadedResorts() async {
    var assetPath = 'assets/resorts.json';

    String jsonString = await rootBundle.loadString(assetPath);
    Map<String, dynamic> data = json.decode(jsonString);
    return data;
  }

  static List<String> allResorts() {
    var res = ['redLake', 'Sheregesh', 'sunny valley'];
    for (var i = 1; i < 100; i++) {
      res.add(i.toString());
    }
    return res;
  }

  static Future<List<DataResort>> resortsData() async {
    var res = <DataResort>[];
    var deviceResorts = (await downloadedResorts())['resorts'].values;

    for (var resort in deviceResorts) {
      res.add(DataResort(resort['name'], LatLng(double.parse(resort['point']['lat']), double.parse(resort['point']['lon'])), resort['isLoaded'],
          resort['needUpdate']));
    }
    return res;
  }

  static Future<void> downloadResort(String fileName) async {
    await Firebase.initializeApp();
    var resortStorageRef = firebase_storage.FirebaseStorage.instance.ref('resorts/$fileName.json');

    Directory appDocDir = await getApplicationDocumentsDirectory();

    File downloadToFile = File('${appDocDir.path}/resorts/$fileName.json');
    try {
      downloadToFile.create(recursive: true);
    } catch (e) {
      print('IOFileError: ${e}');
    }
    try {
      await resortStorageRef.writeToFile(downloadToFile);
    } on firebase_core.FirebaseException catch (e) {
      print('FirebaseException: ${e}');
    }
  }

  // static updateResortsFile(Map<String, dynamic> newData) async {
  //   var stringData = json.encode(newData);
  //   var assetPath = 'assets/resorts.json';
  //
  //   String jsonString = await rootBundle.;
  // }
}

class DataResort {
  bool isLoaded;
  bool isLastVersion;
  bool isLoading;
  final String fileName;
  final LatLng point;

  DataResort(this.fileName, this.point, [this.isLoaded = false, this.isLastVersion = true, this.isLoading = false]);

  @override
  String toString() {
    return '{fileName: ${this.fileName}, isLoaded: ${this.isLoaded}, isLoading: ${this.isLoading}, isLastVersion: ${this.isLastVersion}';
  }
}

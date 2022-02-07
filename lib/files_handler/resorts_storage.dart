import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;

class ResortsStorage {
  static Future<Map<String, dynamic>> getResortsInfo() async {
    var assetPath = 'assets/resorts.json';

    Directory appDocDir = await getApplicationDocumentsDirectory();

    Map<String, dynamic> res = {};
    File resortsInfoFile = File('${appDocDir.path}/resorts/resorts.json');
    if (!(resortsInfoFile.existsSync())) {
      resortsInfoFile.createSync(recursive: true);
      String jsonString = await rootBundle.loadString(assetPath);
      resortsInfoFile.writeAsString(jsonString);
      res = json.decode(jsonString);
    } else {
      var dataString = '';
      await resortsInfoFile.readAsString().then((String contents) {
        dataString = contents;
      });
      res = json.decode(dataString);
    }
    return res;
  }

  static List<String> allResorts() {
    var res = ['redLake', 'Sheregesh', 'sunny valley'];
    for (var i = 1; i < 100; i++) {
      res.add(i.toString());
    }
    return res;
  }

  static Future<List<DataResort>> resortsDataList() async {
    var res = <DataResort>[];
    var deviceResorts = (await getResortsInfo())['resorts'].values;

    for (var resort in deviceResorts) {
      res.add(DataResort(resort['name'], LatLng(double.parse(resort['point']['lat']), double.parse(resort['point']['lon'])), resort['isLoaded'],
          resort['isLastVersion']));
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
      print('IOFileError: $e');
    }
    try {
      await resortStorageRef.writeToFile(downloadToFile);
    } on firebase_core.FirebaseException catch (e) {
      print('FirebaseException: $e');
    }
  }

  static void updateResortsFile(List<DataResort> newData) async {
    var stringData = resortsDataListToString(newData);
    Directory appDocDir = await getApplicationDocumentsDirectory();
    File resortsInfoFile = File('${appDocDir.path}/resorts/resorts.json');
    if (!(resortsInfoFile.existsSync())) {
      resortsInfoFile.createSync(recursive: true);
    }
    resortsInfoFile.writeAsString(stringData);
  }

  static String resortsDataListToString(List<DataResort> resortsInfoList) {
    var res = '''{
    "resorts": {
    
    ''';
    for (var i = 0; i < resortsInfoList.length; i++) {
      res += resortsInfoList[i].toString();
      if (i != resortsInfoList.length - 1) {
        res += ',';
      }
      res += '\n';
    }
    res += '}}';
    return res;
  }
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
    return '''
    "$fileName" :
    {
      "name": "$fileName",
      "point" : {
        "lat": "${point.latitude}",
        "lon": "${point.longitude}"
      } ,
      "isLoaded": $isLoaded, 
      "isLoading": $isLoading, 
      "isLastVersion": $isLastVersion
    }''';
  }
}

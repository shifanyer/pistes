import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class ResortData {
  static Future<Map<String, dynamic>> loadResortData(resortName) async {

    Directory appDocDir = await getApplicationDocumentsDirectory();
    var resortFilePath = '${appDocDir.path}/resorts/resorts_$resortName.json';
    File resortFile = File(resortFilePath);
    var jsonString = '';
    await resortFile.readAsString().then((String contents) {
      jsonString = contents;
    });
    Map<String, dynamic> data = json.decode(jsonString);
    return data;
  }



}

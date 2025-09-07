import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:lcinstaller/database_helper.dart';
import 'package:lcinstaller/models/source.dart';
import 'package:http/http.dart' as http;

Future<void> refetchApps(BuildContext context, Source? source) async {
  List<Source> sources = [];
  if (source == null) {
    final sourceList = await DatabaseHelper().getSources();
    sources = sourceList.map((e) => Source.fromMap(e)).toList();
  } else {
    sources = [source];
  }
  for (var src in sources) {
    final sourceData = await fetchSourceData(src.sourceURL);
    if (sourceData != null && sourceData['apps'] is List) {
      DatabaseHelper().deleteAppsBySource(src.id!);
      for (var appData in sourceData['apps']) {
        final appMap = {
          'source_id': src.id,
          'name': appData['name'],
          'bundleIdentifier': appData['bundleIdentifier'],
          'version': appData['version'],
          'versionDate': appData['versionDate'],
          'downloadURL': appData['downloadURL'],
          'localizedDescription': appData['localizedDescription'],
          'iconURL': appData['iconURL'],
          'size': appData['size'],
        };
        await DatabaseHelper().insertApp(appMap);
      }
    }
  }
}

Future<Map<String, dynamic>?> fetchSourceData(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(json.decode(response.body));
    }
  return null;
}
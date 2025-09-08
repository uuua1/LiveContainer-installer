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
      await DatabaseHelper().deleteAppsBySource(src.id!);
      for (var appData in sourceData['apps']) {
        // Create app map with proper structure
        final appMap = {
          'source_id': src.id,
          'name': appData['name'],
          'bundleIdentifier': appData['bundleIdentifier'],
          'developerName': appData['developerName'] ?? '',
          'subTitle': appData['subtitle'] ?? '',
          'localizedDescription': appData['localizedDescription'] ?? '',
          'iconURL': appData['iconURL'] ?? '',
          'tintColor': appData['tintColor'] ?? '',
        };

        // Add version info as separate entry
        List<Map<String, dynamic>> versions = [];
        if (appData['version'] != null) {
          versions.add({
            'version': appData['version'],
            'date': appData['versionDate'] ?? '',
            'size': appData['size'] ?? 0,
            'downloadURL': appData['downloadURL'] ?? '',
            'localizedDescription':
                appData['versionDescription'] ??
                appData['localizedDescription'] ??
                '',
          });
        }

        // Check if there's a versions array in the data
        if (appData['versions'] is List &&
            (appData['versions'] as List).isNotEmpty) {
          for (var versionData in appData['versions']) {
            versions.add({
              'version': versionData['version'] ?? '',
              'date': versionData['date'] ?? '',
              'size': versionData['size'] ?? 0,
              'downloadURL': versionData['downloadURL'] ?? '',
              'localizedDescription': versionData['localizedDescription'] ?? '',
            });
          }
        }

        if (versions.isNotEmpty) {
          appMap['versions'] = versions;
        }

        // Handle screenshots if available
        List<Map<String, dynamic>> screenshotsList = [];

        if (appData['screenshots'] is List) {
          screenshotsList = (appData['screenshots'] as List).map((s) {
            if (s is String) {
              return {"imageURL": s, "height": 0, "width": 0};
            } else if (s is Map<String, dynamic>) {
              return {
                "imageURL": s['imageURL'] ?? '',
                "height": s['height'] ?? 0,
                "width": s['width'] ?? 0,
              };
            } else {
              return {"imageURL": '', "height": 0, "width": 0};
            }
          }).toList();
        }
        appMap['screenshots'] = screenshotsList;
        try {
          await DatabaseHelper().insertApp(appMap);
        } catch (e) {
          throw Exception('Error inserting app: $e');
        }
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

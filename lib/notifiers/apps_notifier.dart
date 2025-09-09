import 'package:flutter/foundation.dart';
import 'package:lcinstaller/models/app.dart';
import 'package:lcinstaller/database_helper.dart';
import 'package:lcinstaller/models/source.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AppsNotifier extends ChangeNotifier {
  List<AppWithSourceIcon> _apps = [];
  bool _isLoading = false;

  List<AppWithSourceIcon> get apps => _apps;
  bool get isLoading => _isLoading;

  Future<void> fetchApps() async {
    _isLoading = true;
    notifyListeners();
    try {
      final sources = await DatabaseHelper().getSources();
      final sourceObjects = sources.map((e) => Source.fromMap(e)).toList();

      List<AppWithSourceIcon> allApps = [];

      for (final source in sourceObjects) {
        final sourceApps = await _fetchAppsFromSource(source);
        allApps.addAll(sourceApps);
      }

      _apps = allApps;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching apps: $e');
      }
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<List<AppWithSourceIcon>> _fetchAppsFromSource(Source source) async {
    try {
      final response = await http.get(Uri.parse(source.sourceURL));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        if (data['apps'] is List) {
          final apps = (data['apps'] as List).map((appData) {
            return _parseAppFromData(appData, source);
          }).toList();
          return apps;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching apps from ${source.sourceURL}: $e');
      }
    }
    return [];
  }

  AppWithSourceIcon _parseAppFromData(
    Map<String, dynamic> appData,
    Source source,
  ) {
    List<Versions> versions = [];

    // Handle version data
    if (appData['version'] != null) {
      versions.add(
        Versions(
          version: appData['version'],
          date: appData['versionDate'] ?? '',
          size: appData['size'] ?? 0,
          downloadURL: appData['downloadURL'] ?? '',
          localizedDescription:
              appData['versionDescription'] ??
              appData['localizedDescription'] ??
              '',
        ),
      );
    }

    if (appData['versions'] is List) {
      for (var v in appData['versions']) {
        if (v is Map<String, dynamic>) {
          versions.add(
            Versions(
              version: v['version'] ?? '',
              date: v['date'] ?? '',
              size: v['size'] ?? 0,
              downloadURL: v['downloadURL'] ?? '',
              localizedDescription: v['localizedDescription'] ?? '',
            ),
          );
        }
      }
    }

    List<Screenshots> screenshots = [];
    if (appData['screenshots'] is List) {
      screenshots = (appData['screenshots'] as List)
          .map((s) => Screenshots.fromMap(s))
          .toList();
    }

    return AppWithSourceIcon(
      sourceId: source.id!,
      name: appData['name'] ?? '',
      bundleIdentifier: appData['bundleIdentifier'] ?? '',
      developerName: appData['developerName'] ?? '',
      subTitle: appData['subtitle'] ?? '',
      versions: versions,
      localizedDescription: appData['localizedDescription'] ?? '',
      iconURL: appData['iconURL'] ?? '',
      tintColor: appData['tintColor'] ?? '',
      screenshots: screenshots,
      sourceIconURL: source.iconURL,
    );
  }

  Future<void> refreshApps() async {
    await fetchApps();
  }
}

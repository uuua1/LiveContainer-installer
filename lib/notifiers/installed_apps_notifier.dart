import 'package:flutter/foundation.dart';
import 'package:lcinstaller/database_helper.dart';
import 'package:lcinstaller/models/installed_app.dart';

class InstalledAppsNotifier extends ChangeNotifier {
  List<InstalledApp> _apps = [];
  Map<String, InstalledApp> _appMap = {};
  bool _isLoading = false;

  List<InstalledApp> get apps => _apps;
  Map<String, InstalledApp> get appMap => _appMap;
  bool get isLoading => _isLoading;

  Future<void> fetchInstalledApps() async {
    _isLoading = true;
    notifyListeners();
    try {
      final apps = await DatabaseHelper().getInstalledApps();
      _apps = apps.map((e) => InstalledApp.fromMap(e)).toList();
      _appMap = {
        for (var app in _apps) "${app.bundleIdentifier}_${app.sourceId}": app,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching installed apps: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshInstalledApps() async {
    await fetchInstalledApps();
  }
}

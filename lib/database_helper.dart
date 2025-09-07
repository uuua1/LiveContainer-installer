import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'liveapps.db');
    return await openDatabase(path, version: 2, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    // Create the tables
    await db.execute('''
    CREATE TABLE sources (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      identifier TEXT,
      subtitle TEXT,
      sourceURL TEXT,
      iconURL TEXT,
      website TEXT,
      description TEXT,
      tintColor TEXT
    )
  ''');

    await db.execute('''
    CREATE TABLE apps (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      source_id INTEGER,
      name TEXT,
      bundleIdentifier TEXT,
      developerName TEXT,
      subTitle TEXT,
      localizedDescription TEXT,
      iconURL TEXT,
      tintColor TEXT,
      screenshots TEXT,
      FOREIGN KEY(source_id) REFERENCES sources(id)
    )
  ''');

    await db.execute('''
    CREATE TABLE versions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      app_id INTEGER,
      version TEXT,
      date TEXT,
      size INTEGER,
      downloadURL TEXT,
      localizedDescription TEXT,
      FOREIGN KEY(app_id) REFERENCES apps(id)
    )
  ''');

    // Insert default source
    await db.insert('sources', {
      "id": 1,
      "name": "LcInstaller Repo",
      "identifier": "site.ashutoshportfolio.lcinstaller",
      "subtitle":
          "LiveContainer Installer Repo to install or update LcInstaller",
      "iconURL":
          "https://raw.githubusercontent.com/asrma7/LiveContainer-installer/main/screenshots/100.png",
      "website": "https://github.com/asrma7/LiveContainer-Installer",
      "sourceURL":
          "https://raw.githubusercontent.com/asrma7/LiveContainer-Installer/main/source.json",
      "description": "Official Repo of LcInstaller",
      "tintColor": "#3333FF",
    });
  }

  Future<int> insertSource(Map<String, dynamic> source) async {
    final db = await database;
    return await db.insert('sources', source);
  }

  Future<int> insertApp(Map<String, dynamic> app) async {
    final db = await database;
    // Convert screenshots list to JSON string if present
    if (app.containsKey('screenshots') && app['screenshots'] is List) {
      app['screenshots'] = jsonEncode(app['screenshots']);
    }
    // Insert app
    int appId = await db.insert('apps', app);
    // Insert versions if present
    if (app.containsKey('versions') && app['versions'] is List) {
      List versions = app['versions'];
      for (var v in versions) {
        Map<String, dynamic> versionMap = v is Map<String, dynamic> ? v : {};
        versionMap['app_id'] = appId;
        await db.insert('versions', versionMap);
      }
    }
    return appId;
  }

  Future<List<Map<String, dynamic>>> getSources() async {
    final db = await database;
    return await db.query('sources');
  }

  Future<List<Map<String, dynamic>>> getApps() async {
    final db = await database;
    // Get apps with source icon
    final result = await db.rawQuery('''
    SELECT a.*, s.iconURL AS sourceIconURL
    FROM apps a
    INNER JOIN sources s ON a.source_id = s.id
  ''');
    // For each app, get versions and decode screenshots
    for (var app in result) {
      final versions = await db.query(
        'versions',
        where: 'app_id = ?',
        whereArgs: [app['id']],
      );
      app['versions'] = versions;
      // Decode screenshots JSON string to List<String>
      if (app['screenshots'] != null && app['screenshots'] is String) {
        try {
          var decoded = jsonDecode(app['screenshots'] as String);
          if (decoded is List) {
            app['screenshots'] = decoded.map((e) => e.toString()).toList();
          } else {
            app['screenshots'] = [];
          }
        } catch (_) {
          app['screenshots'] = [];
        }
      }
    }
    return result;
  }

  Future<int> deleteAllApps() async {
    final db = await database;
    await db.delete('versions');
    return await db.delete('apps');
  }

  Future<int> deleteAppsBySource(int sourceId) async {
    final db = await database;
    // Get app ids for this source
    final apps = await db.query(
      'apps',
      where: 'source_id = ?',
      whereArgs: [sourceId],
    );
    for (var app in apps) {
      await db.delete('versions', where: 'app_id = ?', whereArgs: [app['id']]);
    }
    return await db.delete(
      'apps',
      where: 'source_id = ?',
      whereArgs: [sourceId],
    );
  }

  Future<int> deleteSourceAndApps(int sourceId) async {
    final db = await database;
    // Get app ids for this source
    final apps = await db.query(
      'apps',
      where: 'source_id = ?',
      whereArgs: [sourceId],
    );
    for (var app in apps) {
      await db.delete('versions', where: 'app_id = ?', whereArgs: [app['id']]);
    }
    await db.delete('apps', where: 'source_id = ?', whereArgs: [sourceId]);
    return await db.delete('sources', where: 'id = ?', whereArgs: [sourceId]);
  }
}

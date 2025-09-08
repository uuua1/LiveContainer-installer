import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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

    await db.execute('''
    CREATE TABLE screenshots (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      app_id INTEGER,
      imageURL TEXT,
      height TEXT,
      width TEXT,
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

    List screenshots = [];
    if (app.containsKey('screenshots') && app['screenshots'] is List) {
      screenshots = app['screenshots'];
      app.remove('screenshots');
    }
    List versions = [];
    if (app.containsKey('versions') && app['versions'] is List) {
      versions = app['versions'];
      app.remove('versions');
    }
    int appId = 0;
    try {
      appId = await db.insert('apps', app);
    } catch (e) {
      throw Exception('Error inserting app: $e');
    }
    if (versions.isNotEmpty) {
      for (var v in versions) {
        Map<String, dynamic> versionMap = v is Map<String, dynamic> ? v : {};
        versionMap['app_id'] = appId;
        await db.insert('versions', versionMap);
      }
    }
    if (screenshots.isNotEmpty) {
      for (var s in screenshots) {
        Map<String, dynamic> screenshotMap = s is Map<String, dynamic> ? s : {};
        screenshotMap['app_id'] = appId;
        await db.insert('screenshots', screenshotMap);
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
    final apps = result.map((app) => Map<String, dynamic>.from(app)).toList();
    for (var app in apps) {
      final versions = await db.query(
        'versions',
        where: 'app_id = ?',
        whereArgs: [app['id']],
      );
      app['versions'] = versions;
      // For each app, get screenshots and screenshots
      final screenshots = await db.query(
        'screenshots',
        where: 'app_id = ?',
        whereArgs: [app['id']],
      );
      app['screenshots'] = screenshots;
    }
    return apps;
  }

  Future<int> deleteAllApps() async {
    final db = await database;
    await db.delete('versions');
    await db.delete('screenshots');
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
      await db.delete(
        'screenshots',
        where: 'app_id = ?',
        whereArgs: [app['id']],
      );
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
      await db.delete(
        'screenshots',
        where: 'app_id = ?',
        whereArgs: [app['id']],
      );
    }
    await db.delete('apps', where: 'source_id = ?', whereArgs: [sourceId]);
    return await db.delete('sources', where: 'id = ?', whereArgs: [sourceId]);
  }
}

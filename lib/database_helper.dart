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
    return await openDatabase(
      path,
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
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
    CREATE TABLE installed_apps (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      bundleIdentifier TEXT,
      version TEXT,
      versionDate TEXT,
      iconURL TEXT,
      sourceId INTEGER,
      FOREIGN KEY (sourceId) REFERENCES sources (id)
    )
  ''');

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
          "https://raw.githubusercontent.com/asrma7/LiveContainer-Installer/main/sidestore.json",
      "description": "Official Repo of LcInstaller",
      "tintColor": "#3333FF",
    });
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      await db.execute('DROP TABLE IF EXISTS screenshots');
      await db.execute('DROP TABLE IF EXISTS versions');
      await db.execute('DROP TABLE IF EXISTS apps');
    }
    if (oldVersion < 4) {
      await db.execute('''
      CREATE TABLE installed_apps (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        bundleIdentifier TEXT,
        version TEXT,
        versionDate TEXT,
        iconURL TEXT,
        sourceId INTEGER,
        FOREIGN KEY (sourceId) REFERENCES sources (id)
      )
    ''');
    }
  }

  Future<int> insertSource(Map<String, dynamic> source) async {
    final db = await database;
    return await db.insert('sources', source);
  }

  Future<List<Map<String, dynamic>>> getSources() async {
    final db = await database;
    return await db.query('sources');
  }

  Future<int> deleteSource(int sourceId) async {
    final db = await database;
    return await db.delete('sources', where: 'id = ?', whereArgs: [sourceId]);
  }

  Future<int> insertInstalledApp(Map<String, dynamic> app) async {
    final db = await database;
    final existing = await db.query(
      'installed_apps',
      where: 'bundleIdentifier = ? AND sourceId = ?',
      whereArgs: [app['bundleIdentifier'], app['sourceId']],
    );
    if (existing.isNotEmpty) {
      return await db.update(
        'installed_apps',
        {...app, 'id': existing.first['id']},
        where: 'id = ?',
        whereArgs: [existing.first['id']],
      );
    } else {
      return await db.insert('installed_apps', app);
    }
  }

  Future<List<Map<String, dynamic>>> getInstalledApps() async {
    final db = await database;
    return await db.query('installed_apps');
  }

  Future<int> deleteInstalledApp(int appId) async {
    final db = await database;
    return await db.delete(
      'installed_apps',
      where: 'id = ?',
      whereArgs: [appId],
    );
  }
}

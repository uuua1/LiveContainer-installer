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
    return await openDatabase(path, version: 1, onCreate: _onCreate);
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
      website TEXT
    )
  ''');

    await db.execute('''
    CREATE TABLE apps (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      source_id INTEGER,
      name TEXT,
      bundleIdentifier TEXT,
      version TEXT,
      versionDate TEXT,
      downloadURL TEXT,
      localizedDescription TEXT,
      iconURL TEXT,
      size INTEGER,
      FOREIGN KEY(source_id) REFERENCES sources(id)
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
    });
  }

  Future<int> insertSource(Map<String, dynamic> source) async {
    final db = await database;
    return await db.insert('sources', source);
  }
  
  Future<int> insertApp(Map<String, dynamic> app) async {
    final db = await database;
    return await db.insert('apps', app);
  }

  Future<List<Map<String, dynamic>>> getSources() async {
    final db = await database;
    return await db.query('sources');
  }

  Future<List<Map<String, dynamic>>> getApps() async {
    final db = await database;

    // Using INNER JOIN to get iconURL from source table
    final result = await db.rawQuery('''
    SELECT a.*, s.iconURL AS sourceIconURL
    FROM apps a
    INNER JOIN sources s ON a.source_id = s.id
  ''');

    return result;
  }

  Future<int> deleteAllApps() async {
    final db = await database;
    return await db.delete('apps');
  }

  Future<int> deleteAppsBySource(int sourceId) async {
    final db = await database;
    return await db.delete('apps', where: 'source_id = ?', whereArgs: [sourceId]);
  }

  Future<int> deleteSourceAndApps(int sourceId) async {
    final db = await database;
    await db.delete('apps', where: 'source_id = ?', whereArgs: [sourceId]);
    return await db.delete('sources', where: 'id = ?', whereArgs: [sourceId]);
  }
}

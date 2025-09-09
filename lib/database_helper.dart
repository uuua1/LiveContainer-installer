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
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    // Create the sources table only
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
          "https://raw.githubusercontent.com/asrma7/LiveContainer-Installer/main/sidestore.json",
      "description": "Official Repo of LcInstaller",
      "tintColor": "#3333FF",
    });
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      // Drop app-related tables as we're moving to memory-only storage
      await db.execute('DROP TABLE IF EXISTS screenshots');
      await db.execute('DROP TABLE IF EXISTS versions');
      await db.execute('DROP TABLE IF EXISTS apps');
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

  Future<int> deleteSourceAndApps(int sourceId) async {
    final db = await database;
    return await db.delete('sources', where: 'id = ?', whereArgs: [sourceId]);
  }
}

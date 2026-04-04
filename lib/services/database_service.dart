import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/car_scan.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static const String _dbName = 'carlens.db';
  static const int _dbVersion = 4;
  static const String _tableName = 'scans';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<void> init() async {
    _database = await _initDatabase();
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        brand TEXT NOT NULL,
        model TEXT NOT NULL,
        year_estimate TEXT NOT NULL,
        body_type TEXT NOT NULL,
        color TEXT NOT NULL,
        confidence REAL NOT NULL,
        details TEXT NOT NULL,
        vin TEXT,
        originality_score REAL,
        originality_report TEXT,
        image_path TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        level INTEGER NOT NULL,
        extra_data TEXT,
        source_url TEXT,
        source_name TEXT,
        asking_price TEXT,
        mileage TEXT
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_scans_created_at ON $_tableName (created_at DESC)
    ''');

    await db.execute('''
      CREATE INDEX idx_scans_brand ON $_tableName (brand)
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE $_tableName ADD COLUMN extra_data TEXT');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE $_tableName ADD COLUMN source_url TEXT');
      await db.execute('ALTER TABLE $_tableName ADD COLUMN source_name TEXT');
      await db.execute('ALTER TABLE $_tableName ADD COLUMN asking_price TEXT');
      await db.execute('ALTER TABLE $_tableName ADD COLUMN mileage TEXT');
    }
    if (oldVersion < 4) {
      // Merge L3 into L2: all level 3 entries become level 2
      await db.execute('UPDATE $_tableName SET level = 2 WHERE level = 3');
    }
  }

  Future<int> insertScan(CarScan scan) async {
    final db = await database;
    return db.insert(_tableName, scan.toMap());
  }

  Future<List<CarScan>> getScans() async {
    final db = await database;
    final maps = await db.query(
      _tableName,
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => CarScan.fromMap(map)).toList();
  }

  Future<CarScan?> getScan(int id) async {
    final db = await database;
    final maps = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return CarScan.fromMap(maps.first);
  }

  Future<void> updateScan(CarScan scan) async {
    if (scan.id == null) {
      throw ArgumentError('Cannot update a scan without an id');
    }
    final db = await database;
    await db.update(
      _tableName,
      scan.toMap(),
      where: 'id = ?',
      whereArgs: [scan.id],
    );
  }

  Future<void> deleteScan(int id) async {
    final db = await database;
    await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> getScanCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM $_tableName');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}

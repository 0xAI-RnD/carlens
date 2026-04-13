import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/car_scan.dart';
import '../models/achievement.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static const String _dbName = 'carlens.db';
  static const int _dbVersion = 5;
  static const String _tableName = 'scans';
  static const String _achievementsTable = 'achievements';

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

    await db.execute('''
      CREATE TABLE $_achievementsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        achievement_id TEXT NOT NULL UNIQUE,
        category TEXT NOT NULL,
        tier TEXT NOT NULL,
        threshold INTEGER NOT NULL,
        unlocked_at INTEGER
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_achievements_category ON $_achievementsTable (category)
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
    if (oldVersion < 5) {
      await db.execute('''
        CREATE TABLE $_achievementsTable (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          achievement_id TEXT NOT NULL UNIQUE,
          category TEXT NOT NULL,
          tier TEXT NOT NULL,
          threshold INTEGER NOT NULL,
          unlocked_at INTEGER
        )
      ''');
      await db.execute(
          'CREATE INDEX idx_achievements_category ON $_achievementsTable (category)');
    }
  }

  // --- Scans CRUD ---

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
    final result =
        await db.rawQuery('SELECT COUNT(*) as count FROM $_tableName');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // --- Achievement CRUD ---

  Future<List<Achievement>> getAchievements() async {
    final db = await database;
    final maps = await db.query(_achievementsTable);
    return maps.map((map) => Achievement.fromMap(map)).toList();
  }

  Future<Achievement?> getAchievement(String achievementId) async {
    final db = await database;
    final maps = await db.query(
      _achievementsTable,
      where: 'achievement_id = ?',
      whereArgs: [achievementId],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Achievement.fromMap(maps.first);
  }

  Future<void> insertAchievement(Achievement achievement) async {
    final db = await database;
    await db.insert(_achievementsTable, achievement.toMap());
  }

  Future<void> unlockAchievement(
      String achievementId, DateTime unlockedAt) async {
    final db = await database;
    await db.update(
      _achievementsTable,
      {'unlocked_at': unlockedAt.millisecondsSinceEpoch},
      where: 'achievement_id = ?',
      whereArgs: [achievementId],
    );
  }

  Future<int> getDistinctBrandCount() async {
    final db = await database;
    final result = await db
        .rawQuery('SELECT COUNT(DISTINCT brand) as count FROM $_tableName');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getDistinctEraCount() async {
    final db = await database;
    final result = await db.rawQuery(
      "SELECT COUNT(DISTINCT CAST(SUBSTR(year_estimate, 1, 3) AS INTEGER)) as count FROM $_tableName WHERE year_estimate GLOB '[0-9][0-9][0-9][0-9]*'",
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getBrandOccurrenceCount(String brand) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_tableName WHERE brand = ?',
      [brand],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<bool> hasDecadeInScans(int decade) async {
    final db = await database;
    final decadeStr = decade.toString().substring(0, 3);
    final result = await db.rawQuery(
      "SELECT COUNT(*) as count FROM $_tableName WHERE year_estimate GLOB '[0-9][0-9][0-9][0-9]*' AND SUBSTR(year_estimate, 1, 3) = ?",
      [decadeStr],
    );
    return (Sqflite.firstIntValue(result) ?? 0) > 0;
  }

  Future<void> seedAchievements() async {
    final db = await database;

    const definitions = [
      // Scansioni
      {'achievement_id': 'scans_base', 'category': 'scans', 'tier': 'base', 'threshold': 1},
      {'achievement_id': 'scans_bronze', 'category': 'scans', 'tier': 'bronze', 'threshold': 10},
      {'achievement_id': 'scans_silver', 'category': 'scans', 'tier': 'silver', 'threshold': 50},
      {'achievement_id': 'scans_gold', 'category': 'scans', 'tier': 'gold', 'threshold': 200},
      // Brand
      {'achievement_id': 'brands_base', 'category': 'brands', 'tier': 'base', 'threshold': 1},
      {'achievement_id': 'brands_bronze', 'category': 'brands', 'tier': 'bronze', 'threshold': 5},
      {'achievement_id': 'brands_silver', 'category': 'brands', 'tier': 'silver', 'threshold': 15},
      {'achievement_id': 'brands_gold', 'category': 'brands', 'tier': 'gold', 'threshold': 30},
      // Ere
      {'achievement_id': 'eras_base', 'category': 'eras', 'tier': 'base', 'threshold': 1},
      {'achievement_id': 'eras_bronze', 'category': 'eras', 'tier': 'bronze', 'threshold': 2},
      {'achievement_id': 'eras_silver', 'category': 'eras', 'tier': 'silver', 'threshold': 4},
      {'achievement_id': 'eras_gold', 'category': 'eras', 'tier': 'gold', 'threshold': 6},
    ];

    final batch = db.batch();
    for (final def in definitions) {
      batch.rawInsert(
        'INSERT OR IGNORE INTO $_achievementsTable (achievement_id, category, tier, threshold) VALUES (?, ?, ?, ?)',
        [def['achievement_id'], def['category'], def['tier'], def['threshold']],
      );
    }
    await batch.commit(noResult: true);
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}

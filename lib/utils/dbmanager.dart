import 'package:aurovilletv/data/models/category_model.dart';
import 'package:aurovilletv/data/models/video_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBManager {
  DBManager._();

  static final DBManager instance = DBManager._();
  static Database? _database;

  static const String _databaseName = 'auroville_tv.db';
  static const int _databaseVersion = 4; // Bumped version to recreate schema cleanly
  static const String watchListTable = 'watchlist';
  static const String categoriesTable = 'categories';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, _databaseName);
    return openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // ---------------- Watchlist Table Creation ----------------
    await db.execute('''
      CREATE TABLE $watchListTable (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        video_url TEXT,
        thumbnail TEXT,
        category TEXT,
        publish_date TEXT,
        upload_date TEXT,
        duration_minutes INTEGER,
        topic_tag TEXT,
        featured INTEGER NOT NULL DEFAULT 0,
        view_count INTEGER NOT NULL DEFAULT 0,
        is_live INTEGER NOT NULL DEFAULT 0,
        published INTEGER NOT NULL DEFAULT 0,
        watched_at TEXT
      )
    ''');

    // ---------------- Categories Table Creation ----------------
    await db.execute('''
      CREATE TABLE $categoriesTable (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Drop old table to clean up constraint mismatches
    await db.execute('DROP TABLE IF EXISTS $watchListTable');
    await db.execute('DROP TABLE IF EXISTS $categoriesTable');
    await _onCreate(db, newVersion);
  }

  // ==========================================
  // ---------------- Watchlist / History -----
  // ==========================================

  Future<List<VideoModel>> getWatchList() async {
    final db = await database;
    final result = await db.query(
      watchListTable,
      orderBy: 'COALESCE(watched_at, publish_date) DESC',
    );
    return result.map(VideoModel.fromMap).toList();
  }

  /// Alias for getWatchList
  Future<List<VideoModel>> getVideos() async => getWatchList();

  /// Inserts video with timestamp safely
  Future<void> addVideo(VideoModel video) async {
    final db = await database;
    final map = Map<String, dynamic>.from(video.toMap());
    map['watched_at'] = DateTime.now().toIso8601String();

    await db.insert(
      watchListTable,
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Alias for addVideo
  Future<void> saveVideo(VideoModel video) async => addVideo(video);

  /// Same as addVideo (for recording watch history)
  Future<void> recordVideoWatch(VideoModel video) async {
    await addVideo(video);
  }

  Future<void> removeVideo(String id) async {
    final db = await database;
    await db.delete(
      watchListTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> removeFromHistory(String id) async {
    await removeVideo(id);
  }

  Future<bool> isInWatchList(String id) async {
    final db = await database;
    final result = await db.query(
      watchListTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  Future<void> clearWatchList() async {
    final db = await database;
    await db.delete(watchListTable);
  }

  Future<void> clearWatchHistory() async {
    await clearWatchList();
  }

  // ==========================================
  // ---------------- Categories --------------
  // ==========================================

  Future<List<CategoryModel>> getCategories() async {
    final db = await database;
    final result = await db.query(categoriesTable, orderBy: 'name ASC');
    return result.map((e) => CategoryModel.fromMap(e)).toList();
  }

  Future<void> insertCategories(List<CategoryModel> categories) async {
    final db = await database;
    final batch = db.batch();
    for (final category in categories) {
      batch.insert(
        categoriesTable,
        category.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<void> clearCategories() async {
    final db = await database;
    await db.delete(categoriesTable);
  }

  Future<void> replaceCategories(List<CategoryModel> categories) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(categoriesTable);
      final batch = txn.batch();
      for (final category in categories) {
        batch.insert(categoriesTable, category.toMap());
      }
      await batch.commit(noResult: true);
    });
  }
}

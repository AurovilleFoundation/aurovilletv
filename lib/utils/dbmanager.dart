import 'package:aurovilletv/data/models/category_model.dart';
import 'package:aurovilletv/data/models/video_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBManager {
  DBManager._();

  static final DBManager instance = DBManager._();

  static Database? _database;

  static const String _databaseName = 'auroville_tv.db';
  static const int _databaseVersion = 3;
  static const String watchListTable = 'watchlist';

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
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
    await db.execute('''
      CREATE TABLE $watchListTable (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        video_url TEXT NOT NULL,
        thumbnail TEXT NOT NULL,
        category_id TEXT NOT NULL,
        date_time TEXT NOT NULL,
        featured INTEGER NOT NULL,
        view_count INTEGER NOT NULL
      )
    ''');

    // Categories Table
    await db.execute('''
    CREATE TABLE event_categories (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL
    )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      await db.execute('DROP TABLE IF EXISTS $watchListTable');
      await db.execute('DROP TABLE IF EXISTS event_categories');
      await _onCreate(db, newVersion);
    }
  }

  /// Get all locally stored videos from sqflite
  Future<List<VideoModel>> getVideos() async {
    final db = await database;
    // Clean up any legacy dummy videos if present
    await db.delete(watchListTable, where: "id IN ('1', '2', '3', '4', '5')");
    final result = await db.query(watchListTable, orderBy: 'date_time DESC');
    return result.map(VideoModel.fromMap).toList();
  }

  /// Alias for getVideos
  Future<List<VideoModel>> getWatchList() async => getVideos();

  /// Used to store a video data into sqflite
  Future<void> saveVideo(VideoModel video) async {
    final db = await database;

    await db.insert(
      watchListTable,
      video.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Alias for saveVideo
  Future<void> addVideo(VideoModel video) async => saveVideo(video);

  Future<void> removeVideo(String id) async {
    final db = await database;
    await db.delete(watchListTable, where: 'id = ?', whereArgs: [id]);
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

  Future<List<CategoryModel>> getCategories() async {
    final db = await database;

    final result = await db.query('event_categories', orderBy: 'name ASC');

    return result.map((e) => CategoryModel.fromMap(e)).toList();
  }

  Future<void> insertCategories(List<CategoryModel> categories) async {
    final db = await database;

    final batch = db.batch();

    for (final category in categories) {
      batch.insert(
        'event_categories',
        category.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<void> clearCategories() async {
    final db = await database;

    await db.delete('event_categories');
  }

  Future<void> replaceCategories(List<CategoryModel> categories) async {
    final db = await database;

    await db.transaction((txn) async {
      await txn.delete('event_categories');

      final batch = txn.batch();

      for (final category in categories) {
        batch.insert('event_categories', category.toMap());
      }

      await batch.commit(noResult: true);
    });
  }
}

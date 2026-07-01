import 'package:aurovilletv/data/models/category_model.dart';
import 'package:aurovilletv/data/models/video_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBManager {
  DBManager._();

  static final DBManager instance = DBManager._();

  static Database? _database;

  static const String _databaseName = 'auroville_tv.db';
  static const int _databaseVersion = 1;
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
    return openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $watchListTable (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        video_url TEXT NOT NULL,
        thumbnail TEXT NOT NULL,
        category_id INTEGER NOT NULL,
        date_time TEXT NOT NULL,
        featured INTEGER NOT NULL,
        view_count INTEGER NOT NULL
      )
    ''');

    // Categories Table
    await db.execute('''
    CREATE TABLE categories (
      id INTEGER PRIMARY KEY,
      name TEXT NOT NULL
    )
    ''');

    await _insertDummyVideos(db);
  }

  Future<List<VideoModel>> getWatchList() async {
    final db = await database;
    final result = await db.query(watchListTable, orderBy: 'date_time DESC');
    return result.map(VideoModel.fromMap).toList();
  }

  Future<void> addVideo(VideoModel video) async {
    final db = await database;

    await db.insert(
      watchListTable,
      video.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

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

  //--------------------------------------------------------------------------
  // Dummy Data
  //--------------------------------------------------------------------------

  Future<void> _insertDummyVideos(Database db) async {
    final videos = <VideoModel>[
      VideoModel(
        id: '1',
        title: 'Living Together in Diversity',
        description: 'An inspiring documentary about Auroville.',
        videoUrl: 'https://example.com/video1.mp4',
        thumbnail: 'assets/images/thumb1.jpg',
        categoryId: 1,
        dateTime: DateTime.now().subtract(const Duration(days: 1)),
        featured: true,
        viewCount: 2560,
      ),
      VideoModel(
        id: '2',
        title: 'The Matrimandir Story',
        description: 'Journey into the heart of Auroville.',
        videoUrl: 'https://example.com/video2.mp4',
        thumbnail: 'assets/images/thumb2.jpg',
        categoryId: 2,
        dateTime: DateTime.now().subtract(const Duration(days: 2)),
        featured: true,
        viewCount: 1824,
      ),
      VideoModel(
        id: '3',
        title: 'Sustainability in Action',
        description: 'How Auroville is building a sustainable future.',
        videoUrl: 'https://example.com/video3.mp4',
        thumbnail: 'assets/images/thumb3.jpg',
        categoryId: 3,
        dateTime: DateTime.now().subtract(const Duration(days: 3)),
        featured: false,
        viewCount: 1432,
      ),
      VideoModel(
        id: '4',
        title: 'Youth of Auroville',
        description: 'Stories from the younger generation.',
        videoUrl: 'https://example.com/video4.mp4',
        thumbnail: 'assets/images/thumb4.jpg',
        categoryId: 4,
        dateTime: DateTime.now().subtract(const Duration(days: 4)),
        featured: false,
        viewCount: 920,
      ),
      VideoModel(
        id: '5',
        title: 'Regreening Auroville',
        description: 'The transformation of a barren land.',
        videoUrl: 'https://example.com/video5.mp4',
        thumbnail: 'assets/images/thumb5.jpg',
        categoryId: 5,
        dateTime: DateTime.now().subtract(const Duration(days: 5)),
        featured: true,
        viewCount: 3285,
      ),
    ];

    final batch = db.batch();

    for (final video in videos) {
      batch.insert(watchListTable, video.toMap());
    }

    await batch.commit(noResult: true);
  }
}

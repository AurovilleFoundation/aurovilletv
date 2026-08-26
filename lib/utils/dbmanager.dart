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
  static const String categoriesTable = 'categories';

  Future<Database> get database async {
    if (_database != null) return _database!;
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
        video_url TEXT,
        thumbnail TEXT,
        category TEXT,
        publish_date TEXT,
        duration_minutes INTEGER,
        topic_tag TEXT,              -- ✅ fixed: added column
        featured INTEGER NOT NULL,
        view_count INTEGER NOT NULL,
        is_live INTEGER NOT NULL,
        published INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $categoriesTable (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL
      )
    ''');

    await _insertDummyVideos(db);
  }

  // ---------------- Watchlist ----------------
  Future<List<VideoModel>> getWatchList() async {
    final db = await database;
    final result = await db.query(watchListTable, orderBy: 'publish_date DESC');
    return result.map(VideoModel.fromMap).toList();
  }

  Future<void> addVideo(VideoModel video) async {
    final db = await database;
    await db.insert(watchListTable, video.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> removeVideo(String id) async {
    final db = await database;
    await db.delete(watchListTable, where: 'id = ?', whereArgs: [id]);
  }

  Future<bool> isInWatchList(String id) async {
    final db = await database;
    final result = await db.query(watchListTable,
        where: 'id = ?', whereArgs: [id], limit: 1);
    return result.isNotEmpty;
  }

  Future<void> clearWatchList() async {
    final db = await database;
    await db.delete(watchListTable);
  }

  // ---------------- Categories ----------------
  Future<List<CategoryModel>> getCategories() async {
    final db = await database;
    final result = await db.query(categoriesTable, orderBy: 'name ASC');
    return result.map((e) => CategoryModel.fromMap(e)).toList();
  }

  Future<void> insertCategories(List<CategoryModel> categories) async {
    final db = await database;
    final batch = db.batch();
    for (final category in categories) {
      batch.insert(categoriesTable, category.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
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

  // ---------------- Dummy Data ----------------
  Future<void> _insertDummyVideos(Database db) async {
    final videos = <VideoModel>[
      VideoModel(
        id: '1',
        title: 'Living Together in Diversity',
        description: 'An inspiring documentary about Auroville.',
        videoUrl: 'https://example.com/video1.mp4',
        thumbnail: 'assets/images/thumb.png',
        category: 'Documentary',
        publishDate: DateTime.now().subtract(const Duration(days: 1)),
        durationMinutes: 28,
        topicTag: 'Nature',
        featured: true,
        viewCount: 2560,
        isLive: false,
        published: true,
      ),
      VideoModel(
        id: '2',
        title: 'Voices of Auroville',
        description: 'Stories from the community.',
        videoUrl: 'https://example.com/video2.mp4',
        thumbnail: 'assets/images/thumb.png',
        category: 'People',
        publishDate: DateTime.now().subtract(const Duration(days: 2)),
        durationMinutes: 18,
        topicTag: 'People',
        featured: true,
        viewCount: 1824,
        isLive: false,
        published: true,
      ),
      VideoModel(
        id: '3',
        title: 'Sustainability in Action',
        description: 'How Auroville is building a sustainable future.',
        videoUrl: 'https://example.com/video3.mp4',
        thumbnail: 'assets/images/thumb.png',
        category: 'Documentary',
        publishDate: DateTime.now().subtract(const Duration(days: 3)),
        durationMinutes: 22,
        topicTag: 'Sustainability',
        featured: false,
        viewCount: 1432,
        isLive: false,
        published: true,
      ),
      VideoModel(
        id: '4',
        title: 'Arts as a Way of Life',
        description: 'Exploring creativity in Auroville.',
        videoUrl: 'https://example.com/video4.mp4',
        thumbnail: 'assets/images/thumb.png',
        category: 'Culture',
        publishDate: DateTime.now().subtract(const Duration(days: 4)),
        durationMinutes: 15,
        topicTag: 'Culture',
        featured: false,
        viewCount: 920,
        isLive: false,
        published: true,
      ),
      VideoModel(
        id: '5',
        title: 'Education for Conscious Living',
        description: 'Talk on holistic education.',
        videoUrl: 'https://example.com/video5.mp4',
        thumbnail: 'assets/images/thumb.png',
        category: 'Talk',
        publishDate: DateTime.now().subtract(const Duration(days: 5)),
        durationMinutes: 20,
        topicTag: 'Education',
        featured: true,
        viewCount: 3285,
        isLive: false,
        published: true,
      ),
    ];

    final batch = db.batch();
    for (final video in videos) {
      batch.insert(watchListTable, video.toMap());
    }
    await batch.commit(noResult: true);
  }
}

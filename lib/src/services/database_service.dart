import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/fav_quote.dart';
import '../models/reader.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'quote_app.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE readers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE favorite_quotes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        quote_id INTEGER NOT NULL,
        quote_text TEXT NOT NULL,
        quote_author TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES readers (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('CREATE UNIQUE INDEX idx_favorite_user_quote ON favorite_quotes(user_id, quote_id)');
    await db.execute('CREATE INDEX idx_favorite_created ON favorite_quotes(created_at)');
  }

  Future<int> insertReader(QuoteReader reader) async {
    final db = await database;
    return db.insert('readers', reader.toMap());
  }

  Future<QuoteReader?> getReaderById(int id) async {
    final db = await database;
    final maps = await db.query(
      'readers',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return QuoteReader.fromMap(maps.first);
  }

  Future<QuoteReader?> getFirstReader() async {
    final db = await database;
    final maps = await db.query(
      'readers',
      orderBy: 'created_at DESC',
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return QuoteReader.fromMap(maps.first);
  }

  Future<List<QuoteReader>> getAllReaders() async {
    final db = await database;
    final maps = await db.query(
      'readers',
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => QuoteReader.fromMap(map)).toList();
  }

  Future<int> updateReader(QuoteReader reader) async {
    final db = await database;
    return db.update(
      'readers',
      reader.toMap(),
      where: 'id = ?',
      whereArgs: [reader.id],
    );
  }

  Future<int> deleteReader(int id) async {
    final db = await database;
    return db.delete(
      'readers',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> upsertFavoriteQuote(FavoriteQuote favorite) async {
    final db = await database;
    return db.insert(
      'favorite_quotes',
      favorite.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> removeFavoriteQuote({required int userId, required int quoteId}) async {
    final db = await database;
    return db.delete(
      'favorite_quotes',
      where: 'user_id = ? AND quote_id = ?',
      whereArgs: [userId, quoteId],
    );
  }

  Future<bool> isQuoteFavorited({required int userId, required int quoteId}) async {
    final db = await database;
    final maps = await db.query(
      'favorite_quotes',
      columns: ['id'],
      where: 'user_id = ? AND quote_id = ?',
      whereArgs: [userId, quoteId],
      limit: 1,
    );

    return maps.isNotEmpty;
  }

  Future<List<FavoriteQuote>> getFavoriteQuotes(int userId, {int? limit}) async {
    final db = await database;
    final maps = await db.query(
      'favorite_quotes',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
      limit: limit,
    );

    return maps.map((map) => FavoriteQuote.fromMap(map)).toList();
  }

  Future<int> countFavoriteQuotes(int userId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM favorite_quotes WHERE user_id = ?',
      [userId],
    );

    return (result.first['count'] as int?) ?? 0;
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}

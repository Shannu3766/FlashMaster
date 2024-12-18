import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flashmaster/classess/Flashcard.dart';

class FlashCardDatabase {
  static final FlashCardDatabase instance = FlashCardDatabase._init();

  static Database? _database;

  FlashCardDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('flashcards.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE flashcards (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        Question TEXT NOT NULL,
        Answer TEXT NOT NULL
      )
    ''');
  }

  Future<void> insertCard(Flashcard card) async {
    final db = await instance.database;
    // final vs = card.toMap();
    // print(vs["id"]);
    // print(vs["Question"]);
    // print(vs["Answer"]);
    await db.insert('flashcards', card.toMap());
  }

  Future<int?> getMaxId() async {
    final db = await database; // Access your database instance
    final result = await db.rawQuery('SELECT MAX(id) as maxId FROM Flashcards');
    return result.first['maxId'] as int?;
  }

  Future<List<Flashcard>> getCards() async {
    final db = await instance.database;
    final result = await db.query('flashcards');
    return result.map((map) => Flashcard.fromMap(map)).toList();
  }

  Future<void> updateCard(Flashcard card) async {
    final db = await instance.database;
    await db.update(
      'flashcards',
      card.toMap(),
      where: 'id = ?',
      whereArgs: [card.id],
    );
  }

  Future<void> deleteCard(int id) async {
    final db = await instance.database;
    await db.delete(
      'flashcards',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

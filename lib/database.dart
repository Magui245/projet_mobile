import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class TodoItem {
  final String title;
  final int indicatorColor;

  TodoItem({required this.title, required this.indicatorColor});

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'indicatorColor': indicatorColor,
    };
  }

  factory TodoItem.fromMap(Map<String, dynamic> map) {
    return TodoItem(
      title: map['title'],
      indicatorColor: map['indicatorColor'],
    );
  }
}

class DatabaseHelper {
  static final _databaseName = "TodoDatabase.db";
  static final _databaseVersion = 1;

  static final table = 'todo_table';
  static final columnTitle = 'title';
  static final columnIndicatorColor = 'indicatorColor';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnTitle TEXT NOT NULL,
        $columnIndicatorColor INTEGER NOT NULL
      )
    ''');
  }

  Future<int> insert(TodoItem todo) async {
    Database db = await instance.database;
    return await db.insert(table, todo.toMap());
  }

  Future<List<TodoItem>> getAllTodoItems() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(table);
    return List.generate(maps.length, (i) {
      return TodoItem.fromMap(maps[i]);
    });
  }

  Future<int> update(TodoItem todo) async {
    Database db = await instance.database;
    return await db.update(
      table,
      todo.toMap(),
      where: '$columnTitle = ?',
      whereArgs: [todo.title],
    );
  }

  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(
      table,
      where: '$columnTitle = ?',
      whereArgs: [id],
    );
  }
}

import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  /// Obtém a instância do banco de dados
  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('cleartask.db');
    return _database!;
  }

  /// Inicializa o banco de dados
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // Abre o banco de dados
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  /// Cria as tabelas no banco de dados
  Future _createDB(Database db, int version) async {
    const String idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const String textType = 'TEXT NOT NULL';
    const String boolType = 'BOOLEAN NOT NULL';
    const String nullableTextType = 'TEXT';
    const String nullableDateType = 'TEXT'; // Armazena DateTime como string

    await db.execute('''
CREATE TABLE tasks (
  id $idType,
  title $textType,
  description $nullableTextType,
  date $nullableDateType,
  isCompleted $boolType,
  isEvent $boolType,
  categories $nullableTextType
)
''');

    await db.execute('''
CREATE TABLE users (
  id $idType,
  name $textType,
  email TEXT NOT NULL UNIQUE,
  password $textType
)
''');
  }

  /// Insere uma nova tarefa no banco de dados
  Future<int> insertTask(Task task) async {
    final db = await instance.database;

    final id = await db.insert('tasks', task.toMap());
    return id;
  }

  /// Obtém todas as tarefas do banco de dados
  Future<List<Task>> getAllTasks() async {
    final db = await instance.database;

    final result = await db.query('tasks');

    return result.map((json) => Task.fromMap(json)).toList();
  }

  /// Atualiza uma tarefa existente no banco de dados
  Future<int> updateTask(Task task) async {
    final db = await instance.database;

    return db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  /// Deleta uma tarefa pelo ID do banco de dados
  Future<int> deleteTask(int id) async {
    final db = await instance.database;

    return db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Insere um novo usuário no banco de dados
  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await instance.database;
    return await db.insert('users', user);
  }

  /// Obtém um usuário pelo email e senha
  Future<Map<String, dynamic>?> getUserByEmailAndPassword(String email, String password) async {
    final db = await instance.database;

    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null;
    }
  }

  /// Obtém um usuário pelo email
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await instance.database;

    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null;
    }
  }

  /// Fecha a conexão com o banco de dados
  Future close() async {
    final db = await instance.database;

    db.close();
  }
}

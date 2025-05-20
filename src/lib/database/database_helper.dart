// lib/database/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class FeedingSchedule {
  final int? id;
  final int hour;
  final int minute;
  final bool isActive;

  FeedingSchedule({
    this.id,
    required this.hour,
    required this.minute,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'hour': hour,
      'minute': minute,
      'isActive': isActive ? 1 : 0,
    };
  }

  factory FeedingSchedule.fromMap(Map<String, dynamic> map) {
    return FeedingSchedule(
      id: map['id'],
      hour: map['hour'],
      minute: map['minute'],
      isActive: map['isActive'] == 1,
    );
  }
}

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('feeding_schedule.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE feeding_schedule(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        hour INTEGER NOT NULL,
        minute INTEGER NOT NULL,
        isActive INTEGER NOT NULL,
        UNIQUE(hour, minute)
      )
    ''');
  }

  Future<FeedingSchedule> create(FeedingSchedule schedule) async {
    final db = await instance.database;
    try {
      final id = await db.insert('feeding_schedule', schedule.toMap());
      return FeedingSchedule(
        id: id,
        hour: schedule.hour,
        minute: schedule.minute,
        isActive: schedule.isActive,
      );
    } catch (e) {
      if (e is DatabaseException &&
          e.toString().contains('UNIQUE constraint failed')) {
        throw Exception('A feeding schedule already exists for this time');
      }
      throw Exception('Failed to create schedule: $e');
    }
  }

  Future<List<FeedingSchedule>> getAllSchedules() async {
    final db = await instance.database;
    final result = await db.query('feeding_schedule', orderBy: 'hour, minute');
    return result.map((json) => FeedingSchedule.fromMap(json)).toList();
  }

  Future<int> update(FeedingSchedule schedule) async {
    final db = await instance.database;
    try {
      return await db.update(
        'feeding_schedule',
        schedule.toMap(),
        where: 'id = ?',
        whereArgs: [schedule.id],
      );
    } catch (e) {
      if (e is DatabaseException &&
          e.toString().contains('UNIQUE constraint failed')) {
        throw Exception('A feeding schedule already exists for this time');
      }
      throw Exception('Failed to update schedule: $e');
    }
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      'feeding_schedule',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}

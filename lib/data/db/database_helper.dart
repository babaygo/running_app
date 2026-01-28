import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'running.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE activities (
        id TEXT PRIMARY KEY,
        start_time TEXT NOT NULL,
        end_time TEXT NOT NULL,
        distance_meters REAL NOT NULL,
        duration_seconds INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE track_points (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        activity_id TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        altitude REAL NOT NULL,
        timestamp TEXT NOT NULL,
        FOREIGN KEY(activity_id) REFERENCES activities(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE splits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        activity_id TEXT NOT NULL,
        split_index INTEGER NOT NULL,
        distance_meters REAL NOT NULL,
        total_distance REAL NOT NULL,
        duration_seconds INTEGER NOT NULL,
        pace_seconds INTEGER NOT NULL,
        current_km INTEGER NOT NULL,
        altitude REAL NOT NULL,
        timestamp TEXT NOT NULL,
        FOREIGN KEY(activity_id) REFERENCES activities(id) ON DELETE CASCADE
      )
    ''');
  }
}

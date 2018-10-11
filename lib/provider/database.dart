import 'dart:async';
import 'package:notes/features/notes/model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io';

class DatabaseProvider {
  static Database _db;
  static DatabaseProvider _instance = DatabaseProvider._internal();
  static const DB_NAME = "notes.db";
  static const DB_VERSION = 1;
  Future<Database> get db async {
    if (_db != null) return _db;
    _db = await _initDb();
    return _db;
  }

  factory DatabaseProvider() {
    return _instance;
  }

  DatabaseProvider._internal();

  _initDb() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    String path = join(appDir.path, DB_NAME);
    return await openDatabase(path,
        version: DB_VERSION, singleInstance: true, onCreate: _onCreate);
  }

  void _onCreate(Database db, int version) async {
    await db.execute("""CREATE TABLE ${Note.TABLE_NAME} (
      ${Note.COL_ID} INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      ${Note.COL_TITLE} TEXT NOT NULL,
      ${Note.COL_CONTENT} TEXT NOT NULL,
      ${Note.COL_IS_PINNED} INTEGER NOT NULL DEFAULT 0,
      ${Note.COL_CREATED_AT} INTEGER NOT NULL,
      ${Note.COL_MODIFIED_AT} INTEGER,
      ${Note.COL_DELETED_AT} INTEGER,
      ${Note.COL_CATEGORY_ID} INTEGER
    )"""
        .trim());
  }
}

import 'dart:async';
import 'package:notes/provider/database.dart';
import 'package:notes/features/notes/model.dart';
import 'package:sqflite/sqflite.dart';

class NoteRepository {
  static NoteRepository _instance = NoteRepository._internal();
  DatabaseProvider _dbProvider;
  factory NoteRepository() => _instance;

  NoteRepository._internal() {
    _dbProvider = DatabaseProvider();
    print("init");
  }
  Future<List<Note>> getNoteList() async {
    Database db = await _dbProvider.db;
    List<Map> results = await db.query(Note.TABLE_NAME);
    return results.map((map) => Note.fromMap(map)).toList();
  }

  Future<List<Note>> searchNote(String query) async {
    print("Search $query");
    Database db = await _dbProvider.db;
    List<Map> results = await db.query(
      Note.TABLE_NAME,
      where: "${Note.COL_TITLE} LIKE ? OR ${Note.COL_CONTENT} LIKE ?", whereArgs: ["%$query%", "%$query%"],
      orderBy: "${Note.COL_CREATED_AT} DESC"
      
    );
    return results.map((map) => Note.fromMap(map)).toList();
  }

  Future<int> insertNote(Note note) async {
    Database db = await _dbProvider.db;
    return db.insert(Note.TABLE_NAME, note.toMap());
  }

  Future<int> updateNote(Note note) async {
    Database db = await _dbProvider.db;
    return db.update(Note.TABLE_NAME,
        note.copy(Note(modifiedAt: DateTime.now(), id: null)).toMap(),
        where: "${Note.COL_ID} = ?", whereArgs: [note.id]);
  }

  Future<List<dynamic>> deleteNote(List<Note> noteList) async {
    Database db = await _dbProvider.db;
    Batch batch = db.batch();
    noteList.forEach(
      (n) => batch.delete(
            Note.TABLE_NAME,
            where: "${Note.COL_ID} = ?",
            whereArgs: [n.id],
          ),
    );
    return batch.commit();
  }
}

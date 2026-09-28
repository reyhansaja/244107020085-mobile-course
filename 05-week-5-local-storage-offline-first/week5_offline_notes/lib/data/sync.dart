import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import 'local/db.dart';
import 'local/note.dart';
import 'repositories/node_repository.dart';

class SyncService {
  SyncService({
    NoteRepository? notes,
    Future<Database> Function()? openDb,
  })  : _notes = notes ?? NoteRepository(openDb: openDb),
        _openDb = openDb ?? openNotesDb;

  final NoteRepository _notes;
  final Future<Database> Function() _openDb;

  Future<void> cachePost({
    required int id,
    required String payload,
  }) async {
    final db = await _openDb();
    await db.insert(
      'cached_posts',
      {
        'id': id,
        'payload': payload,
        'cached_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, Object?>>> fetchCachedPosts() async {
    final db = await _openDb();
    return db.query('cached_posts', orderBy: 'cached_at DESC');
  }

  Future<List<Map<String, dynamic>>> cacheFirstPosts({
    required Future<List<Map<String, dynamic>>> Function() fetchRemote,
  }) async {
    final cached = await fetchCachedPosts();
    if (cached.isNotEmpty) {
      return cached
          .map((row) => jsonDecode(row['payload']! as String))
          .whereType<Map<String, dynamic>>()
          .toList();
    }

    final remote = await fetchRemote();
    for (final post in remote) {
      final id = post['id'];
      if (id is int) {
        await cachePost(id: id, payload: jsonEncode(post));
      }
    }
    return remote;
  }

  Future<void> syncNotes({
    required Future<void> Function(Note note) pushNote,
  }) async {
    final dirtyNotes = await _notes.fetchNotes();
    for (final note in dirtyNotes.where((note) => note.dirty)) {
      if (note.id == null) continue;
      await pushNote(note);
      await _notes.markSynced(note.id!);
    }
  }
}

import 'package:flutter/material.dart';

import '../data/local/note.dart';
import '../data/repositories/node_repository.dart';

class NoteDetailPage extends StatefulWidget {
  const NoteDetailPage({required this.noteId, super.key});

  final int noteId;

  @override
  State<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  final NoteRepository repository = NoteRepository();
  late Future<Note?> noteFuture;

  @override
  void initState() {
    super.initState();
    noteFuture = repository.fetchNoteById(widget.noteId);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Detail catatan')),
        body: FutureBuilder<Note?>(
          future: noteFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Gagal memuat catatan: ${snapshot.error}'));
            }
            final note = snapshot.data;
            if (note == null) {
              return const Center(child: Text('Catatan tidak ditemukan'));
            }
            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(note.title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 16),
                Text(note.body),
                const SizedBox(height: 24),
                Text('Diperbarui: ${note.updatedAt}'),
                if (note.dirty)
                  const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Chip(label: Text('belum tersinkron')),
                  ),
              ],
            );
          },
        ),
      );
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/local/note.dart';
import '../data/repositories/node_repository.dart';
import '../widgets/note_tile.dart';

final noteRepositoryProvider = Provider<NoteRepository>((ref) => NoteRepository());
final notesProvider = FutureProvider<List<Note>>(
  (ref) => ref.watch(noteRepositoryProvider).fetchNotes(),
);

class NotesPage extends ConsumerStatefulWidget {
  const NotesPage({super.key});

  @override
  ConsumerState<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends ConsumerState<NotesPage> {
  final titleController = TextEditingController();
  final bodyController = TextEditingController();
  bool isAdding = false;

  @override
  void dispose() {
    titleController.dispose();
    bodyController.dispose();
    super.dispose();
  }

  void startAdding() {
    setState(() => isAdding = true);
  }

  void cancelAdding() {
    titleController.clear();
    bodyController.clear();
    setState(() => isAdding = false);
  }

  Future<void> saveNote() async {
    final title = titleController.text.trim();
    if (title.isEmpty) return;

    await ref.read(noteRepositoryProvider).addNote(
      title: title,
      body: bodyController.text.trim(),
    );
    if (!mounted) return;
    titleController.clear();
    bodyController.clear();
    ref.invalidate(notesProvider);
    setState(() => isAdding = false);
  }

  Future<void> deleteNote(Note note) async {
    if (note.id == null) return;
    await ref.read(noteRepositoryProvider).deleteNote(note.id!);
    if (!mounted) return;
    ref.invalidate(notesProvider);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Catatan'),
          actions: [
            IconButton(
              tooltip: 'Pengaturan',
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => context.push('/settings'),
            ),
          ],
        ),
        body: Column(
          children: [
            if (isAdding) _buildNoteForm(),
            Expanded(
              child: ref.watch(notesProvider).when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stackTrace) =>
                      Center(child: Text('Gagal memuat catatan: $error')),
                  data: (notes) {
                  if (notes.isEmpty) {
                    return const Center(child: Text('Belum ada catatan'));
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: notes.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      return NoteTile(
                        note: note,
                        onTap: () => context.push('/note/${note.id}'),
                        onDelete: () => deleteNote(note),
                      );
                    },
                  );
                }),
            ),
          ],
        ),
        floatingActionButton: isAdding
            ? null
            : FloatingActionButton.extended(
                onPressed: startAdding,
                icon: const Icon(Icons.add),
                label: const Text('Tambah'),
              ),
      );

  Widget _buildNoteForm() => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Judul'),
            ),
            TextField(
              controller: bodyController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Isi catatan'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: cancelAdding, child: const Text('Batal')),
                const SizedBox(width: 8),
                FilledButton(onPressed: saveNote, child: const Text('Simpan')),
              ],
            ),
          ],
        ),
      );
}

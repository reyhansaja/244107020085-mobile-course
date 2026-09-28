import 'package:flutter/material.dart';

import '../data/local/note.dart';

class NoteTile extends StatelessWidget {
  const NoteTile({
    required this.note,
    required this.onTap,
    required this.onDelete,
    super.key,
  });

  final Note note;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          onTap: onTap,
          title: Text(note.title),
          subtitle: note.body.isEmpty ? null : Text(note.body),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (note.dirty)
                const Chip(
                  label: Text('belum tersinkron'),
                  visualDensity: VisualDensity.compact,
                ),
              IconButton(
                tooltip: 'Hapus catatan',
                icon: const Icon(Icons.delete_outline),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      );
}

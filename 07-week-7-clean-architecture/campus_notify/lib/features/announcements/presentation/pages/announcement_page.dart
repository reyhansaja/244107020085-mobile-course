import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/format.dart';
import '../providers/announcement_providers.dart';

/// Halaman tujuan deep link `/pengumuman/:id`.
class AnnouncementPage extends ConsumerWidget {
  const AnnouncementPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(announcementsProvider);
    final item = state.value
        ?.where((announcement) => announcement.id == id)
        .firstOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pengumuman'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text(announcementErrorMessage(error))),
        data: (_) => item == null
            ? Center(child: Text('Pengumuman #$id tidak ditemukan.'))
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text('ID: ${item.id} · ${formatDateTime(item.publishedAt)}'),
                  const Divider(height: 24),
                  Text(item.body),
                ],
              ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../notifications/presentation/providers/push_providers.dart';
import '../../../../routes.dart';
import '../providers/announcement_providers.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcements = ref.watch(filteredAnnouncementsProvider);
    final query = ref.watch(searchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengumuman Kampus'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: () => ref.read(authStateProvider.notifier).logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _PushStatusCard(),
          const SizedBox(height: 8),
          TextField(
            onChanged: (value) =>
                ref.read(searchQueryProvider.notifier).set(value),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Cari judul pengumuman',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          ...announcements.when(
            loading: () => const [Center(child: CircularProgressIndicator())],
            error: (error, _) => [
              Text(announcementErrorMessage(error)),
              TextButton(
                onPressed: () => ref.invalidate(announcementsProvider),
                child: const Text('Coba lagi'),
              ),
            ],
            data: (items) => items.isEmpty
                ? [
                    Text(
                      query.trim().isEmpty
                          ? 'Belum ada pengumuman.'
                          : 'Tidak ada pengumuman yang cocok dengan '
                                '"$query".',
                    ),
                  ]
                : [
                    for (final item in items)
                      Card(
                        child: ListTile(
                          title: Text(item.title),
                          subtitle: Text(item.body),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push(
                            AppRoutes.announcementDetail(item.id),
                          ),
                        ),
                      ),
                  ],
          ),
        ],
      ),
    );
  }
}

class _PushStatusCard extends ConsumerWidget {
  const _PushStatusCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final token = ref.watch(deviceTokenProvider);
    final status = ref.watch(deviceStatusProvider);
    final pushEnabled = ref.watch(pushRepositoryProvider).enabled;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              pushEnabled ? 'FCM aktif' : 'FCM belum dikonfigurasi (mode mock)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text('Token: ${_mask(token)}'),
            Text('Status token: $status'),
            const SizedBox(height: 8),
            const Text(
              'Klik pengumuman = simulasi payload notification + '
              'data {route: /pengumuman/:id}.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  /// Token tidak pernah ditampilkan penuh.
  static String _mask(String? token) {
    if (token == null || token.isEmpty) return '- (belum ada)';
    if (token.length <= 12) return '${token.substring(0, 4)}…';
    return '${token.substring(0, 6)}…${token.substring(token.length - 4)}';
  }
}

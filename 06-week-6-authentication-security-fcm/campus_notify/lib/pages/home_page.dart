import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../routes.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcements = ref.watch(announcementRepositoryProvider).all();
    final token = ref.watch(deviceTokenProvider);
    final deviceStatus = ref.watch(deviceStatusProvider);
    final pushEnabled = ref.watch(pushServiceProvider).enabled;

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
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pushEnabled
                        ? 'FCM aktif'
                        : 'FCM belum dikonfigurasi (mode mock)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text('Token: ${_mask(token)}'),
                  Text('Status token: $deviceStatus'),
                  const SizedBox(height: 8),
                  const Text(
                    'Klik salah satu pengumuman = simulasi payload '
                    'notification + data {route: /pengumuman/:id}.',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          for (final item in announcements)
            Card(
              child: ListTile(
                title: Text(item.title),
                subtitle: Text(item.body),
                trailing: const Icon(Icons.chevron_right),
                onTap: () =>
                    context.push(AppRoutes.announcementDetail(item.id)),
              ),
            ),
          const SizedBox(height: 16),
          FilledButton.tonal(
            onPressed: () =>
                ref.read(pushServiceProvider).unsubscribe('pengumuman-kampus'),
            child: const Text('Berhenti langganan topik'),
          ),
        ],
      ),
    );
  }

  /// Token tidak pernah ditampilkan penuh (aturan keamanan codelab).
  static String _mask(String? token) {
    if (token == null || token.isEmpty) return '- (belum ada)';
    if (token.length <= 12) return '${token.substring(0, 4)}…';
    return '${token.substring(0, 6)}…${token.substring(token.length - 4)}';
  }
}

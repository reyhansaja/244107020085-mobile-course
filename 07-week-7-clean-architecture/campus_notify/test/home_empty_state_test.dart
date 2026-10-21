import 'package:campus_notify/features/announcements/domain/entities/announcement.dart';
import 'package:campus_notify/features/announcements/presentation/pages/home_page.dart';
import 'package:campus_notify/features/announcements/presentation/providers/announcement_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('empty state muncul saat query tidak cocok', (tester) async {
    final container = ProviderContainer(
      overrides: [
        announcementsProvider.overrideWith(
          (ref) async => [
            Announcement(
              id: '1',
              title: 'Jadwal kuliah berubah',
              body: 'isi',
              publishedAt: DateTime(2026, 10, 1),
            ),
          ],
        ),
      ],
    );
    addTearDown(container.dispose);
    await container.read(announcementsProvider.future);
    container.read(searchQueryProvider.notifier).set('zzz-tak-ada');

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: HomePage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Tidak ada pengumuman yang cocok'),
      findsOneWidget,
    );
    expect(find.text('Jadwal kuliah berubah'), findsNothing);
  });

  testWidgets('daftar tampil saat query cocok', (tester) async {
    final container = ProviderContainer(
      overrides: [
        announcementsProvider.overrideWith(
          (ref) async => [
            Announcement(
              id: '1',
              title: 'Jadwal kuliah berubah',
              body: 'isi',
              publishedAt: DateTime(2026, 10, 1),
            ),
          ],
        ),
      ],
    );
    addTearDown(container.dispose);
    await container.read(announcementsProvider.future);
    container.read(searchQueryProvider.notifier).set('JADWAL');

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: HomePage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Jadwal kuliah berubah'), findsOneWidget);
  });
}

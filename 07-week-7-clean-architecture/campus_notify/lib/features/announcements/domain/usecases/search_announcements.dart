import '../entities/announcement.dart';

/// Pencarian judul pengumuman. Fungsi murni: tanpa widget, tanpa repository,
/// sehingga bisa diuji tanpa Flutter test harness.
///
/// ponytail: versi pertama (draf AI) memakai `contains` apa adanya sehingga
/// pencarian case-sensitive. Diganti ke perbandingan lowercase setelah test
/// merah membuktikannya — lihat docs/ai-log.md Minggu 9.
List<Announcement> filterAnnouncements(List<Announcement> items, String query) {
  final needle = query.trim().toLowerCase();
  if (needle.isEmpty) return items;
  return items
      .where((item) => item.title.toLowerCase().contains(needle))
      .toList();
}

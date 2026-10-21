import 'package:campus_notify/features/announcements/domain/entities/announcement.dart';
import 'package:campus_notify/features/announcements/domain/usecases/search_announcements.dart';
import 'package:flutter_test/flutter_test.dart';

Announcement _a(String id, String title) => Announcement(
  id: id,
  title: title,
  body: 'isi',
  publishedAt: DateTime(2026, 10, 1),
);

final _items = [
  _a('1', 'Jadwal kuliah berubah'),
  _a('2', 'Praktikum minggu 6'),
  _a('3', 'Jadwal ujian akhir'),
];

void main() {
  test('query kosong mengembalikan semua item', () {
    expect(filterAnnouncements(_items, '   '), hasLength(3));
  });

  test('filter abaikan huruf besar/kecil', () {
    expect(filterAnnouncements(_items, 'jadwal'), hasLength(2));
    expect(filterAnnouncements(_items, 'JADWAL'), hasLength(2));
  });

  test('query tak cocok mengembalikan kosong (empty state)', () {
    expect(filterAnnouncements(_items, 'zzz-tak-ada'), isEmpty);
  });

  test('mencocokkan sebagian kata di tengah judul', () {
    final result = filterAnnouncements(_items, 'ujian');
    expect(result.single.id, '3');
  });
}

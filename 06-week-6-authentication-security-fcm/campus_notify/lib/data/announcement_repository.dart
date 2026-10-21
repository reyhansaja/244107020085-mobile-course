/// Sumber data pengumuman. Di produksi kelas ini memanggil
/// `GET /pengumuman` lewat Dio; di codelab isinya mock lokal supaya
/// deep link `/pengumuman/:id` bisa dibuktikan tanpa backend.
class Announcement {
  const Announcement({
    required this.id,
    required this.title,
    required this.body,
    required this.publishedAt,
  });

  final String id;
  final String title;
  final String body;
  final DateTime publishedAt;
}

class AnnouncementRepository {
  const AnnouncementRepository();

  static final List<Announcement> _items = [
    Announcement(
      id: '1',
      title: 'Jadwal kuliah berubah',
      body: 'Kelas Mobile pindah ke Ruang A2 jam 13.00 mulai pekan depan.',
      publishedAt: DateTime(2026, 10, 20, 9, 15),
    ),
    Announcement(
      id: '2',
      title: 'Praktikum minggu 6',
      body:
          'Bawa laptop dan akun Firebase. Kuota Spark cukup, tanpa kartu kredit.',
      publishedAt: DateTime(2026, 10, 19, 15, 40),
    ),
    Announcement(
      id: '3',
      title: 'Batas unggah tugas',
      body:
          'Tugas FCM diunggah paling lambat Minggu 23.59 ke repository portfolio.',
      publishedAt: DateTime(2026, 10, 18, 8, 5),
    ),
  ];

  List<Announcement> all() => List.unmodifiable(_items);

  Announcement? byId(String id) {
    for (final item in _items) {
      if (item.id == id) return item;
    }
    return null;
  }
}

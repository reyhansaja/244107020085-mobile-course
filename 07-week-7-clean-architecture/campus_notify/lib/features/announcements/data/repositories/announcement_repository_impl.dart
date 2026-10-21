import '../../../../core/failures.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/repositories/announcement_repository.dart';
import '../models/announcement_model.dart';

/// Sumber data: di produksi `GET /pengumuman` lewat Dio. Di codelab datanya
/// mock JSON lokal supaya alur data -> entity bisa diuji tanpa jaringan.
class AnnouncementRepositoryImpl implements AnnouncementRepository {
  const AnnouncementRepositoryImpl();

  static const _rawJson = <Map<String, dynamic>>[
    {
      'id': '1',
      'title': 'Jadwal kuliah berubah',
      'body': 'Kelas Mobile pindah ke Ruang A2 jam 13.00 mulai pekan depan.',
      'published_at': '2026-10-20T09:15:00',
    },
    {
      'id': '2',
      'title': 'Praktikum minggu 6',
      'body':
          'Bawa laptop dan akun Firebase. Kuota Spark cukup, tanpa kartu kredit.',
      'published_at': '2026-10-19T15:40:00',
    },
    {
      'id': '3',
      'title': 'Batas unggah tugas',
      'body':
          'Tugas FCM diunggah paling lambat Minggu 23.59 ke repository portfolio.',
      'published_at': '2026-10-18T08:05:00',
    },
  ];

  @override
  Future<({List<Announcement> announcements, Failure? failure})>
  fetchAll() async {
    try {
      final items = _rawJson
          .map(AnnouncementModel.fromMap)
          .map((model) => model.toEntity())
          .toList();
      return (announcements: items, failure: null);
    } catch (e) {
      return (
        announcements: const <Announcement>[],
        failure: LocalFailure('Gagal membaca pengumuman: $e'),
      );
    }
  }
}

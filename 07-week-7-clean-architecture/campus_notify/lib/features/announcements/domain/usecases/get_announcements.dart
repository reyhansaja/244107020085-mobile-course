import '../../../../core/failures.dart';
import '../entities/announcement.dart';
import '../repositories/announcement_repository.dart';

/// Aturan bisnis: pengumuman selalu urut terbaru dan judul kosong dibuang.
/// Aturan ini tidak boleh bergantung pada widget atau sumber data.
class GetAnnouncements {
  const GetAnnouncements(this._repository);

  final AnnouncementRepository _repository;

  Future<({List<Announcement> announcements, Failure? failure})> call() async {
    final result = await _repository.fetchAll();
    if (result.failure != null) {
      return (announcements: const <Announcement>[], failure: result.failure);
    }
    final items =
        result.announcements
            .where((item) => item.title.trim().isNotEmpty)
            .toList()
          ..sort((a, b) {
            final byDate = b.publishedAt.compareTo(a.publishedAt);
            // Tie-break: List.sort tidak stabil, tanpa ini urutan item
            // ber-timestamp sama bisa berubah antarbuild.
            return byDate != 0 ? byDate : a.id.compareTo(b.id);
          });
    return (announcements: items, failure: null);
  }
}

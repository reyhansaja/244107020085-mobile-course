import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/announcement.dart';
import '../../domain/repositories/announcement_repository.dart';
import '../../domain/usecases/get_announcements.dart';
import '../../data/repositories/announcement_repository_impl.dart';
import '../../../../core/failures.dart';

final announcementRepositoryProvider = Provider<AnnouncementRepository>((ref) {
  return const AnnouncementRepositoryImpl();
});

final getAnnouncementsProvider = Provider<GetAnnouncements>((ref) {
  return GetAnnouncements(ref.watch(announcementRepositoryProvider));
});

/// Presentation hanya membaca state; aturan urut/filter ada di use case.
final announcementsProvider = FutureProvider<List<Announcement>>((ref) async {
  final result = await ref.watch(getAnnouncementsProvider).call();
  final failure = result.failure;
  if (failure != null) throw failure;
  return result.announcements;
});

String announcementErrorMessage(Object? error) {
  if (error is Failure) return error.message;
  return 'Gagal memuat pengumuman.';
}

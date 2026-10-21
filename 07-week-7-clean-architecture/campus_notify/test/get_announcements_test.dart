import 'package:campus_notify/core/failures.dart';
import 'package:campus_notify/features/announcements/domain/entities/announcement.dart';
import 'package:campus_notify/features/announcements/domain/repositories/announcement_repository.dart';
import 'package:campus_notify/features/announcements/domain/usecases/get_announcements.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeAnnouncementRepository implements AnnouncementRepository {
  FakeAnnouncementRepository({this.items = const [], this.fail = false});

  final List<Announcement> items;
  final bool fail;
  int calls = 0;

  @override
  Future<({List<Announcement> announcements, Failure? failure})>
  fetchAll() async {
    calls++;
    if (fail) {
      return (
        announcements: const <Announcement>[],
        failure: const LocalFailure('db terkunci (simulasi)'),
      );
    }
    return (announcements: items, failure: null);
  }
}

Announcement _item(String id, DateTime at, {String title = 'Judul'}) {
  return Announcement(id: id, title: title, body: 'isi', publishedAt: at);
}

void main() {
  test('mengurutkan pengumuman terbaru lebih dulu', () async {
    final repo = FakeAnnouncementRepository(
      items: [
        _item('1', DateTime(2026, 10, 1)),
        _item('3', DateTime(2026, 10, 3)),
        _item('2', DateTime(2026, 10, 2)),
      ],
    );

    final result = await GetAnnouncements(repo).call();

    expect(result.failure, isNull);
    expect(result.announcements.map((a) => a.id), ['3', '2', '1']);
  });

  test('membuang pengumuman tanpa judul', () async {
    final repo = FakeAnnouncementRepository(
      items: [
        _item('1', DateTime(2026, 10, 1)),
        _item('2', DateTime(2026, 10, 2), title: '   '),
      ],
    );

    final result = await GetAnnouncements(repo).call();

    expect(result.announcements, hasLength(1));
    expect(result.announcements.single.id, '1');
  });

  test('timestamp sama diurutkan stabil berdasarkan id', () async {
    final same = DateTime(2026, 10, 5, 10);
    final repo = FakeAnnouncementRepository(
      items: [_item('2', same), _item('1', same), _item('3', same)],
    );

    final result = await GetAnnouncements(repo).call();

    expect(result.announcements.map((a) => a.id), ['1', '2', '3']);
  });

  test('meneruskan failure tanpa melempar exception', () async {
    final repo = FakeAnnouncementRepository(fail: true);

    final result = await GetAnnouncements(repo).call();

    expect(result.failure, isA<LocalFailure>());
    expect(result.announcements, isEmpty);
    expect(repo.calls, 1);
  });
}

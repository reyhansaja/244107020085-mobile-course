import 'package:campus_notify/core/format.dart';
import 'package:campus_notify/core/push_route.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('routeFromMessage', () {
    test('data kosong jatuh ke beranda', () {
      expect(routeFromMessage({}), '/');
    });

    test('rute tanpa slash depan ditambahkan', () {
      expect(routeFromMessage({'route': 'pengumuman/3'}), '/pengumuman/3');
    });

    test('rute absolut dipakai apa adanya', () {
      expect(routeFromMessage({'route': '/pengumuman/3'}), '/pengumuman/3');
    });

    test('id pengumuman dibaca dari payload', () {
      expect(announcementIdFromMessage({'id': '3'}), '3');
      expect(announcementIdFromMessage({'id': '  '}), isNull);
    });
  });

  test('formatDateTime menghasilkan dd/MM/yyyy HH:mm', () {
    expect(formatDateTime(DateTime(2026, 9, 7, 8, 5)), '07/09/2026 08:05');
  });
}

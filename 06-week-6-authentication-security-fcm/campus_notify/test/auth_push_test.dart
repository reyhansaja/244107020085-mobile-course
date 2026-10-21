import 'package:campus_notify/data/api_errors.dart';
import 'package:campus_notify/data/auth_repository.dart';
import 'package:campus_notify/messaging/route_parser.dart';
import 'package:dio/dio.dart';
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

    test('data payload membawa id pengumuman', () {
      const data = {'route': '/pengumuman/3', 'id': '3'};
      expect(announcementIdFromMessage(data), '3');
      expect(routeFromMessage(data), '/pengumuman/3');
    });

    test('id kosong dianggap tidak ada', () {
      expect(announcementIdFromMessage({'id': '  '}), isNull);
      expect(announcementIdFromMessage({}), isNull);
    });
  });

  group('friendlyError', () {
    final request = RequestOptions(path: '/devices');

    test('401 jadi pesan sesi habis', () {
      final error = DioException(
        requestOptions: request,
        type: DioExceptionType.badResponse,
        response: Response<dynamic>(requestOptions: request, statusCode: 401),
      );
      expect(friendlyError(error), 'Sesi habis. Silakan login ulang.');
    });

    test('timeout jadi pesan koneksi lambat', () {
      final error = DioException(
        requestOptions: request,
        type: DioExceptionType.receiveTimeout,
      );
      expect(friendlyError(error), 'Koneksi lambat. Coba lagi.');
    });

    test('offline jadi pesan tanpa koneksi', () {
      final error = DioException(
        requestOptions: request,
        type: DioExceptionType.connectionError,
      );
      expect(friendlyError(error), 'Tidak ada koneksi internet.');
    });

    test('exception non-Dio tetap terbaca manusia', () {
      expect(
        friendlyError(Exception('Email atau kata sandi tidak valid')),
        'Email atau kata sandi tidak valid',
      );
    });
  });

  group('sesi dan refresh token', () {
    const auth = AuthRepository();

    test('login valid mengembalikan sepasang token', () async {
      final session = await auth.login(
        email: 'mahasiswa@polinema.ac.id',
        password: 'rahasia123',
      );
      expect(session.access, isNotEmpty);
      expect(session.refresh, isNotEmpty);
    });

    test('email tanpa @ ditolak', () {
      expect(
        () => auth.login(email: 'bukan-email', password: 'rahasia123'),
        throwsA(isA<Exception>()),
      );
    });

    test('kata sandi pendek ditolak', () {
      expect(
        () => auth.login(email: 'a@b.c', password: '123'),
        throwsA(isA<Exception>()),
      );
    });

    test('refresh token kosong -> sesi harus dibersihkan (paksa login)', () {
      expect(() => auth.refresh(''), throwsA(isA<Exception>()));
    });
  });
}

import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'api_errors.dart';

/// Endpoint backend: `POST /devices` menyimpan FCM token per user.
/// Tanpa backend sungguhan, kegagalan jaringan dicatat sebagai status lokal
/// supaya UI tetap bisa menampilkan token mana yang seharusnya dikirim.
class DeviceRepository {
  const DeviceRepository(this._post);

  final Future<dynamic> Function(String path, Map<String, dynamic> body) _post;

  Future<String> register(String token, String platform) async {
    try {
      await _post('/devices', {'fcm_token': token, 'platform': platform});
      return 'terkirim ke backend';
    } catch (e) {
      return 'belum terkirim (${friendlyError(e)})';
    }
  }
}

/// Payload contoh yang dikirim app server ke FCM (HTTP v1).
String examplePushPayload(String route) =>
    const JsonEncoder.withIndent('  ').convert({
      'message': {
        'topic': 'pengumuman-kampus',
        'notification': {
          'title': 'Jadwal kuliah berubah',
          'body': 'Kelas Mobile pindah ke Ruang A2 jam 13.00',
        },
        'data': {'route': route, 'id': route.split('/').last},
      },
    });

void logDevice(String message) => debugPrint(message);

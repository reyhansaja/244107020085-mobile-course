import 'package:flutter/foundation.dart';

/// Kontrak push notification supaya lapisan UI tidak bergantung langsung pada
/// Firebase (dan tetap jalan di web/desktop saat project Firebase belum ada).
abstract class PushService {
  bool get enabled;

  Future<void> start({
    required Future<void> Function(String token) onToken,
    required void Function(String route) go,
  });

  Future<void> subscribe(String topic);

  Future<void> unsubscribe(String topic);
}

/// Dipakai saat Firebase belum dikonfigurasi (tanpa google-services.json).
class NoopPushService implements PushService {
  @override
  bool get enabled => false;

  @override
  Future<void> start({
    required Future<void> Function(String token) onToken,
    required void Function(String route) go,
  }) async {
    debugPrint(
      'push: Firebase belum dikonfigurasi, FCM dilewati. '
      'Tambahkan google-services.json + plugin Gradle untuk mengaktifkan.',
    );
  }

  @override
  Future<void> subscribe(String topic) async {}

  @override
  Future<void> unsubscribe(String topic) async {}
}

import 'package:flutter/foundation.dart';

import '../domain/repositories/push_repository.dart';

/// Dipakai saat Firebase belum dikonfigurasi (tanpa google-services.json,
/// atau di web). Aplikasi tetap jalan, hanya notifikasi yang tidak aktif.
class NoopPushRepository implements PushRepository {
  const NoopPushRepository();

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

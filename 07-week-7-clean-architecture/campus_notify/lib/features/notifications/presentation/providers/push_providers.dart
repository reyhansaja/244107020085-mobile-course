import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/api_client.dart';
import '../../data/device_api.dart';
import '../../data/push_service_firebase.dart';
import '../../data/push_service_noop.dart';
import '../../domain/repositories/push_repository.dart';

final dioProvider = Provider<Dio>((ref) {
  return buildApiClient(ref.watch(authRepositoryProvider));
});

final deviceApiProvider = Provider<DeviceApi>((ref) {
  return DeviceApi(ref.watch(dioProvider));
});

/// Firebase hanya dipakai bila benar-benar terinisialisasi; selain itu no-op
/// supaya aplikasi (dan demo web) tetap berjalan tanpa konfigurasi.
final pushRepositoryProvider = Provider<PushRepository>((ref) {
  return FirebaseBootstrap.ready
      ? FirebasePushRepository()
      : const NoopPushRepository();
});

class DeviceTokenNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void set(String? token) => state = token;
}

final deviceTokenProvider = NotifierProvider<DeviceTokenNotifier, String?>(
  DeviceTokenNotifier.new,
);

class DeviceStatusNotifier extends Notifier<String> {
  @override
  String build() => 'belum diinisialisasi';

  void set(String value) => state = value;
}

final deviceStatusProvider = NotifierProvider<DeviceStatusNotifier, String>(
  DeviceStatusNotifier.new,
);

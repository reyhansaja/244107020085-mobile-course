import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/announcement_repository.dart';
import '../data/api_client.dart';
import '../data/auth_repository.dart';
import '../data/device_repository.dart';
import '../data/token_store.dart';
import '../messaging/firebase_push_service.dart';
import '../messaging/push_service.dart';

// ---------------------------------------------------------------------------
// Wiring DI Minggu 6: semua dependensi dibuat di sini, widget tidak pernah
// meng-instansiasi repository sendiri.
// ---------------------------------------------------------------------------

final tokenStoreProvider = Provider<TokenStore>((ref) => TokenStore());

const _authRepository = AuthRepository();
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => _authRepository,
);

final dioProvider = Provider<Dio>((ref) {
  return buildApiClient(
    ref.watch(tokenStoreProvider),
    ref.watch(authRepositoryProvider),
  );
});

final deviceRepositoryProvider = Provider<DeviceRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return DeviceRepository((path, body) => dio.post<dynamic>(path, data: body));
});

final announcementRepositoryProvider = Provider<AnnouncementRepository>(
  (ref) => const AnnouncementRepository(),
);

final pushServiceProvider = Provider<PushService>((ref) {
  return FirebaseBootstrap.ready ? FirebasePushService() : NoopPushService();
});

/// Token FCM aktif (dipotong saat ditampilkan, tidak pernah di-log penuh).
class DeviceTokenNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void set(String? token) => state = token;
}

final deviceTokenProvider = NotifierProvider<DeviceTokenNotifier, String?>(
  DeviceTokenNotifier.new,
);

/// Status pengiriman token ke backend, untuk bukti di UI.
class DeviceStatusNotifier extends Notifier<String> {
  @override
  String build() => 'belum diinisialisasi';

  void set(String value) => state = value;
}

final deviceStatusProvider = NotifierProvider<DeviceStatusNotifier, String>(
  DeviceStatusNotifier.new,
);

// ---------------------------------------------------------------------------
// State autentikasi
// ---------------------------------------------------------------------------

final authStateProvider = AsyncNotifierProvider<AuthNotifier, bool>(
  AuthNotifier.new,
);

class AuthNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final token = await ref.watch(tokenStoreProvider).readAccess();
    return token != null;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final session = await ref
          .read(authRepositoryProvider)
          .login(email: email, password: password);
      await ref
          .read(tokenStoreProvider)
          .save(access: session.access, refresh: session.refresh);
      return true;
    });
  }

  Future<void> logout() async {
    await ref.read(tokenStoreProvider).clear();
    ref.invalidateSelf();
    debugPrint('logout: token dibersihkan');
  }
}

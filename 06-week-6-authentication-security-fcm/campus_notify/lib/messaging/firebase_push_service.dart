import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'push_service.dart';
import 'route_parser.dart';

/// Inisialisasi Firebase sekali di awal. Tanpa `google-services.json`
/// (mis. di web/desktop atau saat project Firebase belum dibuat) aplikasi
/// tetap jalan dengan [NoopPushService]; tidak ada secret yang di-hardcode.
class FirebaseBootstrap {
  FirebaseBootstrap._();

  static bool ready = false;
  static Object? error;

  static Future<bool> init() async {
    if (ready) return true;
    // Web butuh FirebaseOptions eksplisit (apiKey, projectId, VAPID key);
    // codelab ini fokus Android sehingga web berjalan dalam mode mock.
    if (kIsWeb) return false;
    try {
      // Batas waktu: init yang menggantung tidak boleh menahan runApp().
      await Firebase.initializeApp().timeout(const Duration(seconds: 8));
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      ready = true;
    } catch (e) {
      error = e;
      ready = false;
      debugPrint('firebase init gagal: $e');
    }
    return ready;
  }
}

/// WAJIB fungsi top-level: berjalan di isolate terpisah sehingga tidak boleh
/// menyentuh BuildContext, Riverpod, atau navigasi. Tugasnya hanya mencatat.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('bg message -> ${routeFromMessage(message.data)}');
}

class FirebasePushService implements PushService {
  static final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  static const _channel = AndroidNotificationDetails(
    'pengumuman',
    'Pengumuman Kampus',
    channelDescription: 'Notifikasi pengumuman dan perubahan jadwal',
    importance: Importance.high,
    priority: Priority.high,
  );

  bool _localReady = false;
  String? _pendingDeepLink;

  @override
  bool get enabled => true;

  @override
  Future<void> start({
    required Future<void> Function(String token) onToken,
    required void Function(String route) go,
  }) async {
    await _requestPermission();
    await _initLocalNotifications();
    await _initToken(onToken);
    _listenForeground(go);
    await _handleTerminated(go);
    await subscribe('pengumuman-kampus');
  }

  /// Android 13+ dan iOS wajib izin runtime.
  Future<bool> _requestPermission() async {
    try {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      final granted =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
      if (defaultTargetPlatform == TargetPlatform.android) {
        await _local
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.requestNotificationsPermission();
      }
      return granted;
    } catch (e) {
      debugPrint('permission notifikasi gagal: $e');
      return false;
    }
  }

  Future<void> _initLocalNotifications() async {
    if (_localReady) return;
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    try {
      await _local.initialize(
        settings: settings,
        onDidReceiveNotificationResponse: (response) {
          // Klik banner foreground: payload = rute tujuan.
          _pendingDeepLink = response.payload;
        },
      );
      _localReady = true;
    } catch (e) {
      debugPrint('local notification tidak tersedia di platform ini: $e');
    }
  }

  /// Registrasi FCM + pengiriman token ke backend.
  ///
  /// Catatan versi: `firebase_messaging` 17 menandai `getToken()` /
  /// `onTokenRefresh` sebagai deprecated dan menggantinya dengan
  /// `register()` + `onRegistered`. Perilakunya sama: satu nilai saat ini,
  /// lalu nilai baru setiap token berubah. Listener refresh wajib ada, jika
  /// tidak backend menyimpan token basi setelah reinstall/clear data.
  Future<void> _initToken(Future<void> Function(String token) onToken) async {
    try {
      await FirebaseMessaging.instance.register();
      FirebaseMessaging.instance.onRegistered.listen((token) {
        if (token.isNotEmpty) onToken(token);
      });
      // Fallback bila stream belum memancarkan nilai saat ini.
      // ignore: deprecated_member_use
      final current = await FirebaseMessaging.instance.getToken();
      if (current != null && current.isNotEmpty) await onToken(current);
    } catch (e) {
      debugPrint('ambil FCM token gagal: $e');
    }
  }

  void _listenForeground(void Function(String route) go) {
    FirebaseMessaging.onMessage.listen((message) async {
      final route = routeFromMessage(message.data);
      if (_localReady) {
        try {
          await _local.show(
            id: message.hashCode,
            title: message.notification?.title ?? 'Pengumuman',
            body: message.notification?.body ?? '',
            notificationDetails: const NotificationDetails(android: _channel),
            payload: route,
          );
          return;
        } catch (e) {
          debugPrint('tampilkan banner lokal gagal: $e');
        }
      }
      // Platform tanpa local notification: langsung arahkan ke rute.
      go(route);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      go(routeFromMessage(message.data));
    });
  }

  /// Terminated: aplikasi dibuka dari notifikasi.
  Future<void> _handleTerminated(void Function(String route) go) async {
    try {
      final initial = await FirebaseMessaging.instance.getInitialMessage();
      if (initial != null) {
        go(routeFromMessage(initial.data));
        return;
      }
    } catch (e) {
      debugPrint('getInitialMessage gagal: $e');
    }
    final pending = _pendingDeepLink;
    if (pending != null && pending.isNotEmpty) go(pending);
  }

  @override
  Future<void> subscribe(String topic) async {
    try {
      await FirebaseMessaging.instance.subscribeToTopic(topic);
    } catch (e) {
      debugPrint('subscribe $topic gagal: $e');
    }
  }

  @override
  Future<void> unsubscribe(String topic) async {
    try {
      await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
    } catch (e) {
      debugPrint('unsubscribe $topic gagal: $e');
    }
  }
}

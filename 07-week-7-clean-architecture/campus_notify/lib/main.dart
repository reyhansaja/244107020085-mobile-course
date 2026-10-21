import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/notifications/data/push_service_firebase.dart';
import 'features/notifications/presentation/providers/push_providers.dart';
import 'routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Tanpa google-services.json, init gagal dan push otomatis jadi no-op.
  await FirebaseBootstrap.init();
  runApp(const ProviderScope(child: CampusNotifyApp()));
}

class CampusNotifyApp extends ConsumerStatefulWidget {
  const CampusNotifyApp({super.key});

  @override
  ConsumerState<CampusNotifyApp> createState() => _CampusNotifyAppState();
}

class _CampusNotifyAppState extends ConsumerState<CampusNotifyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startPush());
  }

  /// Router sudah siap di sini, jadi deep link dari notifikasi
  /// (foreground / background / terminated) bisa langsung `go`.
  Future<void> _startPush() async {
    final router = ref.read(routerProvider);
    await ref
        .read(pushRepositoryProvider)
        .start(
          onToken: (token) async {
            ref.read(deviceTokenProvider.notifier).set(token);
            final status = await ref
                .read(deviceApiProvider)
                .register(token, defaultTargetPlatform.name);
            ref.read(deviceStatusProvider.notifier).set(status);
          },
          go: router.go,
        );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Campus Notification App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF14532D),
        useMaterial3: true,
      ),
      routerConfig: ref.watch(routerProvider),
    );
  }
}

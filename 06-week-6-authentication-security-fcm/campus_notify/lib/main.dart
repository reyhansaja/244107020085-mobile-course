import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'messaging/firebase_push_service.dart';
import 'providers/auth_provider.dart';
import 'providers/router_provider.dart';

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

  /// Dipanggil setelah router siap supaya deep link dari notifikasi
  /// (foreground / background / terminated) bisa langsung `go`.
  Future<void> _startPush() async {
    final router = ref.read(routerProvider);
    await ref
        .read(pushServiceProvider)
        .start(
          onToken: (token) async {
            ref.read(deviceTokenProvider.notifier).set(token);
            final status = await ref
                .read(deviceRepositoryProvider)
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/announcements/presentation/pages/announcement_page.dart';
import 'features/announcements/presentation/pages/home_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/providers/auth_providers.dart';

/// Semua string rute di satu tempat: deep link FCM dan GoRouter memakai
/// konstanta yang sama.
class AppRoutes {
  const AppRoutes._();

  static const login = '/login';
  static const home = '/';
  static const announcement = '/pengumuman/:id';

  static String announcementDetail(String id) => '/pengumuman/$id';
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _AuthRefresh(ref);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: AppRoutes.home,
    refreshListenable: refresh,
    redirect: (context, state) {
      final loggedIn = ref.read(authStateProvider).value ?? false;
      final goingLogin = state.matchedLocation == AppRoutes.login;
      if (!loggedIn && !goingLogin) return AppRoutes.login;
      if (loggedIn && goingLogin) return AppRoutes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.announcement,
        builder: (context, state) =>
            AnnouncementPage(id: state.pathParameters['id'] ?? ''),
      ),
    ],
  );
});

class _AuthRefresh extends ChangeNotifier {
  _AuthRefresh(Ref ref) {
    _subscription = ref.listen<AsyncValue<bool>>(authStateProvider, (
      previous,
      next,
    ) {
      if (previous?.value != next.value) notifyListeners();
    });
  }

  late final ProviderSubscription<AsyncValue<bool>> _subscription;

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}

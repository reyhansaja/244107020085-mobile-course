import 'package:dio/dio.dart';

import '../../auth/domain/repositories/auth_repository.dart';

/// Dio + dua perilaku wajib: menyisipkan `Authorization: Bearer <access>` dan
/// menukar refresh token SEKALI saat 401 lalu mengulang request satu kali.
/// Bila refresh mati, sesi dibersihkan sehingga router memaksa login ulang.
Dio buildApiClient(AuthRepository auth) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://example-campus-api.test',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final access = await auth.accessToken();
        if (access != null) {
          options.headers['Authorization'] = 'Bearer $access';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        final retried = error.requestOptions.extra['retried'] == true;
        if (error.response?.statusCode != 401 || retried) {
          return handler.next(error);
        }
        final session = await auth.restore();
        final refresh = session.session?.refresh;
        if (refresh == null) return handler.next(error);
        final renewed = await auth.refreshAccess(refresh);
        if (renewed == null) {
          await auth.logout();
          return handler.next(error);
        }
        final retry = await dio.fetch(
          error.requestOptions
            ..extra['retried'] = true
            ..headers['Authorization'] = 'Bearer $renewed',
        );
        return handler.resolve(retry);
      },
    ),
  );

  return dio;
}

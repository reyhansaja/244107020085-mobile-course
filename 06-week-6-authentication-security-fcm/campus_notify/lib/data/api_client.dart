import 'package:dio/dio.dart';

import 'auth_repository.dart';
import 'token_store.dart';

/// Dio dengan dua perilaku wajib:
/// 1. menyisipkan `Authorization: Bearer <access>`,
/// 2. saat 401, menukar refresh token SEKALI lalu mengulang request satu kali.
///    Bila refresh ikut mati, token dibersihkan sehingga router memaksa login.
Dio buildApiClient(TokenStore store, AuthRepository auth) {
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
        final access = await store.readAccess();
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
        final refresh = await store.readRefresh();
        if (refresh == null) return handler.next(error);
        try {
          final renewed = await auth.refresh(refresh);
          await store.save(access: renewed, refresh: refresh);
          final retry = await dio.fetch(
            error.requestOptions
              ..extra['retried'] = true
              ..headers['Authorization'] = 'Bearer $renewed',
          );
          return handler.resolve(retry);
        } catch (_) {
          await store.clear();
        }
        return handler.next(error);
      },
    ),
  );

  return dio;
}

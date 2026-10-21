import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/failures.dart';
import '../../data/auth_repository_impl.dart';
import '../../data/token_store.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login.dart';

/// Satu-satunya tempat wiring fitur auth. Widget tidak pernah membuat
/// repository sendiri; semua lewat provider ini.
final tokenStoreProvider = Provider<TokenStore>((ref) => TokenStore());

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(store: ref.watch(tokenStoreProvider));
});

final loginProvider = Provider<Login>((ref) {
  return Login(ref.watch(authRepositoryProvider));
});

final authStateProvider = AsyncNotifierProvider<AuthNotifier, bool>(
  AuthNotifier.new,
);

class AuthNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final result = await ref.watch(authRepositoryProvider).restore();
    return result.session != null;
  }

  /// State error membawa `Failure` (bukan exception mentah) supaya UI cukup
  /// membaca `message`.
  Future<void> login({required String email, required String password}) async {
    state = const AsyncLoading();
    final result = await ref
        .read(loginProvider)
        .call(email: email, password: password);
    final failure = result.failure;
    if (failure != null) {
      state = AsyncError<bool>(failure, StackTrace.current);
      return;
    }
    state = AsyncData<bool>(result.session != null);
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    ref.invalidateSelf();
  }
}

/// Pesan siap tampil untuk state error auth.
String authErrorMessage(Object? error) {
  if (error is Failure) return error.message;
  return 'Gagal memproses permintaan. Coba lagi.';
}

import '../../../core/failures.dart';
import '../domain/entities/auth_session.dart';
import '../domain/repositories/auth_repository.dart';
import 'token_store.dart';

/// Implementasi mock (tanpa backend). Titik migrasi Firebase Auth hanya
/// mengganti isi [login]: `FirebaseAuth.instance.signInWithEmailAndPassword`
/// lalu `getIdToken()` sebagai access dan `getIdToken(refresh: true)` sebagai
/// refresh. Kontrak domain tidak berubah.
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required this.store,
    this.latency = const Duration(milliseconds: 400),
  });

  final TokenStore store;
  final Duration latency;

  @override
  Future<({AuthSession? session, Failure? failure})> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(latency);
    if (!email.contains('@') || password.length < 6) {
      return (
        session: null,
        failure: const AuthFailure('Email atau kata sandi tidak valid'),
      );
    }
    final session = AuthSession(
      access: 'mock-access-for-$email',
      refresh: 'mock-refresh-for-$email',
    );
    await store.save(access: session.access, refresh: session.refresh);
    return (session: session, failure: null);
  }

  @override
  Future<({AuthSession? session, Failure? failure})> restore() async {
    final access = await store.readAccess();
    final refresh = await store.readRefresh();
    if (access == null || refresh == null) {
      return (session: null, failure: null);
    }
    return (
      session: AuthSession(access: access, refresh: refresh),
      failure: null,
    );
  }

  @override
  Future<String?> accessToken() => store.readAccess();

  @override
  Future<String?> refreshAccess(String refreshToken) async {
    await Future<void>.delayed(latency);
    if (refreshToken.isEmpty) return null;
    final renewed =
        'mock-access-renewed-${DateTime.now().millisecondsSinceEpoch}';
    await store.save(access: renewed, refresh: refreshToken);
    return renewed;
  }

  @override
  Future<void> logout() => store.clear();
}

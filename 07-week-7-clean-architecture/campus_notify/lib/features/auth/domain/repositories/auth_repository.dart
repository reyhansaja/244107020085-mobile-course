import '../../../../core/failures.dart';
import '../entities/auth_session.dart';

/// Kontrak domain. Implementasi (mock / Firebase Auth / REST) ada di `data/`.
abstract class AuthRepository {
  /// `session == null && failure == null` berarti belum pernah login.
  Future<({AuthSession? session, Failure? failure})> login({
    required String email,
    required String password,
  });

  Future<({AuthSession? session, Failure? failure})> restore();

  Future<String?> accessToken();

  /// Menukar refresh token menjadi access token baru. `null` = refresh mati.
  Future<String?> refreshAccess(String refreshToken);

  Future<void> logout();
}

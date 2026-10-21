import '../../../../core/failures.dart';
import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

/// Satu operasi bisnis: memvalidasi input login sebelum menyentuh repository.
/// Aturan "email wajib diisi" tidak boleh hilang hanya karena backend berubah.
class Login {
  const Login(this._repository);

  final AuthRepository _repository;

  Future<({AuthSession? session, Failure? failure})> call({
    required String email,
    required String password,
  }) {
    final trimmed = email.trim();
    if (trimmed.isEmpty) {
      return Future.value((
        session: null,
        failure: const AuthFailure('Email wajib diisi'),
      ));
    }
    if (!trimmed.contains('@')) {
      return Future.value((
        session: null,
        failure: const AuthFailure('Format email tidak valid'),
      ));
    }
    if (password.length < 6) {
      return Future.value((
        session: null,
        failure: const AuthFailure('Kata sandi minimal 6 karakter'),
      ));
    }
    return _repository.login(email: trimmed, password: password);
  }
}

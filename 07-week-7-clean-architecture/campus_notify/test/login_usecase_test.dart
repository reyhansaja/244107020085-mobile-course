import 'package:campus_notify/core/failures.dart';
import 'package:campus_notify/features/auth/domain/entities/auth_session.dart';
import 'package:campus_notify/features/auth/domain/repositories/auth_repository.dart';
import 'package:campus_notify/features/auth/domain/usecases/login.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.fail = false});

  final bool fail;
  int loginCalls = 0;

  @override
  Future<({AuthSession? session, Failure? failure})> login({
    required String email,
    required String password,
  }) async {
    loginCalls++;
    if (fail) {
      return (
        session: null,
        failure: const AuthFailure('kredensial ditolak server'),
      );
    }
    return (
      session: AuthSession(access: 'a-$email', refresh: 'r-$email'),
      failure: null,
    );
  }

  @override
  Future<({AuthSession? session, Failure? failure})> restore() async =>
      (session: null, failure: null);

  @override
  Future<String?> accessToken() async => null;

  @override
  Future<String?> refreshAccess(String refreshToken) async => null;

  @override
  Future<void> logout() async {}
}

void main() {
  test('email kosong ditolak di use case tanpa memanggil repository', () async {
    final repo = FakeAuthRepository();
    final result = await Login(repo).call(email: '   ', password: 'rahasia123');

    expect(result.failure, isA<AuthFailure>());
    expect(result.failure!.message, 'Email wajib diisi');
    expect(repo.loginCalls, 0);
  });

  test('kata sandi pendek ditolak sebelum menyentuh repository', () async {
    final repo = FakeAuthRepository();
    final result = await Login(repo).call(email: 'a@b.c', password: '123');

    expect(result.failure!.message, 'Kata sandi minimal 6 karakter');
    expect(repo.loginCalls, 0);
  });

  test('input valid diteruskan ke repository dan mengembalikan sesi', () async {
    final repo = FakeAuthRepository();
    final result = await Login(
      repo,
    ).call(email: ' mahasiswa@polinema.ac.id ', password: 'rahasia123');

    expect(result.failure, isNull);
    expect(result.session!.access, 'a-mahasiswa@polinema.ac.id');
    expect(repo.loginCalls, 1);
  });

  test('failure repository diteruskan tanpa melempar', () async {
    final repo = FakeAuthRepository(fail: true);
    final result = await Login(
      repo,
    ).call(email: 'a@b.c', password: 'rahasia123');

    expect(result.session, isNull);
    expect(result.failure!.message, 'kredensial ditolak server');
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:week4_api/data/models/comment.dart';

void main() {
  test('Comment.fromJson memakai nilai default saat field hilang', () {
    // JSON tidak lengkap harus tetap menghasilkan model yang valid.
    final comment = Comment.fromJson({'id': 7, 'email': 'user@example.com'});

    // Field yang tersedia dipertahankan, sedangkan field hilang menjadi default.
    expect(comment.id, 7);
    expect(comment.email, 'user@example.com');
    expect(comment.postId, 0);
    expect(comment.name, '');
    expect(comment.body, '');
  });

  test('Comment.fromJson memakai nilai default saat field bernilai null', () {
    // Nilai null eksplisit juga tidak boleh menyebabkan cast error.
    final comment = Comment.fromJson({
      'postId': null,
      'id': null,
      'name': null,
      'email': null,
      'body': null,
    });

    expect(comment.postId, 0);
    expect(comment.id, 0);
    expect(comment.name, '');
    expect(comment.email, '');
    expect(comment.body, '');
  });

  test('Comment.fromJson mengabaikan tipe field yang tidak sesuai', () {
    // Payload malformed tidak boleh membuat parsing model crash.
    final comment = Comment.fromJson({
      'postId': 'bukan angka',
      'id': true,
      'name': 123,
      'email': <String>[],
      'body': Object(),
    });

    expect(comment.postId, 0);
    expect(comment.id, 0);
    expect(comment.name, '');
    expect(comment.email, '');
    expect(comment.body, '');
  });
}
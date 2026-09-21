import 'package:dio/dio.dart';
import '../models/comment.dart';

/// Repository yang menangani komunikasi endpoint komentar.
class CommentRepository {
  /// Repository menerima Dio agar mudah dipakai ulang dan di-test.
  CommentRepository(this._dio);

  final Dio _dio;

  /// Mengambil semua komentar untuk post tertentu.
  Future<List<Comment>> fetchComments(int postId) async {
    // Base URL dan seluruh timeout diwariskan dari Dio client terpusat.
    final response = await _dio.get<List>(
      '/comments',
      queryParameters: {'postId': postId},
    );

    // Data kosong atau item JSON yang tidak berbentuk map diabaikan dengan aman.
    final data = response.data ?? [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(Comment.fromJson)
        .toList();
  }
}
/// Model satu komentar dari JSONPlaceholder.
class Comment {
  /// Membuat objek komentar dengan nilai yang sudah dinormalisasi.
  const Comment({
    required this.postId,
    required this.id,
    required this.name,
    required this.email,
    required this.body,
  });

  /// ID post yang memiliki komentar ini.
  final int postId;

  /// ID unik komentar.
  final int id;

  /// Nama penulis komentar.
  final String name;

  /// Email penulis komentar.
  final String email;

  /// Isi komentar.
  final String body;

  /// Mengubah JSON menjadi Comment dengan fallback aman jika field null/hilang.
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      postId: _readInt(json['postId']),
      id: _readInt(json['id']),
      name: _readString(json['name']),
      email: _readString(json['email']),
      body: _readString(json['body']),
    );
  }

  /// Mengembalikan default jika nilai JSON null atau bukan angka.
  static int _readInt(Object? value) => value is num ? value.toInt() : 0;

  /// Mengembalikan default jika nilai JSON null atau bukan string.
  static String _readString(Object? value) => value is String ? value : '';

  /// Mengubah objek komentar kembali menjadi JSON.
  Map<String, dynamic> toJson() => {
        'postId': postId,
        'id': id,
        'name': name,
        'email': email,
        'body': body,
      };
}
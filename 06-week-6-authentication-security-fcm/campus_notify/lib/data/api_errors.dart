import 'package:dio/dio.dart';

/// Satu tempat pemetaan exception -> pesan yang layak dibaca pengguna.
/// UI hanya menerima string, bukan DioException mentah.
String friendlyError(Object error) {
  if (error is! DioException) {
    return error.toString().replaceFirst('Exception: ', '');
  }
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
      return 'Koneksi lambat. Coba lagi.';
    case DioExceptionType.connectionError:
      return 'Tidak ada koneksi internet.';
    case DioExceptionType.badResponse:
      final code = error.response?.statusCode;
      if (code == 401) return 'Sesi habis. Silakan login ulang.';
      if (code == 403) return 'Akses ditolak.';
      if (code == 404) return 'Data tidak ditemukan.';
      if (code != null && code >= 500) return 'Server sedang bermasalah.';
      return 'Permintaan gagal (${code ?? 'tanpa status'}).';
    case DioExceptionType.cancel:
      return 'Permintaan dibatalkan.';
    case DioExceptionType.badCertificate:
    case DioExceptionType.unknown:
      return 'Terjadi kesalahan jaringan. Coba lagi.';
  }
}

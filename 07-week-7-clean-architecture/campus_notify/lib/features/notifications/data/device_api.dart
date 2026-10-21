import 'package:dio/dio.dart';

/// `POST /devices` menyimpan token perangkat per user.
class DeviceApi {
  const DeviceApi(this._dio);

  final Dio _dio;

  Future<String> register(String token, String platform) async {
    try {
      await _dio.post<dynamic>(
        '/devices',
        data: {'fcm_token': token, 'platform': platform},
      );
      return 'terkirim ke backend';
    } on DioException catch (e) {
      return 'belum terkirim (${_friendly(e)})';
    } catch (e) {
      // Jangan biarkan error tak terduga lolos sebagai unhandled async error
      // di listener token; status di UI tetap terisi.
      return 'belum terkirim (${e.runtimeType})';
    }
  }

  /// Tanpa backend sungguhan, status ini yang ditampilkan di UI.
  String _friendly(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return 'koneksi lambat';
      case DioExceptionType.connectionError:
        return 'tidak ada koneksi';
      case DioExceptionType.badResponse:
        return 'status ${error.response?.statusCode ?? '-'}';
      case DioExceptionType.cancel:
        return 'dibatalkan';
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return 'kesalahan jaringan';
    }
  }
}

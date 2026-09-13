import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

// Mengelola data statistik yang memiliki tiga kemungkinan state:
// loading, error, atau data berhasil.
class StatsNotifier extends AsyncNotifier<List<String>> {
  // Fungsi ini dibuat bisa diinjeksi agar unit test tidak bergantung pada acak.
  final bool Function()? shouldFail;

  // Delay juga bisa dipersingkat saat test, tetapi aplikasi tetap memakai 2 detik.
  final Duration delay;

  // Constructor menerima dependency opsional untuk simulasi kegagalan.
  StatsNotifier({this.shouldFail, this.delay = const Duration(seconds: 2)});

  // build dipanggil otomatis ketika provider pertama kali digunakan.
  @override
  Future<List<String>> build() => _fetchStats();

  // Mengambil data statistik dan mensimulasikan network request.
  Future<List<String>> _fetchStats() async {
    await Future.delayed(delay);

    // Secara normal, 30% request gagal; test dapat mengganti keputusan ini.
    final failureDecision = shouldFail ?? (() => Random().nextDouble() < 0.3);
    if (failureDecision()) {
      throw Exception('Data statistik gagal dimuat');
    }

    // Tiga item ini adalah data yang ditampilkan oleh StatsPage.
    return ['Penjualan: 120', 'Pengguna aktif: 85', 'Pesanan: 42'];
  }

  // Memuat ulang data secara manual dan mengubah state ke loading terlebih dahulu.
  Future<void> retry() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchStats);
  }
}

// Provider ini membuat dan menyediakan satu StatsNotifier untuk aplikasi.
final statsProvider = AsyncNotifierProvider<StatsNotifier, List<String>>(
  StatsNotifier.new,
);

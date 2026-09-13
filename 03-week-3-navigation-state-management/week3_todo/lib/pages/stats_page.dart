import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/stats_provider.dart';

// Halaman yang membaca state statistik dari Riverpod.
class StatsPage extends ConsumerWidget {
  // Constructor const membuat widget lebih efisien saat dibangun ulang.
  const StatsPage({super.key});

  // build menggambar ulang UI setiap kali state provider berubah.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.watch membuat halaman berlangganan pada perubahan statsProvider.
    final statsAsync = ref.watch(statsProvider);

    // Scaffold menyediakan struktur dasar halaman Material.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistik'),
        leading: IconButton(
          tooltip: 'Kembali ke daftar tugas',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      // when memilih tampilan berdasarkan state AsyncValue.
      body: statsAsync.when(
        // Spinner ditampilkan selama data sedang diambil.
        loading: () => const Center(child: CircularProgressIndicator()),
        // Pesan error dan tombol retry ditampilkan jika pengambilan gagal.
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Gagal memuat statistik: $error'),
              FilledButton(
                // invalidate meminta provider menjalankan build kembali.
                onPressed: () => ref.invalidate(statsProvider),
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
        // ListView menampilkan tepat tiga item ketika data berhasil tersedia.
        data: (stats) => ListView.builder(
          itemCount: stats.length,
          itemBuilder: (context, index) => ListTile(
            leading: const Icon(Icons.bar_chart),
            title: Text(stats[index]),
          ),
        ),
      ),
    );
  }
}

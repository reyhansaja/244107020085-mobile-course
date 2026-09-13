import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:week3_todo/providers/stats_provider.dart';

// Menguji perilaku StatsNotifier melalui ProviderContainer.
void main() {
  // Memastikan notifier mengembalikan tiga item saat request berhasil.
  test('menghasilkan tiga statistik saat pengambilan berhasil', () async {
    // Container test memakai notifier dengan hasil yang selalu berhasil.
    final container = ProviderContainer(
      overrides: [
        statsProvider.overrideWith(
          () => StatsNotifier(
            shouldFail: () => false,
            delay: Duration.zero,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    // Membaca future akan menunggu sampai proses build selesai.
    final stats = await container.read(statsProvider.future);

    // Memastikan jumlah dan isi data sesuai kontrak notifier.
    expect(stats, hasLength(3));
    expect(stats, contains('Penjualan: 120'));
    expect(container.read(statsProvider), isA<AsyncData<List<String>>>());
  });

  // Menguji state error dan pemulihan menggunakan retry.
  test('menghasilkan error lalu berhasil setelah retry', () async {
    // Nilai ini diubah setelah kegagalan untuk mensimulasikan server pulih.
    var shouldFail = true;
    final container = ProviderContainer(
      overrides: [
        statsProvider.overrideWith(
          () => StatsNotifier(
            shouldFail: () => shouldFail,
            delay: Duration.zero,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    // Memulai request pertama agar notifier memproses build asynchronous-nya.
    container.read(statsProvider);
    await Future<void>.delayed(Duration.zero);

    // Request pertama harus gagal dan masuk ke state AsyncError.
    expect(container.read(statsProvider).hasError, isTrue);

    // Request berikutnya dibuat berhasil, lalu notifier menjalankan retry.
    shouldFail = false;
    await container.read(statsProvider.notifier).retry();

    // Setelah retry, state harus berisi data dan tetap terdiri dari tiga item.
    final state = container.read(statsProvider);
    expect(state, isA<AsyncData<List<String>>>());
    expect(state.requireValue, hasLength(3));
  });
}

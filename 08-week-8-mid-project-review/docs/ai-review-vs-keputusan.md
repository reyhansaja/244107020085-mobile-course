# Review AI vs keputusan final (Minggu 8)

## Prompt review yang dipakai

```
Review PR Flutter ini sebagai senior Flutter dev.
Konteks: feature-first Clean Architecture (presentation -> domain <- data),
Riverpod, GoRouter, SQLite + Dio.
Fokus: kebenaran, arsitektur, dan test. Abaikan style.
Berikan 5 temuan teratas + level (blocker/saran)
+ alasan + usulan potongan kode perbaikan.
```

Konteks yang ditempel: isi `get_announcements.dart`, `device_api.dart`,
`api_client.dart`, `auth_providers.dart`, dan daftar `test/`. Tanpa token.

## Temuan AI dan keputusan

| # | Temuan AI | Level | Keputusan | Bukti / alasan |
|---|---|---|---|---|
| 1 | Urutan pengumuman tidak deterministik saat `publishedAt` sama karena `List.sort` tidak stabil | blocker | **Terima** | Test `timestamp sama diurutkan stabil berdasarkan id` merah pada kode lama (`['2','1','3']`), hijau setelah tie-break `id`. |
| 2 | `DeviceApi.register` hanya menangkap `DioException`; error lain lolos sebagai unhandled async error di listener token | saran | **Terima** | Ditambah `catch (e)` yang tetap mengisi status UI. Diverifikasi `flutter analyze` bersih. |
| 3 | Pindahkan `api_client.dart` ke `core/network/` agar semua infrastruktur di core | saran | **Tolak** | `core/` dijaga bebas package (grep kedua nol hasil). Memindahkannya melanggar dependency rule Minggu 7 — justru menurunkan nilai. |
| 4 | Tambah test UI untuk pencarian/empty state | blocker | **Terima** | `test/home_empty_state_test.dart` (2 test) lulus. |
| 5 | Tambahkan `intl` untuk format tanggal dan lokalisasi | saran | **Tolak** | `formatDateTime` murni 4 baris sudah cukup; menambah dependency + inisialisasi locale hanya untuk satu format memperbesar risiko tanpa manfaat. |
| 6 | Tambahkan `copyWith`, `==`, `hashCode` di semua entity | saran | **Tolak** | Tidak ada konsumen yang membandingkan entity; 30 baris tambahan tanpa test yang bisa membuktikan manfaat. |

## Verifikasi AI

- Temuan 1 dan 4 dibuktikan dengan test (merah → hijau), bukan dengan percaya
  pada narasi AI.
- Temuan 3 ditolak dengan bukti grep (dependensi terlarang di `core/`).
- Tidak ada temuan gaya (spasi, urutan import) yang diterapkan: itu tugas
  `dart format` + CI, bukan tugas reviewer.

## Bukti mesin

```
flutter analyze                     -> No issues found!
dart format --set-exit-if-changed . -> bersih
flutter test                        -> All tests passed! (19 test)
```

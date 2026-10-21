# 09 — AI-Assisted Development / Vibe Coding

Fitur kecil yang dikerjakan dengan bantuan AI pada project hasil Minggu 7
(`07-week-7-clean-architecture/campus_notify`): **pencarian judul pengumuman +
empty state**. Tidak ada project baru.

## Yang dikerjakan

| Bagian | Lokasi | Peran AI |
|---|---|---|
| Filter case-insensitive, fungsi murni | `lib/features/announcements/domain/usecases/search_announcements.dart` | draf awal (bug: case-sensitive) |
| State query UI | `presentation/providers/announcement_providers.dart` (`searchQueryProvider`, `filteredAnnouncementsProvider`) | draf + refactor |
| UI pencarian + empty state | `presentation/pages/home_page.dart` | tulis manual (kecil, UI project-specific) |
| Test domain + widget | `test/search_announcements_test.dart`, `test/home_empty_state_test.dart` | draf test, diperbaiki |

Alur generate → verify → test → refactor → explain dijalankan penuh; log
mentahnya (prompt, output awal, temuan, keputusan) ada di
[`docs/ai-log.md`](docs/ai-log.md).

## Prompt inti (5 slot)

```
Peran: senior Flutter dev
Konteks: feature-first Clean Architecture, Riverpod, entity Announcement
         (id, title, body, publishedAt), list sudah ada di announcementsProvider
Tugas: tambah pencarian judul + empty state, filter case-insensitive
Batas: jangan ubah arsitektur; filter WAJIB di domain, bukan di widget; maks 80 baris
Output: kode + test sukses & gagal + cara uji
```

## Bukti verifikasi

| Langkah | Hasil |
|---|---|
| Baca tiap baris draf | 1 bug ditemukan (case-sensitive) |
| Cek import domain | `search_announcements.dart` hanya impor entity (bebas Flutter) |
| `flutter analyze` | `No issues found!` |
| Test merah dulu | `Expected: length 2, Actual: []` untuk query `JADWAL` |
| Test setelah perbaikan | `All tests passed!` (19 test total) |
| Uji manual | query kosong, cocok, tidak cocok (empty state) |

## Cara menjalankan

```bash
cd ../07-week-7-clean-architecture/campus_notify
flutter pub get
flutter run -d chrome
flutter analyze && flutter test
```

Login mock: email mengandung `@`, kata sandi ≥ 6 karakter. Di beranda, kolom
"Cari judul pengumuman" ada di bawah kartu status FCM.

## Hasil

- Pencarian bekerja tanpa request baru (filter di memori, satu sumber data).
- Query kosong mengembalikan semua item; query tanpa hasil memunculkan pesan
  yang menyebut query-nya, bukan layar kosong.
- Logika filter 12 baris, diuji tanpa widget; UI hanya membaca state.

# AI log — Minggu 9 (pencarian judul + empty state)

## Prompt 1 (generate)

```
Peran: senior Flutter dev
Konteks: project campus_notify, feature-first
  lib/features/announcements/{domain,data,presentation},
  entity Announcement(id, title, body, publishedAt),
  announcementsProvider (FutureProvider<List<Announcement>>) sudah ada,
  Riverpod 3, tanpa package tambahan.
Tugas: tambah pencarian judul pengumuman + empty state.
Batas: jangan ubah arsitektur; filter harus di domain (fungsi murni),
  bukan di widget; maks 80 baris; jangan menambah dependency.
Output: kode + 3 test case (sukses, tidak cocok, query kosong) + cara uji.
```

Konteks yang ditempel: isi `announcement.dart`, `announcement_providers.dart`,
`home_page.dart`. Tidak menyertakan token/secret apa pun (mock auth, tanpa
`google-services.json`).

## Output awal AI (ringkas)

```dart
// lib/features/announcements/domain/usecases/search_announcements.dart
List<Announcement> filterAnnouncements(List<Announcement> items, String query) {
  final needle = query.trim();
  if (needle.isEmpty) return items;
  return items.where((item) => item.title.contains(needle)).toList();
}
```

plus saran `searchQueryProvider` (Notifier<String>) dan `TextField(onChanged:)`
di `home_page.dart`. Tidak ada import Flutter di file domain — bagian ini benar.

## Halusinasi / bug yang ditemukan (bukti)

**Bug 1 — filter case-sensitive (terbukti lewat test merah).**
Klaim AI: "`contains` sudah cukup untuk pencarian judul."
Cara membuktikan: tulis test `filter abaikan huruf besar/kecil` dengan query
`JADWAL`, jalankan sebelum memperbaiki kode:

```
00:00 +1 -1: filter abaikan huruf besar/kecil [E]
  Expected: an object with length of <2>
    Actual: []
00:00 +3 -1: Some tests failed.
```

Perbaikan: bandingkan `title.toLowerCase()` dengan `query.trim().toLowerCase()`.
Setelah perbaikan: `All tests passed!` (4 test file ini).

**Bug 2 — `ListView` + `TextField` di dalam `children` (draf UI).**
Draf AI menaruh `TextField` sebagai anak `ListView` tanpa `padding` dan memberi
`controller` baru di dalam `build`. Dua masalah: controller dibuat ulang tiap
rebuild (fokus hilang) dan teks tidak pernah dikirim ke state. Perbaikan manual:
tanpa `TextEditingController`, cukup `onChanged` → `searchQueryProvider`.
Diverifikasi dengan widget test (`test/home_empty_state_test.dart`) yang
memaksa query lewat provider, bukan lewat ketikan.

**Bug 3 — empty state generik.**
Draf AI memakai satu teks "Belum ada pengumuman." untuk dua kondisi berbeda.
Ditolak: pengguna perlu tahu bahwa yang kosong adalah **hasil pencarian**.
Diganti pesan yang menyebut query, dibedakan dari daftar yang memang kosong.

## Tabel terima/tolak

| Usulan AI | Keputusan | Alasan + bukti |
|---|---|---|
| `filterAnnouncements` sebagai fungsi murni di `domain/usecases/` | **Terima** | Sesuai dependency rule; bisa diuji tanpa widget (4 test lulus). |
| `searchQueryProvider` (`Notifier<String>`) | **Terima** | State UI tetap di presentation; tidak ada state global baru di luar provider. |
| `filteredAnnouncementsProvider` yang menggabungkan list + query | **Terima + sederhanakan** | AI mengusulkan memanggil `getAnnouncementsProvider` ulang di dalamnya (request dobel). Diganti `whenData` di atas `announcementsProvider` — nol request baru. |
| `contains` case-sensitive | **Tolak** | Test merah: `JADWAL` menghasilkan `[]`. |
| `TextEditingController` di dalam `build` | **Tolak** | Controller dibuat ulang tiap rebuild → fokus input hilang. |
| Satu teks empty state generik | **Tolak** | Tidak membedakan "belum ada data" vs "tidak ada hasil"; UX menyesatkan. |
| Tambah `package:fuzzy` untuk pencarian "lebih pintar" | **Tolak** | Dependency baru untuk kebutuhan yang belum ada; `contains` + lowercase sudah memenuhi acceptance criteria. |
| Tambah `debounce` 300 ms pada query | **Tolak (untuk sekarang)** | Filter berjalan di memori atas 3 item; debounce menambah timer + test time yang tidak memberi manfaat sampai datanya datang dari API. Catat sebagai upgrade saat pindah ke `GET /pengumuman`. |

## Refactor setelah AI

- Filter 12 baris di domain, tanpa import Flutter.
- UI hanya: `TextField(onChanged: ...)` + `when(...)` untuk loading/error/empty.
- `filteredAnnouncementsProvider` menghitung turunan, bukan menyimpan duplikat
  state.

## Verifikasi akhir

```
$ flutter analyze
No issues found!
$ dart format --set-exit-if-changed .
(bersih)
$ flutter test
All tests passed! (19 test)
```

Manual: query kosong → 3 pengumuman; `jadwal` → 2; `JADWAL` → 2;
`zzz-tak-ada` → pesan empty state.

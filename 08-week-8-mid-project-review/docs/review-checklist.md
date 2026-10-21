# Review checklist tengah semester

Review dilakukan pada `07-week-7-clean-architecture/campus_notify` (branch
`feat/clean-architecture`) dengan checklist codelab: 2 temuan kebenaran,
1 temuan arsitektur, 1 temuan test, 1 saran keterbacaan.

## 1. Tiga commit lama ditulis ulang

| Commit lama | Ditulis ulang | Alasan |
|---|---|---|
| `tugas week 5` | `feat(notes): CRUD catatan offline + dirty flag` | Menyebut *apa* dan *di mana*; "tugas" tidak memberi informasi apa pun saat `git log` dibaca. |
| `week 4` | `feat(api): Dio + repository pattern untuk daftar pengumuman` | Menyebut lapisan yang berubah (api) dan hasilnya (repository pattern), bukan nomor minggu saja. |
| `fix bug` | `fix(auth): refresh token sekali sebelum retry request 401` | Menyebut gejala, penyebab, dan batas retry — reviewer tahu apa yang harus diuji. |

Format yang dipakai: `tipe(scope): deskripsi singkat` dengan tipe
`feat|fix|refactor|test|docs|chore`.

## 2. Temuan review

### Temuan 1 — kebenaran (blocker) — **DITERIMA, diperbaiki**

**Observasi.** `GetAnnouncements` mengurutkan dengan
`b.publishedAt.compareTo(a.publishedAt)` saja. `List.sort` di Dart tidak stabil,
jadi dua pengumuman dengan timestamp identik bisa bertukar posisi antar-build.
**Dampak.** Daftar "berkedip" saat rebuild; sulit didemokan, dan urutan
tidak bisa diuji.
**Usulan.** Tie-break deterministik dengan `id`.

```dart
final byDate = b.publishedAt.compareTo(a.publishedAt);
return byDate != 0 ? byDate : a.id.compareTo(b.id);
```

**Bukti.** Test baru `timestamp sama diurutkan stabil berdasarkan id`
(`test/get_announcements_test.dart`) merah pada kode lama dan lulus setelah
perbaikan. Perbaikan masuk ke PR #2 sebelum merge.

### Temuan 2 — kebenaran (saran) — **DITERIMA, diperbaiki**

**Observasi.** `DeviceApi.register` hanya menangkap `DioException`. Error lain
(mis. `TypeError` dari payload tak terduga) lolos keluar dari `onToken` yang
dipanggil di dalam listener stream FCM.
**Dampak.** Pada aplikasi rilis, error itu menjadi unhandled async error dan
status token di UI tidak pernah terisi.
**Usulan.** Tangkap `Object` sebagai jaring terakhir dan tetap kembalikan status.
**Bukti.** Kode: `lib/features/notifications/data/device_api.dart` (blok `catch (e)`);
diverifikasi lewat review kode + `flutter analyze` bersih (tidak ada lint
`avoid_catches_without_on_clauses` di ruleset project).

### Temuan 3 — arsitektur (saran) — **DITOLAK**

**Observasi reviewer.** `api_client.dart` (Dio) tidak berada di `core/`.
**Usulan.** Pindahkan ke `core/network/api_client.dart` agar "semua infrastruktur
di core".
**Alasan penolakan.** `core/` dijaga bebas package (grep kedua: nol import
`package:dio`). Memindahkannya ke `core/` justru **melanggar** dependency rule
yang jadi kriteria penilaian Minggu 7. Posisi `features/notifications/data/`
konsisten: hanya lapisan data yang boleh tahu Dio, dan fitur yang memakainya
adalah notifikasi (registrasi device).
**Bukti.** `grep -rnE "import 'package:(flutter|dio|sqflite|firebase)" lib/features/*/domain lib/core` → kosong.

### Temuan 4 — test (blocker) — **DITERIMA, diperbaiki**

**Observasi.** Belum ada test untuk perilaku UI pencarian (empty state).
**Usulan.** Tambah widget test: query tanpa hasil → teks empty state muncul;
query cocok → item tampil.
**Bukti.** `test/home_empty_state_test.dart` (2 test) lulus.

### Temuan 5 — keterbacaan (saran) — **DITERIMA sebagian**

**Observasi.** `HomePage.build` memuat kartu status FCM, pencarian, dan daftar
dalam satu method sehingga sulit dibaca.
**Usulan.** Pecah menjadi widget terpisah.
**Tindakan.** Kartu status sudah dipisah menjadi `_PushStatusCard`. Daftar dan
pencarian dibiarkan inline karena hanya 20 baris dan memakai `ref` yang sama —
memecahnya menjadi 3 widget menambah 3 file tanpa mengurangi kompleksitas.

## 3. Nilai kesiapan tengah semester

| Kriteria | Nilai | Catatan |
|---|---|---|
| Fondasi arsitektur | 9/10 | dependency rule terbukti lewat grep, bukan klaim |
| Kebersihan mesin | 10/10 | analyze + format + test hijau |
| Disiplin kolaborasi | 4/10 | tanpa remote: tidak ada PR/issue nyata di GitHub, hanya simulasi lokal + template |
| Kelengkapan dokumentasi | 9/10 | README per minggu + docs keputusan |
| Fitur berjalan | 7/10 | auth + guard + deep link terbukti; FCM belum terbukti di perangkat |

Yang harus dikejar paruh kedua: (1) buka PR nyata begitu remote tersedia,
(2) uji FCM di perangkat fisik, (3) pecah pekerjaan menjadi PR < 300 baris
sejak awal, bukan setelah selesai.

## 4. Perintah mesin

```bash
flutter analyze                        # No issues found!
dart format --set-exit-if-changed .    # bersih
flutter test                           # 19 test lulus
```

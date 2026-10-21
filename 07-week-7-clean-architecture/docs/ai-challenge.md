# AI Challenge — Minggu 7 (Clean Architecture)

## Prompt yang dipakai

```
Project Flutter saya: campus_notify (auth + FCM + daftar pengumuman).
Kondisi kini: folder lib/{data, providers, pages, messaging},
repository tercampur dengan implementasi, widget memanggil Dio langsung.
Tugas:
1. Usulkan struktur feature-first Clean Architecture
   (presentation/domain/data) untuk fitur auth + announcements.
2. Untuk tiap file lama, sebutkan tujuan barunya (pindah/pecah/hapus).
3. Tandai bagian yang over-engineering bila diterapkan ke CRUD sederhana,
   dan kapan use case benar-benar dibutuhkan vs repository langsung.
4. Tunjukkan wiring DI dengan Riverpod (tanpa package DI tambahan).
Jelaskan trade-off setiap keputusan.
```

Konteks yang ditempel: daftar file `lib/` Minggu 6, isi
`auth_repository.dart`, `api_client.dart`, `push_service.dart`, dan versi
package dari `pubspec.yaml`. Tanpa token/secret.

## Usulan AI vs keputusan final

| # | Usulan AI | Keputusan | Alasan teknis |
|---|---|---|---|
| 1 | Pisahkan `AuthRepository` (kontrak) di `domain/` dan `AuthRepositoryImpl` di `data/` | **Terima** | Widget/notifier bergantung pada abstraksi; implementasi mock bisa diganti Firebase Auth tanpa menyentuh presentation. |
| 2 | Buat use case untuk **setiap** operasi: `Login`, `Logout`, `RestoreSession`, `RegisterDevice`, `SubscribeTopic`, `UnsubscribeTopic`, `GetAnnouncements`, `GetAnnouncementById` | **Tolak sebagian** | `Logout`/`SubscribeTopic`/`UnsubscribeTopic` hanya satu baris delegasi — tidak ada aturan bisnis yang dilindungi. 8 use case untuk 5 operasi nyata = 5 file upacara. Dipakai: `Login` (validasi) + `GetAnnouncements` (urut + filter). Sisanya repository/notifier langsung. |
| 3 | Taruh `api_client.dart` (Dio) di `core/network/` | **Tolak** | `core/` saya jaga bebas package (grep kedua). Dio di `core/` akan melanggar dependency rule yang saya tetapkan sendiri. Dipindah ke `features/notifications/data/api_client.dart`. |
| 4 | Pakai `Either<Failure, T>` dari `fpdart` | **Tolak** | Butuh dependency baru untuk dua kemungkinan; record Dart `({data, failure})` sudah cukup dan sudah dipakai Minggu 6 sehingga diff refactor lebih kecil. |
| 5 | Pakai `get_it` + `injectable` untuk DI | **Tolak** | Riverpod `Provider` sudah jadi container DI; menambah service locator kedua membuat dua sumber kebenaran wiring. |
| 6 | Simpan `toMap/fromMap` di entity `Announcement` agar "tidak perlu model terpisah" | **Tolak** | Entity akan bergantung pada bentuk JSON; kalau API berubah, domain ikut berubah. Mapping tetap di `AnnouncementModel`. |
| 7 | `announcementByIdProvider` (family provider) untuk halaman detail | **Terima + sederhanakan** | Disepakati detail butuh data per id, tetapi family provider menambah satu provider untuk data yang sudah dimuat. Halaman detail membaca `announcementsProvider` lalu memfilter — nol state baru, nol request baru. |
| 8 | State error auth dilempar sebagai `Exception(result.failure.message)` | **Tolak** | Melempar exception menghapus tipe `Failure`; UI jadi harus mem-parsing string. Diganti `AsyncError<bool>(failure, ...)` sehingga UI membaca `failure.message` lewat `authErrorMessage`. |

## Bukti verifikasi

```
$ grep -rnE "Dio\(|openDatabase|getDatabasesPath|FlutterSecureStorage|SharedPreferences\.getInstance|jsonDecode" lib/features/*/presentation
(kosong, exit 1)

$ grep -rnE "import 'package:(flutter|dio|sqflite|firebase)" lib/features/*/domain lib/core
(kosong, exit 1)

$ grep -rnE "RepositoryImpl\(|TokenStore\(" lib/features/*/presentation
lib/features/announcements/presentation/providers/announcement_providers.dart:10
lib/features/auth/presentation/providers/auth_providers.dart:11
lib/features/auth/presentation/providers/auth_providers.dart:14
(semuanya provider wiring, nol di pages/)

$ flutter analyze  -> No issues found!
$ flutter test     -> 12 tests passed
```

## Biaya over-engineering yang saya hindari

Batch use case (usulan 2) akan menambah ~6 file dan ~120 baris tanpa satu pun
test baru yang bermakna. Biaya nyatanya bukan ukuran repo, tetapi beban
membaca: setiap perubahan kecil harus melewati 3 lapisan delegasi. Use case
baru layak ditambahkan ketika operasi menggabungkan >1 repository atau punya
aturan yang bisa salah (mis. `SyncNotes`, `RefreshSession` dengan batas retry).

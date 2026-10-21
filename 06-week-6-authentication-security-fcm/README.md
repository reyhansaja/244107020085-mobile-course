# 06 — Authentication, Security & FCM (Campus Notification App)

Project Flutter untuk codelab Minggu 6: autentikasi, penyimpanan token yang aman,
refresh token otomatis, dan integrasi Firebase Cloud Messaging (FCM) untuk
notifikasi pengumuman kampus.

## Tujuan

- Login dengan guard rute: pengguna yang belum login selalu diarahkan ke `/login`.
- Access token + refresh token hanya disimpan lewat `TokenStore`
  (`flutter_secure_storage`), tidak pernah di `SharedPreferences` atau log.
- Dio me-refresh token **satu kali** saat menerima 401 lalu mengulang request;
  bila refresh ikut mati, sesi dibersihkan dan pengguna dipaksa login ulang.
- FCM: izin notifikasi, token perangkat + listener pembaruan token, langganan
  topik `pengumuman-kampus`, dan deep link `/pengumuman/:id` dari ketiga app
  state (foreground / background / terminated).

## Fitur utama

| Fitur | Berkas |
|---|---|
| Penyimpanan token aman | `lib/data/token_store.dart` |
| Mock auth + JWT simulasi (titik migrasi Firebase Auth) | `lib/data/auth_repository.dart` |
| Dio + interceptor refresh-once | `lib/data/api_client.dart` |
| Pemetaan error ke pesan pengguna | `lib/data/api_errors.dart` |
| State login (Riverpod `AsyncNotifier`) | `lib/providers/auth_provider.dart` |
| Router + guard `redirect` | `lib/providers/router_provider.dart`, `lib/routes.dart` |
| FCM: permission, token, topik, deep link | `lib/messaging/firebase_push_service.dart` |
| Parsing payload murni (bisa diuji tanpa Firebase) | `lib/messaging/route_parser.dart` |
| UI | `lib/pages/login_page.dart`, `home_page.dart`, `announcement_page.dart` |
| Test | `test/auth_push_test.dart` |

## Stack

- Flutter 3.44.4 / Dart 3.12.2
- `flutter_riverpod` 3.x, `go_router` 18.x, `dio` 5.x
- `flutter_secure_storage` 11.x
- `firebase_core` 5.x, `firebase_messaging` 17.x, `flutter_local_notifications` 22.x

## Struktur

```
lib/
├── main.dart                    # Firebase init + wiring push
├── routes.dart                  # konstanta rute (dipakai GoRouter & FCM)
├── data/
│   ├── api_client.dart          # Dio + refresh-once interceptor
│   ├── api_errors.dart          # DioException -> pesan pengguna
│   ├── auth_repository.dart     # mock auth + refresh
│   ├── announcement_repository.dart
│   ├── device_repository.dart   # POST /devices (token perangkat)
│   └── token_store.dart         # secure storage
├── providers/
│   ├── auth_provider.dart       # DI + AuthNotifier
│   └── router_provider.dart     # GoRouter + guard
├── messaging/
│   ├── push_service.dart        # kontrak + noop (tanpa Firebase)
│   ├── firebase_push_service.dart
│   └── route_parser.dart
└── pages/
    ├── login_page.dart
    ├── home_page.dart
    └── announcement_page.dart
```

## Cara menjalankan

```bash
cd campus_notify
flutter pub get
flutter run -d chrome     # demo UI tanpa Firebase (mode mock)
flutter run -d <device>   # Android + FCM penuh (butuh langkah di bawah)
flutter analyze
flutter test
```

Login mock: email apa pun yang mengandung `@` dan kata sandi minimal 6 karakter.

### Mengaktifkan FCM (Android)

1. Buat project di Firebase Console, tambahkan aplikasi Android dengan
   `applicationId` = `id.polinema.campus_notify`.
2. Unduh `google-services.json` ke `android/app/`.
3. Terapkan plugin Gradle `com.google.android.gms:google-services` mengikuti
   [panduan FCM Flutter](https://firebase.google.com/docs/cloud-messaging/flutter/client).
4. `flutter run` ulang (hot reload tidak cukup untuk plugin baru).

Selama `google-services.json` belum ada, `FirebaseBootstrap.init()` gagal dengan
anggun dan aplikasi memakai `NoopPushService` — tidak ada crash dan tidak ada
secret yang di-hardcode.

## Rencana uji tiga app state

Payload yang dipakai (FCM HTTP v1, gabungan `notification` + `data`):

```json
{
  "message": {
    "topic": "pengumuman-kampus",
    "notification": { "title": "Jadwal kuliah berubah", "body": "Kelas Mobile pindah ke Ruang A2 jam 13.00" },
    "data": { "route": "/pengumuman/3", "id": "3" }
  }
}
```

| State | Yang diharapkan | Cara uji | Status |
|---|---|---|---|
| Foreground | Banner lokal muncul (sistem tidak menampilkan otomatis), klik masuk `/pengumuman/3` | Aplikasi terbuka, kirim dari Firebase Console | perlu perangkat + project Firebase |
| Background | Banner sistem muncul, klik membuka rute yang benar | Tekan Home, kirim, klik banner | perlu perangkat + project Firebase |
| Terminated | Aplikasi terbuka langsung ke rute yang benar via `getInitialMessage` | Swipe-close, kirim, klik banner | perlu perangkat + project Firebase |

Deep link bisa dibuktikan tanpa FCM di web: buka `http://localhost:8099/index.html#/pengumuman/3`
setelah login — halaman detail #3 tampil lewat rute yang sama dengan
`data.route` (lihat `screenshots/04-deeplink-pengumuman-3.png`). Parsing
payload-nya diuji unit test.

## Hasil verifikasi

```
flutter analyze  -> No issues found!
flutter test     -> 13 tests passed
flutter build web --release -> sukses
```

Aplikasi dijalankan nyata di Chrome (build web, bukan mockup). Bukti di
`screenshots/`:

| File | Isi |
|---|---|
| `01-login.png` | Login form: email, kata sandi, tombol Masuk |
| `02-home.png` | Beranda setelah login: kartu status FCM + 3 pengumuman |
| `03-detail.png` | Detail `/pengumuman/1` (judul, ID, tanggal, isi) |
| `04-deeplink-pengumuman-3.png` | Buka langsung `#/pengumuman/3` (reload penuh): sesi dipulihkan dari secure storage, guard meloloskan, halaman detail #3 tampil — jalur yang sama dipakai payload FCM `data.route` |
| `05-after-logout-login.png` | Setelah logout: URL `#/login`, form login tampil (guard bekerja) |

Yang **belum** bisa diuji di environment ini: banner FCM riil pada Android.
Environment tidak punya emulator/perangkat dan project Firebase, jadi tiga baris
tabel uji di atas masih "perlu perangkat". Handler ketiga state sudah ada dan
logika parsing-nya lulus test.

## Catatan versi penting

`firebase_messaging` 17 menandai `getToken()` dan `onTokenRefresh` sebagai
**deprecated**, digantikan `register()` + `onRegistered` (nilainya adalah
Firebase Installation ID untuk direct-send). Kode memakai API baru, dengan
`getToken()` sebagai fallback satu kali agar token saat ini tetap terkirim.
Detail keputusan: `docs/ai-challenge.md`.

## AI Challenge

Prompt, output awal AI, temuan yang diterima/ditolak, dan verifikasinya ada di
[`docs/ai-challenge.md`](docs/ai-challenge.md).

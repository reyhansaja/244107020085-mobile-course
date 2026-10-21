# AI Challenge — Minggu 6 (Authentication, Security & FCM)

## Prompt yang dipakai

```
Aplikasi Flutter Campus Notification App.
Stack: firebase_messaging, flutter_local_notifications,
flutter_secure_storage, go_router, Riverpod.
Buatkan PushService dengan:
- requestPermission + getToken + onTokenRefresh (kirim ke POST /devices)
- onMessage (tampilkan local notification manual)
- onMessageOpenedApp + getInitialMessage (navigasi ke data.route)
- subscribe/unsubscribe topic pengumuman-kampus
- background handler top-level dengan @pragma('vm:entry-point')
Tandai bagian yang BERBEDA untuk Android 13+ vs iOS,
dan bagian yang tidak boleh mengakses BuildContext.
```

Konteks yang ditempel ke AI: struktur `lib/`, versi package dari `pubspec.yaml`
(`firebase_messaging` 17.0.0, `flutter_local_notifications` 22.3.2,
`flutter_riverpod` 3.4.3), kontrak `TokenStore`, dan `AppRoutes`.
Tidak ada token, API key, atau `google-services.json` yang ditempel.

## Verifikasi terhadap output AI

| # | Klaim / usulan AI | Keputusan | Bukti |
|---|---|---|---|
| 1 | Background handler harus `@pragma('vm:entry-point')` dan top-level | **Terima** | `firebaseMessagingBackgroundHandler` berupa fungsi top-level di `lib/messaging/firebase_push_service.dart`; dokumentasi Firebase mensyaratkan isolate terpisah, jadi tidak boleh menyentuh Riverpod/`BuildContext`. |
| 2 | `Future<void> initialize(InitializationSettings(...))` (posisional) | **Tolak, tulis manual** | API nyata `flutter_local_notifications` 22.3.2: `initialize({required InitializationSettings settings, ...})` — parameter bernama. Diverifikasi di `~/.pub-cache/.../flutter_local_notifications-22.3.2/lib/src/flutter_local_notifications_plugin.dart:111`. Kalau diterima mentah, kode tidak compile. |
| 3 | `_local.show(id, title, body, details, payload:)` (posisional) | **Tolak, tulis manual** | Versi 22 memakai named parameter: `show({required int id, String? title, ...})`. Terbukti dari error analyzer saat draf awal dipakai. |
| 4 | `getToken()` + `onTokenRefresh` (sesuai teks codelab) | **Terima + refactor** | Analyzer menandai keduanya `deprecated_member_use` di `firebase_messaging` 17. Diganti `register()` + `onRegistered`, dengan `getToken()` disisakan sebagai fallback satu kali. Alasan: analyze wajib bersih, dan nilai token saat ini tetap harus terkirim ke backend. |
| 5 | `FirebaseMessaging.onBackgroundMessage` dipanggil di `main()` sebelum `Firebase.initializeApp()` | **Tolak** | Handler didaftarkan setelah `initializeApp()` sukses; kalau didaftarkan sebelum Firebase siap, exception pada startup (tanpa `google-services.json` aplikasi malah mati total). |
| 6 | Interceptor refresh tanpa penanda retry | **Tolak** | Tanpa `extra['retried'] = true`, 401 berulang memicu loop refresh tak berujung. Ditambahkan penanda + `store.clear()` saat refresh gagal. |
| 7 | Saran `SharedPreferences` untuk menyimpan token karena "lebih simpel" | **Tolak** | Refresh token adalah kredensial jangka panjang; `SharedPreferences` tidak terenkripsi dan bisa dibaca di perangkat root/backup. Codelab juga melarang. Token hanya lewat `TokenStore` (`flutter_secure_storage`). |
| 8 | Token di-log penuh untuk debugging (`debugPrint(token)`) | **Tolak** | Melanggar aturan "tidak log token". UI hanya menampilkan token terpotong (`_mask`), log hanya mencatat rute/error. |
| 9 | `dart:io` `Platform.isAndroid` untuk cek platform | **Tolak** | `dart:io` tidak tersedia di web, sedangkan project ini dibangun juga untuk web (`flutter build web`). Diganti `defaultTargetPlatform`. |

## Refactor setelah verifikasi

1. Semua string rute dipindah ke `lib/routes.dart` sehingga deep link FCM dan
   GoRouter memakai konstanta yang sama.
2. `routeFromMessage` / `announcementIdFromMessage` dipisah ke
   `lib/messaging/route_parser.dart` sebagai fungsi murni, diuji tanpa Firebase.
3. `DioException -> pesan pengguna` dipindah ke `lib/data/api_errors.dart`; UI
   tidak pernah menerima exception mentah.
4. Push dibungkus kontrak `PushService` (`push_service.dart`) + `NoopPushService`
   agar aplikasi tetap jalan tanpa konfigurasi Firebase.

## Kesimpulan

Draf AI berguna untuk kerangka (permission, topik, urutan handler), tetapi tiga
bagian paling berisiko — tanda tangan API notification, deprecation token FCM,
dan penanganan platform web — semuanya salah pada draf awal. Semua sudah
diperbaiki dan dibuktikan lewat `flutter analyze` + `flutter test`.

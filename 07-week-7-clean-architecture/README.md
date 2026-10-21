# 07 — Clean Architecture (refactor `campus_notify`)

Refactor project Minggu 6 (`06-week-6-authentication-security-fcm/campus_notify`)
menjadi struktur **feature-first** dengan tiga layer. Tidak ada fitur baru:
perilaku aplikasi identik dengan sebelum refactor.

## Arah dependensi

```
presentation  (widget, provider, router)
      |
      v  bergantung ke
   domain     (entity, kontrak repository, use case, failure)
      ^
      |  diimplementasikan oleh
    data      (model, repository impl, secure storage, Dio, Firebase)
```

Aturan emas: **dependensi hanya mengarah ke dalam**. `domain/` dan `core/`
tidak mengimpor Flutter, Dio, sqflite, atau Firebase — dibuktikan grep di
bawah, dan itulah alasan use case bisa diuji tanpa database/jaringan.

## Struktur

```
lib/
├── main.dart                  # bootstrap Firebase + wiring push
├── routes.dart                # AppRoutes + GoRouter + guard redirect
├── core/                      # murni Dart, tanpa framework
│   ├── failures.dart          # sealed Failure: Local/Network/Auth
│   ├── format.dart            # formatDateTime (pure)
│   └── push_route.dart        # routeFromMessage, announcementIdFromMessage
└── features/
    ├── auth/
    │   ├── domain/
    │   │   ├── entities/auth_session.dart
    │   │   ├── repositories/auth_repository.dart   # KONTRAK
    │   │   └── usecases/login.dart                 # validasi + Login
    │   ├── data/
    │   │   ├── token_store.dart                    # secure storage
    │   │   └── auth_repository_impl.dart           # mock -> titik migrasi
    │   └── presentation/
    │       ├── providers/auth_providers.dart       # DI + AuthNotifier
    │       └── pages/login_page.dart
    ├── announcements/
    │   ├── domain/
    │   │   ├── entities/announcement.dart
    │   │   ├── repositories/announcement_repository.dart
    │   │   └── usecases/get_announcements.dart     # urut + buang judul kosong
    │   ├── data/
    │   │   ├── models/announcement_model.dart      # mapping JSON di sini
    │   │   └── repositories/announcement_repository_impl.dart
    │   └── presentation/
    │       ├── providers/announcement_providers.dart
    │       └── pages/{home_page,announcement_page}.dart
    └── notifications/
        ├── domain/repositories/push_repository.dart
        ├── data/
        │   ├── push_service_firebase.dart          # + FirebaseBootstrap
        │   ├── push_service_noop.dart
        │   ├── api_client.dart                     # Dio + refresh-once
        │   └── device_api.dart                     # POST /devices
        └── presentation/providers/push_providers.dart
```

## Peta file lama → tujuan baru

| File Minggu 6 | Tujuan minggu 7 | Tindakan |
|---|---|---|
| `lib/data/token_store.dart` | `features/auth/data/token_store.dart` | pindah (layer data) |
| `lib/data/auth_repository.dart` | `domain/repositories/auth_repository.dart` (kontrak) + `data/auth_repository_impl.dart` (mock) | **pecah** — interface dan implementasi dipisah |
| `lib/data/api_client.dart` | `features/notifications/data/api_client.dart` | pindah; interceptor memakai kontrak auth, bukan `TokenStore` langsung |
| `lib/data/api_errors.dart` | dihapus | kegagalan jadi `Failure` di domain/`DeviceApi`; UI hanya baca `message` |
| `lib/data/announcement_repository.dart` | `domain/entities` + `domain/repositories` + `data/models` + `data/repositories` | **pecah** 4 file |
| `lib/data/device_repository.dart` | `features/notifications/data/device_api.dart` | pindah + hanya melempar pesan, bukan exception |
| `lib/providers/auth_provider.dart` | `features/auth/presentation/providers/auth_providers.dart` + `routes.dart` | provider tetap, router dipindah ke `routes.dart` |
| `lib/messaging/route_parser.dart` | `core/push_route.dart` | pindah (fungsi murni, dipakai domain & presentation) |
| `lib/messaging/push_service.dart` | `features/notifications/domain/repositories/push_repository.dart` + `data/push_service_noop.dart` | **pecah** kontrak vs implementasi |
| `lib/messaging/firebase_push_service.dart` | `features/notifications/data/push_service_firebase.dart` | pindah (layer data) |
| `lib/pages/*.dart` | `features/*/presentation/pages/*.dart` | pindah per fitur |
| `lib/routes.dart` | `routes.dart` (root) | tetap; ditambah `routerProvider` |

## Keputusan arsitektur (dan yang sengaja **tidak** dibuat)

1. **Use case hanya di tempat yang punya aturan bisnis.** `Login` (validasi
   input) dan `GetAnnouncements` (urut terbaru + buang judul kosong) berhak jadi
   use case. `logout()` satu baris dan `subscribe(topic)` tidak dibuatkan use
   case — itu upacara tanpa nilai; provider memanggil repository langsung.
2. **Tidak ada use case per CRUD.** Untuk fitur sekecil ini, `GetAnnouncements`
   → `Notifier` langsung sudah cukup; menambah `GetAnnouncementById`,
   `SortAnnouncements`, `FilterAnnouncements` akan menambah 3 file tanpa
   mengurangi risiko bug.
3. **Record `({data, failure})` sebagai hasil**, bukan `Either` dari package
   tambahan. Tidak ada dependency baru (fpdart/dartz) hanya untuk dua nilai.
4. **Entity tanpa mapping.** `toMap`/`fromMap` hanya ada di
   `AnnouncementModel`; entity tetap class biasa tanpa import apa pun.
5. **Tidak ada package DI** (`get_it`, `injectable`). Riverpod `Provider` sudah
   jadi container DI; wiring terpusat di `presentation/providers/*`.
6. **`api_client.dart` diletakkan di `features/notifications/data/`**, bukan
   `core/`, karena `core/` dijaga bebas package. Ini konsekuensi dependency
   rule yang saya pilih sadar: lebih baik satu file "miring" di data daripada
   mengotori `core/` dengan Dio.
7. **Tidak semua fitur dipaksa punya use case/entity baru.** `notifications`
   hanya punya kontrak + dua implementasi + provider; ia tidak punya state
   bisnis sendiri.

## Verifikasi dependency rule

```bash
# 1. Presentation steril dari akses data mentah (harus NOL hasil)
grep -rnE "Dio\(|openDatabase|getDatabasesPath|FlutterSecureStorage|SharedPreferences\.getInstance|jsonDecode" lib/features/*/presentation
# -> tidak ada hasil (exit 1)

# 2. Domain + core steril dari framework/package (harus NOL hasil)
grep -rnE "import 'package:(flutter|dio|sqflite|firebase)" lib/features/*/domain lib/core
# -> tidak ada hasil (exit 1)

# 3. Tidak ada instansiasi repository di luar provider DI
grep -rnE "RepositoryImpl\(|TokenStore\(" lib/features/*/presentation
# -> hanya 3 baris, semuanya di *providers* (wiring DI), nol di pages/
```

## Hasil mesin

```
flutter analyze                   -> No issues found!
flutter test                      -> 12 tests passed
dart format --set-exit-if-changed -> bersih
```

Test domain murni (tanpa SQLite/Dio/Firebase):

- `test/get_announcements_test.dart` — fake repository: urutan terbaru, judul
  kosong dibuang, failure diteruskan tanpa exception.
- `test/login_usecase_test.dart` — fake `AuthRepository`: validasi berhenti
  sebelum repository, input valid diteruskan, failure diteruskan.
- `test/push_route_test.dart` — parsing payload + `formatDateTime`.

## Perilaku identik (before/after)

Screenshot UI sebelum refactor ada di
`../06-week-6-authentication-security-fcm/screenshots/`, sesudah refactor di
`screenshots/` folder ini: login, beranda (kartu FCM + daftar pengumuman),
detail pengumuman, deep link `/pengumuman/3`, dan redirect ke login setelah
logout.

## Cara menjalankan

```bash
cd campus_notify
flutter pub get
flutter run -d chrome      # mode mock (tanpa Firebase)
flutter analyze && flutter test
```

## AI Challenge

Prompt, tabel usulan-vs-keputusan, dan bukti grep: [`docs/ai-challenge.md`](docs/ai-challenge.md).

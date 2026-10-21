# 244107020085 — Mobile Programming Portfolio

Portfolio praktikum Pemrograman Mobile (JTI Polinema), Flutter.
Codelab acuan: <https://jti-polinema.github.io/flutter-codelab/>

| Minggu | Folder | Isi | Status |
|---|---|---|---|
| 1 | `01-week-1-mobile-development-ecosystem-flutter-refresh/` | Ecosystem + Dart refresh, profil app | selesai |
| 2 | `02-week-2-declarative-ui-responsive-design/` | Declarative UI + responsive layout | selesai |
| 3 | `03-week-3-navigation-state-management/` | Navigasi + Riverpod | selesai |
| 4 | `04-week-4-networking-rest-api/` | Dio, JSON, repository | selesai |
| 5 | `05-week-5-local-storage-offline-first/` | SharedPreferences + sqflite, offline-first | selesai |
| 6 | `06-week-6-authentication-security-fcm/` | Auth mock, secure storage, refresh-once, FCM | selesai (FCM perlu perangkat) |
| 7 | `07-week-7-clean-architecture/` | Refactor feature-first: domain/data/presentation | selesai |
| 8 | `08-week-8-mid-project-review/` | Git Flow, review checklist, CI | selesai (PR simulasi lokal) |
| 9 | `09-week-9-ai-assisted-development/` | Search + empty state dengan AI, log verifikasi | selesai |

Project yang berjalan (dua terakhir):

```bash
cd 07-week-7-clean-architecture/campus_notify
flutter pub get
flutter run -d chrome      # mode mock, tanpa Firebase
flutter analyze && flutter test
```

## Alur kerja

- `main` selalu bisa dirilis; kerja harian di `feature/*` / `docs/*`.
- PR kecil (< 300 baris), commit Conventional Commits, CI di
  `.github/workflows/ci.yml` menolak PR yang tidak lolos
  `dart format` + `flutter analyze` + `flutter test`.
- Setiap keputusan teknis yang menyimpang dari saran AI dicatat di
  `docs/ai-challenge.md` / `docs/ai-log.md` beserta buktinya.

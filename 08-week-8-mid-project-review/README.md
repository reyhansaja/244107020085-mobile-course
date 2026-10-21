# 08 — Mid Project Review & Code Review

Review tengah semester atas project `07-week-7-clean-architecture/campus_notify`
(hasil refactor Clean Architecture dari `campus_notify` Minggu 6). Codelab ini
tidak membuat fitur baru: yang dinilai adalah disiplin branch/commit/PR,
kebersihan mesin (analyze + format + test), dan tindak lanjut review.

## Status paruh semester

| Aspek | Status | Bukti |
|---|---|---|
| Struktur feature-first (auth, announcements, notifications) | selesai | `lib/features/*/{domain,data,presentation}` |
| Dependency rule | lulus | tiga grep sterilitas nol hasil di `README` Minggu 7 |
| `flutter analyze` | bersih | `No issues found!` |
| `dart format --set-exit-if-changed .` | bersih | dijalankan sebelum commit |
| `flutter test` | hijau | 19 test (domain + widget) |
| README + cara menjalankan | ada | README Minggu 6, 7, 8, 9 |
| FCM diuji di perangkat | **belum** | tidak ada emulator/perangkat + project Firebase di environment ini; lihat `06-.../README.md` |
| CI menolak PR kotor | siap | `.github/workflows/ci.yml` |

## Branching model yang dipakai

```
main      -> selalu bisa dirilis, tidak di-commit langsung
develop   -> integrasi fitur mingguan (target PR)
feature/* -> kerja satu fitur, umur < 3 hari
```

Alur yang dijalankan saat mengerjakan repo ini:

```bash
git checkout main
git checkout -b develop          # sekali saja
git checkout -b feat/clean-architecture
# ...kerja + commit...
git checkout develop && git merge --no-ff feat/clean-architecture
git checkout -b docs/mid-review
# ...dokumen review + CI...
git checkout develop && git merge --no-ff docs/mid-review
```

Catatan kejujuran: repository ini dikerjakan seorang diri tanpa remote GitHub
aktif, jadi Pull Request **tidak** dibuka di github.com. Sebagai gantinya:
template PR, deskripsi PR, dan hasil review disimpan di `docs/` dan riwayat
merge `--no-ff` di atas membuktikan alur branch → review → merge. Bila repo
di-push ke GitHub, `docs/pr-body.md` bisa langsung dipakai sebagai isi PR.

## Commit sebelum/sesudah

Lihat `docs/review-checklist.md` untuk tabel penulisan ulang 3 commit buruk
menjadi format Conventional Commits beserta alasannya.

## Review sejawat (mandiri, dengan checklist)

Karena tidak ada pasangan reviewer, review dilakukan dengan checklist yang sama
yang diminta codelab (2 temuan kebenaran, 1 arsitektur, 1 test, 1 keterbacaan).
Hasil lengkap: `docs/review-checklist.md`. Dua temuan **benar** sudah diperbaiki
dan dibuktikan test; satu usulan **ditolak** dengan alasan tertulis.

## Mesin hijau

```
$ flutter analyze
No issues found!
$ dart format --set-exit-if-changed .
(bersih)
$ flutter test
All tests passed!   (19 test)
```

## Review AI vs keputusan

Prompt reviewer, temuan AI, tabel usulan-vs-keputusan, dan bukti penolakan:
`docs/ai-review-vs-keputusan.md`.

## Peta issue / PR

| ID | Judul | Branch | Status |
|---|---|---|---|
| #1 | Autentikasi + FCM (Minggu 6) | `feat/auth-fcm` | merged ke `develop` |
| #2 | Refactor feature-first Clean Architecture (termasuk 2 perbaikan hasil review) | `feat/clean-architecture` | merged |
| #3 | Review tengah semester + CI | `docs/mid-review` | merged |
| #4 | Pencarian judul + empty state (Minggu 9) | `feat/ai-search` | merged |

Karena repo dikerjakan tanpa remote, dua temuan review (urutan tidak stabil,
`catch` non-Dio) diperbaiki **di dalam PR #2 sebelum merge**, bukan sebagai PR
terpisah — jejaknya ada di pesan commit PR #2 dan di test yang menyertainya.

## Cara menjalankan

```bash
cd ../07-week-7-clean-architecture/campus_notify
flutter pub get
flutter run -d chrome
flutter analyze && flutter test
```

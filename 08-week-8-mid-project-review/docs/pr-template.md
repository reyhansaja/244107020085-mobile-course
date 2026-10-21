# Template Pull Request

## Judul
`feat(scope): ringkasan satu fitur`

## Masalah
<!-- Apa yang salah/kurang, dampaknya ke pengguna. Sertakan issue: Closes #12 -->

## Solusi
<!-- Perubahan apa yang dilakukan dan mengapa pendekatan itu dipilih -->

## Cara uji
1.
2.
```bash
flutter analyze
flutter test
```

## Bukti
<!-- Screenshot before/after, atau output test yang relevan -->

## Checklist
- [ ] `flutter analyze` bersih
- [ ] `dart format --set-exit-if-changed .` bersih
- [ ] `flutter test` hijau
- [ ] Diff < 300 baris, satu fitur
- [ ] Dependency rule utuh (grep sterilitas nol hasil)
- [ ] Issue tertutup via `Closes #id`

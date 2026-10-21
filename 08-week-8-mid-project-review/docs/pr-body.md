# PR body — `feat(search-announcements)`

Judul: `feat(announcements): pencarian judul + empty state`

Masalah: daftar pengumuman hanya bisa digulir; tidak ada cara menemukan
pengumuman tertentu, dan daftar kosong tidak menjelaskan apa pun ke pengguna.

Solusi:
- Fungsi murni `filterAnnouncements(items, query)` di `domain/usecases/`
  (case-insensitive, query kosong = semua item).
- `searchQueryProvider` menyimpan state query di presentation;
  `filteredAnnouncementsProvider` menggabungkan `announcementsProvider` +
  query tanpa request baru.
- Empty state membedakan "belum ada pengumuman" dari "tidak ada yang cocok
  dengan query".
- Widget tidak memanggil logika filter sendiri; filter diuji di domain.

Cara uji:
1. Buka beranda, ketik `jadwal` → 2 item.
2. Ketik `JADWAL` → hasil sama (case-insensitive).
3. Ketik `zzz-tak-ada` → "Tidak ada pengumuman yang cocok dengan "zzz-tak-ada"."

```bash
flutter analyze   # No issues found!
flutter test      # All tests passed! (19 test)
```

Bukti: `screenshots/search-empty-after.png` (menyusul pada commit yang sama
dengan capture).

Closes #4

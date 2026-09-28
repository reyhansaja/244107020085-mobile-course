# week5_offline_notes

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:


For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# Offline Notes

## Penyimpanan

- `SharedPreferences` menyimpan preferensi tema dan waktu terakhir aplikasi dibuka.
- `sqflite` menyimpan catatan secara persisten melalui `NoteRepository`.
- Daftar catatan selalu mengambil data dari SQLite dan diurutkan berdasarkan `updated_at DESC`.
- Riverpod mengelola repository dan invalidasi ulang daftar setelah operasi tambah atau hapus.

## Offline-first

Data bacaan menggunakan strategi cache-first melalui `SyncService.cacheFirstPosts`: cache SQLite dibaca lebih dahulu; sumber remote hanya dipanggil ketika cache kosong, lalu hasil remote disimpan ke cache.

Catatan baru ditandai `dirty = 1`. `SyncService.syncNotes` mengirim setiap catatan dirty melalui callback remote dan hanya mengubahnya menjadi `dirty = 0` setelah pengiriman berhasil. Jika pengiriman gagal, exception diteruskan dan catatan tetap dirty untuk percobaan berikutnya.

## Aturan konflik

Strategi konflik yang digunakan adalah **last-write-wins berdasarkan `updated_at`**. Saat server diintegrasikan, client mengirim `updated_at`; server mempertahankan versi dengan timestamp paling baru dan mengembalikan versi pemenang. Versi server yang lebih baru menggantikan salinan lokal, sedangkan versi lokal yang lebih baru dikirim ulang. Penghapusan harus memakai tombstone atau status deleted agar tidak muncul kembali saat sinkronisasi berikutnya.

Implementasi saat ini menyediakan antrean dirty dan callback push, tetapi belum memanggil server nyata. Callback remote bertanggung jawab menerapkan aturan timestamp tersebut.

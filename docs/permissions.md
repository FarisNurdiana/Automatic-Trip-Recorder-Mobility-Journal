# Permission Android & iOS

Aplikasi meminta permission **bertahap** dengan penjelasan sebelum setiap
permintaan (onboarding), tidak sekaligus. Halaman **Diagnostik Izin**
(Settings → Diagnostik izin) menampilkan status live seluruh permission dan
tombol request ulang / buka pengaturan sistem. Aplikasi tidak pernah mencoba
melewati kebijakan permission Android/iOS.

## Daftar permission dan alasannya

| Permission | Platform | Penjelasan kepada pengguna |
|---|---|---|
| Activity recognition (`ACTIVITY_RECOGNITION`) | Android 10+ | "Digunakan untuk mendeteksi ketika perjalanan menggunakan kendaraan dimulai atau selesai." |
| Motion & Fitness (`NSMotionUsageDescription`) | iOS | "Digunakan untuk mengenali aktivitas seperti berjalan, diam, atau menggunakan kendaraan." |
| Location while in use | Keduanya | "Digunakan untuk merekam rute perjalanan." |
| Background location (`ACCESS_BACKGROUND_LOCATION` / Always) | Keduanya | "Digunakan agar perjalanan tetap direkam ketika layar mati atau aplikasi diminimalkan." |
| Notifications (`POST_NOTIFICATIONS`) | Android 13+ | "Digunakan untuk menunjukkan bahwa perjalanan sedang direkam." |
| Battery optimization exemption | Android (opsional) | "Mencegah sistem menghentikan perekaman di latar belakang." |

## Urutan permintaan (onboarding)

1. Penjelasan aplikasi (tanpa permission).
2. Activity recognition / Motion & Fitness.
3. Location while in use.
4. Background location — **hanya setelah** while-in-use diberikan; di
   Android 11+ sistem membuka halaman Settings ("Allow all the time").
5. Notifications.

Setiap langkah bisa dilewati; fitur yang bergantung pada permission yang
ditolak akan menampilkan pesan yang bisa dipahami, dan perekaman manual tetap
tersedia selama izin lokasi diberikan.

## Format diagnostik

```
Location:                        granted/denied
Background location:             granted/denied
Activity recognition:            granted/denied
Motion & fitness:                granted/denied
Notifications:                   granted/denied
Battery optimization exemption:  active/inactive
```

## Privasi

- Tidak ada data lokasi/sensor yang dikirim sebelum pengguna login **dan**
  menyetujui permission terkait.
- Mode lokal: tidak ada data yang meninggalkan perangkat sama sekali.
- Halaman Privasi menyediakan: matikan deteksi otomatis, matikan sensor
  logging, hapus satu perjalanan, hapus semua data lokal, hapus semua data
  cloud, dan logout (dengan peringatan bila masih ada data belum tersinkron).
- Token autentikasi tidak pernah ditulis ke log.

# Troubleshooting

## Build

**`flutter pub get` gagal resolve.**
Pastikan Flutter stable 3.44.x (`flutter --version`). Jalankan
`flutter clean && flutter pub get`.

**Gradle gagal download (`services.gradle.org` / `dl.google.com`).**
Jaringan Anda memblokir domain build Android. Gunakan jaringan normal atau CI
(workflow GitHub Actions di repo ini membangun APK debug otomatis).

**`Namespace not specified` / error AGP.**
Pastikan JDK 17+ (`java -version`) dan tidak menimpa versi AGP/Kotlin di
`android/settings.gradle.kts`.

**Error sqlite3 saat `flutter test` di Linux.**
Instal sqlite dev: `sudo apt install libsqlite3-dev`.

**Pod install gagal di iOS.**
`sudo gem install cocoapods`, lalu `cd ios && pod repo update && pod install`.

## Runtime

**Perekaman berhenti saat layar mati (Android).**
1. Pastikan permission *Background location* = "Allow all the time".
2. Beri pengecualian battery optimization (Settings → Diagnostik izin).
3. ROM vendor agresif: lihat https://dontkillmyapp.com.

**Deteksi otomatis tidak pernah memulai perjalanan.**
1. Cek permission Activity recognition / Motion & Fitness di Diagnostik Izin.
2. Perangkat harus memiliki Google Play Services (Android).
3. Deteksi butuh validasi pergerakan (~150 m atau ~20 detik > 8 km/jam) —
   bukan bug bila tidak langsung mulai.
4. Pastikan toggle "Deteksi perjalanan otomatis" aktif di Settings.

**Trip tidak muncul di Supabase.**
1. Pastikan login (bukan mode lokal) — mode lokal tidak pernah upload.
2. Cek status sinkronisasi di dashboard; tekan ikon refresh untuk sync manual.
3. Pastikan kedua file migration sudah dijalankan; error RLS berarti policy
   belum terpasang.
4. Trip berstatus aktif tidak di-upload — hanya trip selesai.

**Ringkasan tidak tersimpan / "Perjalanan terlalu pendek".**
Trip dengan < 10 titik valid, < 300 m, atau < 60 detik sengaja dibatalkan
(lihat `TripDetectionConfig`).

**Peta kosong.**
Tile OpenStreetMap butuh internet. Data rute tetap aman di lokal; peta muncul
saat online kembali.

**GPS tidak akurat / rute bergerigi.**
Perekaman di dalam gedung/terowongan menghasilkan akurasi buruk; titik dengan
akurasi > 50 m dibuang otomatis. Posisikan ponsel dengan langit terlihat.

## Log debug

Log teknis lokal tersimpan di direktori app-support (`triplog.log`, rotasi
512 KB). Token autentikasi tidak pernah ditulis ke log.

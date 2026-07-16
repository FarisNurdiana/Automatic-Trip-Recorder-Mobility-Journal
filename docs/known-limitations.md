# Keterbatasan MVP (dijelaskan jujur)

1. **Activity recognition tidak selalu akurat.** API Android dan iOS bisa
   terlambat, salah mengklasifikasi (mis. bus vs mobil vs kereta), atau tidak
   mengirim event sama sekali. Karena itu deteksi hanya menjadi *pemicu
   kandidat*, dan kontrol manual selalu tersedia.

2. **Auto-start dan auto-stop dapat salah.** Perjalanan bisa terlambat
   dimulai (butuh validasi pergerakan), terpotong (kehilangan GPS), atau
   telat berhenti (menunggu ~6 menit stabil). Threshold dapat disetel di
   `lib/core/config/trip_detection_config.dart`.

3. **Mobil dan motor belum dapat dibedakan secara andal.** MVP hanya
   mendeteksi "berada dalam kendaraan". Prediksi jenis kendaraan yang tampil
   bersifat placeholder; konfirmasi pengguna diperlakukan sebagai
   ground-truth label untuk melatih model di masa depan. Kami **tidak**
   mengklaim akurasi klasifikasi mobil/motor pada MVP.

4. **GPS terganggu lingkungan.** Gedung tinggi, terowongan, basement, dan
   cuaca memengaruhi akurasi. Filter rule-based mengurangi outlier tetapi
   tidak menghilangkan semua kesalahan jarak/kecepatan.

5. **Background execution berbeda di setiap merek ponsel.** ROM agresif
   (MIUI, ColorOS, dll.) dapat membunuh foreground service meski sudah ada
   notifikasi. Pengecualian battery optimization membantu tapi tidak
   menjamin. Lihat `docs/android-setup.md`.

6. **iOS membatasi eksekusi background.** Aplikasi bisa dihentikan sistem
   kapan pun; tidak ada notifikasi persisten. Pemulihan trip dilakukan saat
   aplikasi dibuka kembali, sehingga bagian akhir perjalanan bisa hilang.

7. **Data sensor sangat dipengaruhi posisi ponsel.** Accelerometer/gyroscope
   di saku sangat berbeda dengan di holder stang motor. Karena itu posisi
   ponsel dicatat sebagai metadata (`phone_mount_position`) dan dataset MVP
   harus dianalisis dengan mempertimbangkan hal ini.

8. **Perangkat wearable (mis. Huawei Band) belum menjadi sumber data** pada
   MVP ini.

9. **Perangkat Android tanpa Google Play Services** tidak mendapatkan
   activity recognition maupun fused location — hanya perekaman manual yang
   berfungsi (dan itu pun bergantung pada penyedia lokasi platform).

10. **Jika proses aplikasi dimatikan paksa saat merekam**, titik selama
    proses mati tidak terekam; trip dipulihkan saat aplikasi dibuka kembali
    tetapi ada celah data. Penulisan titik sepenuhnya di sisi native adalah
    perbaikan yang direncanakan.

11. **Teks notifikasi Android saat merekam berbahasa Indonesia statis**
    (belum mengikuti locale aplikasi).

12. **Alamat awal/akhir (reverse geocoding) belum diimplementasikan** —
    kolomnya sudah ada di skema lokal & cloud, tetapi MVP tidak memanggil
    layanan geocoding apa pun (menghindari dependensi API berbayar).

13. **Build iOS belum diverifikasi** karena lingkungan pengembangan tanpa
    macOS/Xcode. Kode, konfigurasi, dan dokumentasi tersedia; verifikasi
    membutuhkan Mac.

14. **Aplikasi ini bukan alat keselamatan atau alat medis** dan tidak boleh
    diandalkan untuk keperluan darurat, navigasi, atau kepatuhan hukum.

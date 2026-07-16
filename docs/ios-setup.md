# Setup iOS

> **Catatan kejujuran:** proyek iOS ini disiapkan lengkap (Swift, Info.plist,
> Podfile, background mode) tetapi **belum diverifikasi build** karena
> lingkungan pengembangan yang dipakai tidak memiliki macOS/Xcode. Ikuti
> langkah di bawah pada Mac untuk memverifikasi.

## Prasyarat

- macOS dengan Xcode 16+
- CocoaPods (`sudo gem install cocoapods`)
- iOS minimum: **13.0** (mengikuti supabase_flutter & flutter_map)

## Langkah build

```bash
flutter pub get
cd ios
pod install
cd ..
open ios/Runner.xcworkspace     # atur Team & signing di Xcode
flutter run                     # atau build dari Xcode
# tanpa signing:
flutter build ios --debug --no-codesign
```

## Capability yang harus aktif di Xcode

Target **Runner → Signing & Capabilities**:

1. **Background Modes** → centang **Location updates**.
   (Sudah dideklarasikan di Info.plist lewat `UIBackgroundModes = [location]`,
   tapi pastikan capability muncul di Xcode.)

## Info.plist (sudah terisi)

| Key | Nilai |
|---|---|
| `NSLocationWhenInUseUsageDescription` | "Digunakan untuk merekam rute perjalanan Anda." |
| `NSLocationAlwaysAndWhenInUseUsageDescription` | "Digunakan agar perjalanan tetap direkam ketika layar mati atau aplikasi diminimalkan." |
| `NSMotionUsageDescription` | "Digunakan untuk mengenali aktivitas seperti berjalan, diam, atau menggunakan kendaraan." |
| `UIBackgroundModes` | `location` |

## Komponen native (Swift)

| File | Fungsi |
|---|---|
| `AppDelegate.swift` | Registrasi MethodChannel/EventChannel yang sama dengan Android |
| `LocationTracker.swift` | `CLLocationManager` dengan `allowsBackgroundLocationUpdates`, `activityType = .automotiveNavigation`, profil akurasi/distance filter adaptif |
| `MotionActivityTracker.swift` | `CMMotionActivityManager` → tipe aktivitas internal yang sama dengan Android (confidence low/medium/high → 0.3/0.6/0.9) |

Kedua file sudah didaftarkan di `project.pbxproj`.

## Podfile

`ios/Podfile` menyetel platform 13.0 dan macro `permission_handler` sehingga
hanya permission yang benar-benar dipakai yang dikompilasi:
`PERMISSION_LOCATION`, `PERMISSION_LOCATION_ALWAYS`,
`PERMISSION_NOTIFICATIONS`, `PERMISSION_SENSORS` (motion & fitness).

## Perilaku background iOS

- iOS tidak memiliki notifikasi persisten seperti Android; sebagai gantinya
  sistem menampilkan indikator lokasi (pil biru/ikon panah) selama perekaman.
- iOS dapat menghentikan aplikasi kapan saja; pemulihan trip aktif dilakukan
  saat aplikasi dibuka kembali (lihat `docs/architecture.md`).
- `CMMotionActivityManager` membutuhkan izin **Motion & Fitness**; tanpa itu
  deteksi otomatis tidak berjalan dan perekaman manual tetap tersedia.

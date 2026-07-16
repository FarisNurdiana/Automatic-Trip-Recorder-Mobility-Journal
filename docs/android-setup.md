# Setup Android

## Prasyarat

- Android Studio dengan Android SDK Platform **36** dan Build-Tools 36
- JDK 17 atau lebih baru (JDK 21 direkomendasikan)
- Gradle di-download otomatis oleh wrapper (9.1.0); AGP 9.0.1; Kotlin 2.3.20
- `minSdk = 26` (Android 8.0) — dibutuhkan foreground service modern &
  notification channel. `targetSdk` mengikuti Flutter (36).

## Build

```bash
flutter pub get
flutter build apk --debug          # APK debug
flutter build apk --release        # perlu signing config sendiri
```

APK debug muncul di `build/app/outputs/flutter-apk/app-debug.apk`.

## Komponen native (Kotlin)

| File | Fungsi |
|---|---|
| `MainActivity.kt` | Mendaftarkan MethodChannel/EventChannel (`triplog/location`, `triplog/activity`, dst.) |
| `TripTrackingService.kt` | Foreground service tipe `location`; FusedLocationProviderClient; notifikasi persisten dengan aksi Pause/Resume/Stop; interval adaptif 3/7/20 detik |
| `ActivityTransitionReceiver.kt` | Menerima hasil Activity Recognition Transition API + sampled updates (dengan confidence) |
| `EventStreams.kt` | Buffer event native → Flutter agar tidak ada event hilang saat engine belum siap |

Dependensi native: `com.google.android.gms:play-services-location:21.3.0`
(Fused Location Provider + Activity Recognition). Perangkat tanpa Google Play
Services tidak mendapat deteksi otomatis — perekaman manual tetap berfungsi.

## Permission di AndroidManifest

- `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION` — merekam rute
- `ACCESS_BACKGROUND_LOCATION` — merekam saat layar mati (di Android 11+
  pengguna harus memilih "Allow all the time" dari halaman Settings)
- `ACTIVITY_RECOGNITION` — deteksi masuk/keluar kendaraan (runtime permission
  sejak Android 10)
- `FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_LOCATION` — service perekaman
- `POST_NOTIFICATIONS` — notifikasi "Perjalanan sedang direkam" (Android 13+)
- `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` — opsional, agar service tidak
  dimatikan sistem

Aplikasi meminta permission **bertahap dengan penjelasan** lewat onboarding,
tidak sekaligus. Lihat `docs/permissions.md`.

## Battery optimization & vendor ROM

Beberapa merek (Xiaomi/MIUI, Oppo/ColorOS, Vivo, Huawei, Samsung) membunuh
background service secara agresif. Sarankan pengguna untuk:

1. Memberi pengecualian battery optimization (tersedia dari halaman
   Diagnostik Izin di aplikasi).
2. Mengunci aplikasi di recent apps (fitur vendor).
3. Menonaktifkan "battery saver" ketat untuk TripLog.

Lihat https://dontkillmyapp.com untuk panduan per vendor.

## Catatan build di jaringan terbatas

Build Android membutuhkan akses ke `dl.google.com` (Google Maven & SDK) dan
`services.gradle.org`. Di jaringan yang memblokir domain tersebut, build tidak
dapat berjalan — gunakan CI (GitHub Actions bawaan repo ini) atau jaringan
normal.

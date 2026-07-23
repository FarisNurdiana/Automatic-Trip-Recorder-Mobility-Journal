# Ruteku — Catat Perjalanan Otomatis

Ruteku (sebelumnya TripLog) adalah aplikasi Flutter (Android & iOS) yang
mendeteksi ketika Anda sedang menggunakan kendaraan, merekam rute perjalanan
dari titik A ke titik B di latar belakang, lalu menghasilkan ringkasan
perjalanan secara otomatis — lengkap dengan peta rute, statistik, klasifikasi
titik berhenti, dan konfirmasi jenis kendaraan.

> Ruteku **bukan** clone Strava: fokusnya adalah pencatatan perjalanan
> kendaraan otomatis (mobility journal), bukan aktivitas olahraga.

## Fitur MVP

- ✅ Deteksi aktivitas native (Activity Recognition Transition API di Android,
  CMMotionActivityManager di iOS) sebagai pemicu kandidat perjalanan
- ✅ Perekaman GPS latar belakang (foreground service + fused location di
  Android; Core Location background mode di iOS) dengan sampling adaptif
- ✅ State machine perjalanan eksplisit
  (`idle → possibleTrip → recording → temporarilyStopped → finishing → finished`)
- ✅ Offline-first: seluruh data disimpan lokal (Drift/SQLite) lebih dulu
- ✅ Sinkronisasi ke Supabase (auth, PostgreSQL + RLS, batch upload, retry
  dengan exponential backoff, idempotent)
- ✅ Ringkasan perjalanan otomatis (jarak Haversine, waktu bergerak/berhenti,
  kecepatan rata-rata/maksimum, deteksi lokasi berhenti, filter GPS rule-based)
- ✅ Peta rute OpenStreetMap (flutter_map) + grafik kecepatan
- ✅ Koreksi jenis kendaraan oleh pengguna (ground-truth label untuk model
  klasifikasi mobil/motor di masa depan)
- ✅ Perekaman dataset sensor (accelerometer/gyroscope/magnetometer) dengan
  buffering + downsampling, opsional dan hemat baterai
- ✅ Pemulihan perjalanan setelah aplikasi ditutup paksa
- ✅ **Bagikan perjalanan**: gambar PNG (peta + statistik + watermark, dengan
  pilihan privasi & pemotongan rute), GPX (impor ke Strava/Google Earth),
  GeoJSON, dan salin ringkasan
- ✅ Peta layar penuh "Peta perjalanan" dengan marker berhenti yang dapat
  ditekan, label berhenti (istirahat/parkir/BBM/tujuan...), panah arah,
  dark mode, dan kontrol zoom/fit/recenter
- ✅ Lifecycle berhenti bertingkat: berhenti singkat tanpa gangguan, 30 menit
  memunculkan pertanyaan tujuan/istirahat, 5 jam menjadi kandidat tujuan
  dengan auto-finish yang bisa dikoreksi pengguna
- ✅ Modul edukasi **Rambu lalu lintas Indonesia** (pencarian, kategori,
  favorit) bersumber UU 22/2009 & Permenhub PM 13/2014
- ✅ Bahasa Indonesia (default) + English, tema terang/gelap

> **Prioritas platform:** pengujian difokuskan ke **Android** terlebih dahulu
> (APK debug diverifikasi otomatis oleh CI). Kode iOS lengkap tetapi belum
> diverifikasi — lihat `docs/ios-setup.md`.

## Struktur Proyek

```
lib/
  app/            # MaterialApp, router (GoRouter), theme, providers (Riverpod)
  core/
    activity/     # Activity recognition: interface + MethodChannel + simulator
    config/       # Env, threshold deteksi (satu file), konfigurasi sensor
    constants/    # Enum domain (state, vehicle, sync, dsb.)
    errors/       # AppException, logger lokal
    location/     # Location tracking: interface + MethodChannel + simulator
    sensors/      # Sensor collection: buffering + downsampling
    simulation/   # Trip simulator (replay skrip JSON)
    storage/      # Drift database + migration
    sync/         # Sync engine (batch, retry, status)
    utils/        # Haversine, polyline simplifier, formatter
  features/
    auth/         # Login/register/reset + onboarding permission bertahap
    home/         # Dashboard
    recording/    # State machine + controller + halaman current trip
    trips/        # Repository, summary calculator, history/detail/konfirmasi
    profile/
    settings/     # Settings, diagnostik izin, privasi
  shared/         # Widget reusable (loading/empty/error/offline)
  l10n/           # app_id.arb (default), app_en.arb
android/          # Kotlin: foreground service, transition receiver, channels
ios/              # Swift: Core Location + Core Motion + channels
supabase/         # SQL migration + RLS policies
assets/simulator/ # Skrip rute simulasi JSON
docs/             # Dokumentasi arsitektur, setup, permission, testing
test/             # Unit test (84 test)
```

## Prasyarat

- Flutter stable **3.44.x** (Dart 3.12, null safety)
- Android: Android SDK 36, JDK 17+ (via Android Studio), minSdk **26**
- iOS: macOS + Xcode 16+, CocoaPods, iOS **13+**
- Akun [Supabase](https://supabase.com) (gratis) untuk auth & sync

## Instalasi

### 1. Clone & dependensi

```bash
git clone <repo-url>
cd Automatic-Trip-Recorder-Mobility-Journal
flutter pub get
```

### 2. Konfigurasi environment

```bash
cp .env.example .env
# lalu isi SUPABASE_URL dan SUPABASE_ANON_KEY dari dashboard Supabase
```

Tanpa `.env`, aplikasi tetap berjalan dalam **mode lokal** (tanpa akun dan
tanpa sinkronisasi).

### 3. Setup Supabase

Jalankan SQL di `supabase/migrations/` secara berurutan pada SQL Editor
Supabase (atau `supabase db push` dengan CLI). Detail: [docs/supabase-setup.md](docs/supabase-setup.md).

### 4. Menjalankan di Android

```bash
flutter run                     # perangkat/emulator terpasang
flutter build apk --debug       # membuat APK debug
```

Detail (permission, battery optimization, vendor ROM): [docs/android-setup.md](docs/android-setup.md).

### 5. Menjalankan di iOS

```bash
cd ios && pod install && cd ..
flutter run
# atau: flutter build ios --debug --no-codesign
```

Wajib membuka `ios/Runner.xcworkspace` di Xcode untuk mengatur signing.
Detail capability & background mode: [docs/ios-setup.md](docs/ios-setup.md).

## Verifikasi

```bash
dart format .
flutter analyze     # 0 issue
flutter test        # 84 test
```

## Dokumentasi

| Dokumen | Isi |
|---|---|
| [docs/architecture.md](docs/architecture.md) | Arsitektur, state machine, aliran data |
| [docs/android-setup.md](docs/android-setup.md) | Setup Android, foreground service |
| [docs/ios-setup.md](docs/ios-setup.md) | Setup Xcode, background modes |
| [docs/supabase-setup.md](docs/supabase-setup.md) | Migration, RLS, auth |
| [docs/permissions.md](docs/permissions.md) | Seluruh permission & alasannya |
| [docs/testing.md](docs/testing.md) | Unit test & trip simulator |
| [docs/known-limitations.md](docs/known-limitations.md) | Keterbatasan MVP (jujur) |
| [docs/troubleshooting.md](docs/troubleshooting.md) | Masalah umum & solusinya |

## Keterbatasan Penting (ringkas)

- Activity recognition tidak selalu akurat; auto-start/auto-stop bisa salah.
- Mobil dan motor **belum** dapat dibedakan secara andal — konfirmasi pengguna
  adalah sumber label yang sebenarnya.
- GPS terganggu oleh gedung, terowongan, dan pengaturan baterai; background
  execution berbeda-beda antar merek ponsel (terutama ROM agresif).
- Aplikasi ini bukan alat keselamatan atau alat medis.

Daftar lengkap: [docs/known-limitations.md](docs/known-limitations.md).

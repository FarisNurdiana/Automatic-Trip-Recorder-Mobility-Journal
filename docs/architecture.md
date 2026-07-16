# Arsitektur TripLog

## Prinsip

1. **Feature-first + layer terpisah.** UI tidak pernah menyentuh database atau
   platform channel secara langsung; semuanya lewat repository dan service
   interface.
2. **Offline-first.** Setiap byte data ditulis ke Drift (SQLite) lebih dulu.
   Sinkronisasi ke Supabase adalah proses lanjutan yang boleh gagal kapan pun
   tanpa kehilangan data.
3. **Logika inti murni & teruji.** State machine, filter GPS, dan kalkulator
   ringkasan adalah pure Dart tanpa dependensi platform — semuanya digerakkan
   oleh event dan timestamp yang di-inject, sehingga dapat diuji tanpa GPS
   fisik.

## Diagram lapisan

```
┌────────────────────────────────────────────────────────┐
│ Presentation (pages, widgets)                          │
│   Riverpod providers + GoRouter                        │
├────────────────────────────────────────────────────────┤
│ Application                                            │
│   TripRecordingController  AuthController  Settings    │
├────────────────────────────────────────────────────────┤
│ Domain (pure Dart)                                     │
│   TripStateMachine  TripSummaryCalculator  GpsFilter   │
├───────────────────────────┬────────────────────────────┤
│ Data                      │ Platform services          │
│   TripRepository          │   LocationTrackingService  │
│   LocalTripDataSource     │   ActivityRecognitionSvc   │
│   RemoteTripDataSource    │   SensorCollectionService  │
│   SyncService             │   (MethodChannel / fake)   │
├───────────────────────────┼────────────────────────────┤
│ Drift (SQLite)  Supabase  │ Kotlin service / Swift     │
└───────────────────────────┴────────────────────────────┘
```

## Interface service utama

Semua kontrak berada di kode dan memiliki implementasi platform **dan** mock:

| Interface | Implementasi produksi | Implementasi test |
|---|---|---|
| `LocationTrackingService` | `MethodChannelLocationTrackingService` | `SimulatedLocationTrackingService` |
| `ActivityRecognitionService` | `MethodChannelActivityRecognitionService` | `SimulatedActivityRecognitionService` |
| `SensorCollectionService` | `SensorsPlusCollectionService` | `FakeSensorService` (test) |
| `TripStateMachine` | `DefaultTripStateMachine` | — (pure, diuji langsung) |
| `TripRepository` | `DefaultTripRepository` | — (pakai DB in-memory) |
| `LocalTripDataSource` | `DriftTripDataSource` | Drift `NativeDatabase.memory()` |
| `RemoteTripDataSource` | `SupabaseTripDataSource` | `FakeRemote` (test) |
| `SyncService` | `DefaultSyncService` | — (delay & remote di-inject) |
| `TripSummaryCalculator` | `DefaultTripSummaryCalculator` | — (pure) |

## State machine perjalanan

```
        activity: vehicle (conf ≥ 0.7)
 idle ────────────────────────────────► possibleTrip
  ▲                                        │
  │ timeout 5 mnt / aktivitas jalan kaki   │ validasi (salah satu):
  │◄───────────────────────────────────────┤  • perpindahan ≥ 150 m
  │                                        │  • kecepatan ≥ 8 km/j selama ≥ 20 dtk
  │                                        │  • ≥ 4 titik bergerak konsisten
  │                                        ▼
  │                                    recording ◄─────────────┐
  │                                        │                   │ bergerak lagi
  │                                        │ kecepatan ≤ 3 km/j│
  │                                        │ & stabil ≥ 90 dtk │
  │                                        ▼                   │
  │                              temporarilyStopped ───────────┘
  │                                        │ non-vehicle & stabil ≥ 6 mnt
  │                                        ▼
  │                                    finishing ──► finished
  │                                        │
  └───────────── cancelled ◄───────────────┘ (manual cancel)
```

- **Seluruh threshold** ada di satu file:
  `lib/core/config/trip_detection_config.dart`.
- Activity recognition hanya **pemicu**; perjalanan tidak pernah dimulai dari
  satu event atau satu titik GPS saja.
- Kontrol manual (start/pause/resume/finish/cancel) selalu tersedia dan tetap
  berfungsi jika deteksi otomatis gagal atau dimatikan.

## Aliran data perekaman

```
Activity Recognition ──► TripStateMachine ◄── GPS fixes (adaptif 3/7/20 dtk)
                              │ transitions
                              ▼
                   TripRecordingController
        ┌──────────────┬──────┴────────┬──────────────────┐
        ▼              ▼               ▼                  ▼
   TripRepository  Notification   Sampling profile   SensorCollection
   (Drift lokal)   (Android FGS)  (moving/slow/stop) (buffer→downsample)
```

## Ringkasan perjalanan

`DefaultTripSummaryCalculator` (versi algoritma disimpan per trip):

1. **Filter rule-based** (`GpsPointFilter`, bukan machine learning): akurasi
   buruk, timestamp mundur, lompatan mustahil (kecepatan tersirat > 220 km/j),
   spike kecepatan tak konsisten; mock location ditandai.
2. **Median smoothing** kecepatan (window 3).
3. Jarak = penjumlahan Haversine titik tervalidasi.
4. `overall avg = jarak / elapsed`; `moving avg = jarak / waktu bergerak`.
5. Deteksi lokasi berhenti: klaster kecepatan ≤ 3 km/j berdurasi ≥ 60 dtk.
6. Trip tidak valid (< 10 titik, < 300 m, atau < 60 dtk) → dibatalkan, bukan
   disimpan dengan angka menyesatkan.

## Sinkronisasi

- Status per baris: `pending → syncing → synced / failed`.
- Urutan upload per trip: trip row → points (batch 500) → activity events →
  sensor samples (batch 500).
- Retry exponential backoff (2s, 4s, 8s, 16s), maksimal 4 kali.
- Idempoten: seluruh primary key adalah UUID yang dibuat di perangkat dan
  di-upsert; retry tidak pernah menduplikasi data.
- Kegagalan tidak pernah menghapus data lokal.
- Mode lokal (tanpa akun): sinkronisasi dinonaktifkan sepenuhnya; tidak ada
  data lokasi/sensor yang meninggalkan perangkat.

## Pemulihan setelah force-close

Trip berstatus aktif (`recording` / `temporarilyStopped` / `finishing`)
di-scan saat startup (`TripRecordingController.init`). Jika ditemukan, state
machine di-restore, jarak dihitung ulang dari titik tersimpan, GPS dan sensor
dinyalakan kembali, dan pengguna diberi tahu bahwa perjalanan dipulihkan.

## Penyimpanan peta

- Raw points **selalu** tersimpan utuh di lokal.
- Untuk tampilan, polyline disederhanakan dengan Ramer–Douglas–Peucker
  (`PolylineSimplifier`) sehingga ribuan titik tidak membekukan UI.
- Grafik kecepatan di-downsample maksimal ~300 titik.

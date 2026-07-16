# Testing

## Menjalankan

```bash
flutter test          # seluruh suite (84 test)
flutter analyze       # statik analisis, harus 0 issue
dart format .         # formatter
```

Test database memakai Drift `NativeDatabase.memory()` — di Linux/macOS
membutuhkan `libsqlite3` sistem (Ubuntu: `apt install libsqlite3-dev`).

## Cakupan

| Area | File | Isi |
|---|---|---|
| Haversine & konversi | `test/core/geo_utils_test.dart` | jarak nol, 1° lintang, pasangan kota nyata, simetri, antimeridian |
| Filter GPS | `test/features/trips/gps_point_filter_test.dart` | akurasi buruk, timestamp mundur, lompatan mustahil, spike kecepatan, mock location |
| Ringkasan trip | `test/features/trips/trip_summary_calculator_test.dart` | durasi, moving/stopped time, jarak, kecepatan rata-rata & moving average & maksimum, deteksi berhenti, versi algoritma, trip tidak valid |
| State machine | `test/features/recording/trip_state_machine_test.dart` | semua jalur transisi wajib: idle→possibleTrip, possibleTrip→recording (3 kondisi), possibleTrip→idle (timeout/aktivitas lain), recording→temporarilyStopped, temporarilyStopped→recording, temporarilyStopped→finishing, finishing→finished, recording→cancelled, kontrol manual, restore |
| Repository | `test/features/trips/trip_repository_test.dart` | lifecycle trip, urutan sequence, konfirmasi kendaraan (ground truth), **pemulihan trip setelah restart**, hapus data |
| Sinkronisasi | `test/core/sync_service_test.dart` | upload + batch, **pencegahan duplikasi (idempoten)**, retry exponential backoff, kegagalan tidak menghapus data lokal |
| Simulator | `test/core/trip_simulator_test.dart` | parsing skrip, playback bertahap, enter/exit vehicle, signal loss, pipeline penuh (jump terfilter, ringkasan masuk akal) |
| Controller | `test/features/recording/trip_recording_controller_test.dart` | alur manual penuh, deteksi otomatis, aksi notifikasi, recovery |

## Trip Simulator

Simulator (`lib/core/simulation/trip_simulator.dart`) mereplay skrip JSON
sehingga perekaman bisa diuji **tanpa benar-benar berkendara**.

Format skrip (`assets/simulator/jakarta_commute.json`):

```json
{
  "name": "jakarta-sudirman-commute",
  "steps": [
    {"type": "activity", "activity": "vehicle", "transition": "enter",
     "confidence": 0.85, "afterSeconds": 0},
    {"type": "point", "lat": -6.195, "lon": 106.823,
     "speedKmh": 35.2, "accuracy": 6.1, "afterSeconds": 3},
    {"type": "signalLoss", "afterSeconds": 45},
    {"type": "point", "lat": -6.215, "lon": 106.813,
     "speedKmh": 300, "accuracy": 80,
     "comment": "GPS jump outlier - must be filtered"},
    {"type": "activity", "activity": "vehicle", "transition": "exit",
     "afterSeconds": 5}
  ]
}
```

Kemampuan:

- mengirim titik rute **bertahap** (delay `afterSeconds`, bisa dipercepat
  dengan `timeFactor`, atau instan untuk unit test dengan `instant: true`);
- mensimulasikan kecepatan (`speedKmh`);
- mensimulasikan berhenti (titik berkecepatan ~0);
- mensimulasikan **GPS jump** (titik outlier);
- mensimulasikan **kehilangan sinyal** (`signalLoss`);
- mensimulasikan event **enter/exit vehicle**.

Contoh pemakaian di kode:

```dart
final sim = TripSimulator.fromJson(jsonString);
await for (final event in sim.play(timeFactor: 30)) {
  switch (event) {
    case SimulationLocationEvent(:final location):
      simulatedLocationService.emit(location);
    case SimulationActivityEvent(:final activity):
      simulatedActivityService.emit(activity);
  }
}
```

`SimulatedLocationTrackingService` dan `SimulatedActivityRecognitionService`
mengimplementasikan interface yang sama dengan versi native, sehingga seluruh
pipeline (state machine → repository → summary) berjalan persis seperti di
perangkat nyata.

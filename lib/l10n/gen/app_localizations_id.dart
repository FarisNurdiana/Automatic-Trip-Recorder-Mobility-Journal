// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Ruteku';

  @override
  String get commonRetry => 'Coba lagi';

  @override
  String get commonCancel => 'Batal';

  @override
  String get commonSave => 'Simpan';

  @override
  String get commonDelete => 'Hapus';

  @override
  String get commonClose => 'Tutup';

  @override
  String get commonLoading => 'Memuat...';

  @override
  String get commonError => 'Terjadi kesalahan';

  @override
  String get commonEmpty => 'Belum ada data';

  @override
  String get commonOffline => 'Tidak ada koneksi internet';

  @override
  String get commonOfflineBanner =>
      'Offline — data disimpan lokal dan akan disinkronkan nanti';

  @override
  String get commonSkip => 'Lewati';

  @override
  String get commonNext => 'Lanjut';

  @override
  String get commonDone => 'Selesai';

  @override
  String get commonConfirm => 'Konfirmasi';

  @override
  String get authLoginTitle => 'Masuk';

  @override
  String get authRegisterTitle => 'Daftar';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Kata sandi';

  @override
  String get authDisplayName => 'Nama tampilan';

  @override
  String get authLoginButton => 'Masuk';

  @override
  String get authRegisterButton => 'Daftar';

  @override
  String get authForgotPassword => 'Lupa kata sandi?';

  @override
  String get authResetPasswordTitle => 'Atur ulang kata sandi';

  @override
  String get authResetPasswordButton => 'Kirim tautan atur ulang';

  @override
  String get authResetPasswordSent =>
      'Tautan atur ulang telah dikirim ke email Anda.';

  @override
  String get authNoAccount => 'Belum punya akun? Daftar';

  @override
  String get authHaveAccount => 'Sudah punya akun? Masuk';

  @override
  String get authLogout => 'Keluar';

  @override
  String get authLocalMode => 'Lanjut tanpa akun (mode lokal)';

  @override
  String get authLocalModeInfo =>
      'Perjalanan disimpan di perangkat saja dan tidak disinkronkan.';

  @override
  String get authEmailInvalid => 'Format email tidak valid';

  @override
  String get authPasswordTooShort => 'Kata sandi minimal 8 karakter';

  @override
  String get authRegisterSuccess =>
      'Pendaftaran berhasil. Periksa email Anda untuk konfirmasi.';

  @override
  String get authLogoutUnsyncedWarning =>
      'Masih ada data yang belum tersinkronisasi. Jika keluar sekarang, data tersebut tetap tersimpan di perangkat tetapi tidak akan diunggah sampai Anda masuk kembali.';

  @override
  String get homeTitle => 'Beranda';

  @override
  String get homeDetectionStatus => 'Status deteksi';

  @override
  String get homeStartTrip => 'Mulai perjalanan';

  @override
  String get homeLastTrip => 'Perjalanan terakhir';

  @override
  String get homeTotalDistance => 'Total jarak';

  @override
  String get homeTripCount => 'Jumlah perjalanan';

  @override
  String get homePermissions => 'Izin';

  @override
  String get homeSyncStatus => 'Sinkronisasi';

  @override
  String get homeNoTrips => 'Belum ada perjalanan tercatat';

  @override
  String get homePermissionsIncomplete => 'Beberapa izin belum diberikan';

  @override
  String get homePermissionsComplete => 'Semua izin lengkap';

  @override
  String get stateIdle => 'Mencari aktivitas';

  @override
  String get statePossibleTrip => 'Kemungkinan perjalanan terdeteksi';

  @override
  String get stateRecording => 'Perjalanan sedang direkam';

  @override
  String get stateTemporarilyStopped => 'Berhenti sementara';

  @override
  String get stateFinishing => 'Menyelesaikan perjalanan';

  @override
  String get stateFinished => 'Perjalanan tersimpan';

  @override
  String get stateCancelled => 'Perjalanan dibatalkan';

  @override
  String get syncPending => 'Menunggu sinkronisasi';

  @override
  String get syncSyncing => 'Menyinkronkan...';

  @override
  String get syncSynced => 'Tersinkronisasi';

  @override
  String get syncFailed => 'Sinkronisasi gagal';

  @override
  String get syncNow => 'Sinkronkan sekarang';

  @override
  String get syncLocalOnly => 'Mode lokal — sinkronisasi nonaktif';

  @override
  String get tripCurrentTitle => 'Perjalanan saat ini';

  @override
  String get tripPause => 'Jeda';

  @override
  String get tripResume => 'Lanjutkan';

  @override
  String get tripFinish => 'Selesaikan';

  @override
  String get tripCancel => 'Batalkan';

  @override
  String get tripCancelConfirm =>
      'Batalkan perjalanan ini? Data perjalanan ini akan dihapus.';

  @override
  String get tripDistance => 'Jarak';

  @override
  String get tripDuration => 'Durasi';

  @override
  String get tripSpeed => 'Kecepatan';

  @override
  String get tripMaxSpeed => 'Kecepatan maks';

  @override
  String get tripAvgSpeed => 'Kecepatan rata-rata';

  @override
  String get tripMovingAvgSpeed => 'Rata-rata bergerak';

  @override
  String get tripMovingTime => 'Waktu bergerak';

  @override
  String get tripStoppedTime => 'Waktu berhenti';

  @override
  String get tripDeparture => 'Berangkat';

  @override
  String get tripArrival => 'Tiba';

  @override
  String get tripStops => 'Lokasi berhenti';

  @override
  String get tripStopCount => 'Jumlah berhenti';

  @override
  String get tripNoPoints => 'Perjalanan tidak memiliki cukup titik GPS';

  @override
  String get tripTooShort => 'Perjalanan terlalu pendek untuk disimpan';

  @override
  String get tripPoints => 'Titik GPS';

  @override
  String get tripSpeedChart => 'Grafik kecepatan';

  @override
  String get tripFitRoute => 'Tampilkan seluruh rute';

  @override
  String get tripStart => 'Mulai';

  @override
  String get tripEnd => 'Selesai';

  @override
  String get tripExportGpx => 'Ekspor GPX';

  @override
  String get tripExportGpxDesc =>
      'Bagikan rute sebagai file GPX (dapat diimpor ke Strava, Google Earth, dll.)';

  @override
  String get tripExportFailed =>
      'Ekspor gagal. Perjalanan tidak memiliki titik rute.';

  @override
  String get historyTitle => 'Riwayat perjalanan';

  @override
  String get historyEmpty =>
      'Belum ada perjalanan. Mulai perjalanan pertama Anda dari beranda.';

  @override
  String get vehicleConfirmTitle => 'Konfirmasi kendaraan';

  @override
  String get vehicleConfirmMessage =>
      'Kami mendeteksi perjalanan menggunakan kendaraan.';

  @override
  String get vehicleConfirmQuestion => 'Jenis kendaraan:';

  @override
  String vehiclePrediction(String vehicle) {
    return 'Prediksi: $vehicle';
  }

  @override
  String vehicleConfidence(String percent) {
    return 'Confidence: $percent%';
  }

  @override
  String get vehicleCar => 'Mobil';

  @override
  String get vehicleMotorcycle => 'Motor';

  @override
  String get vehicleBus => 'Bus';

  @override
  String get vehicleTruck => 'Truk';

  @override
  String get vehicleTrain => 'Kereta';

  @override
  String get vehicleOther => 'Lainnya';

  @override
  String get vehicleUnknown => 'Tidak diketahui';

  @override
  String get profileTitle => 'Profil';

  @override
  String get settingsTitle => 'Pengaturan';

  @override
  String get settingsAutoDetection => 'Deteksi perjalanan otomatis';

  @override
  String get settingsAutoDetectionDesc =>
      'Mulai dan akhiri perekaman secara otomatis berdasarkan aktivitas kendaraan.';

  @override
  String get settingsSensorLogging => 'Perekaman data sensor';

  @override
  String get settingsSensorLoggingDesc =>
      'Merekam accelerometer dan gyroscope selama perjalanan untuk pengembangan model klasifikasi kendaraan.';

  @override
  String get settingsSensorLoggingWarning =>
      'Perekaman sensor meningkatkan penggunaan baterai.';

  @override
  String get settingsMountPosition => 'Posisi ponsel';

  @override
  String get settingsMountPositionDesc =>
      'Posisi ponsel memengaruhi karakteristik data sensor.';

  @override
  String get mountDashboard => 'Holder dashboard';

  @override
  String get mountHandlebar => 'Holder stang motor';

  @override
  String get mountPocket => 'Saku';

  @override
  String get mountBag => 'Tas';

  @override
  String get mountCupHolder => 'Cup holder';

  @override
  String get mountUnknown => 'Tidak diketahui';

  @override
  String get settingsLanguage => 'Bahasa';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get themeSystem => 'Ikuti sistem';

  @override
  String get themeLight => 'Terang';

  @override
  String get themeDark => 'Gelap';

  @override
  String get settingsPermissions => 'Diagnostik izin';

  @override
  String get settingsPrivacy => 'Privasi & keamanan';

  @override
  String get privacyTitle => 'Privasi & keamanan';

  @override
  String get privacyDeleteAllLocal => 'Hapus semua data lokal';

  @override
  String get privacyDeleteAllLocalConfirm =>
      'Semua perjalanan dan data sensor di perangkat ini akan dihapus permanen. Lanjutkan?';

  @override
  String get privacyDeleteAllCloud => 'Hapus semua data cloud saya';

  @override
  String get privacyDeleteAllCloudConfirm =>
      'Semua perjalanan Anda di server akan dihapus permanen. Lanjutkan?';

  @override
  String get privacyDeleteTrip => 'Hapus perjalanan';

  @override
  String get privacyDeleteTripConfirm =>
      'Hapus perjalanan ini secara permanen?';

  @override
  String get privacyDataDeleted => 'Data berhasil dihapus';

  @override
  String get permLocation => 'Lokasi';

  @override
  String get permLocationDesc => 'Digunakan untuk merekam rute perjalanan.';

  @override
  String get permBackgroundLocation => 'Lokasi latar belakang';

  @override
  String get permBackgroundLocationDesc =>
      'Digunakan agar perjalanan tetap direkam ketika layar mati atau aplikasi diminimalkan.';

  @override
  String get permActivityRecognition => 'Pengenalan aktivitas';

  @override
  String get permActivityRecognitionDesc =>
      'Digunakan untuk mendeteksi ketika perjalanan menggunakan kendaraan dimulai atau selesai.';

  @override
  String get permMotionFitness => 'Gerakan & kebugaran';

  @override
  String get permMotionFitnessDesc =>
      'Digunakan untuk mengenali aktivitas seperti berjalan, diam, atau menggunakan kendaraan.';

  @override
  String get permNotifications => 'Notifikasi';

  @override
  String get permNotificationsDesc =>
      'Digunakan untuk menunjukkan bahwa perjalanan sedang direkam.';

  @override
  String get permBatteryOptimization => 'Pengecualian optimasi baterai';

  @override
  String get permBatteryOptimizationDesc =>
      'Mencegah sistem menghentikan perekaman di latar belakang.';

  @override
  String get permGranted => 'Diberikan';

  @override
  String get permDenied => 'Ditolak';

  @override
  String get permActive => 'Aktif';

  @override
  String get permInactive => 'Tidak aktif';

  @override
  String get permRequest => 'Minta izin';

  @override
  String get permOpenSettings => 'Buka pengaturan';

  @override
  String get onboardingWelcomeTitle => 'Selamat datang di Ruteku';

  @override
  String get onboardingWelcomeDesc =>
      'Catat perjalanan Anda secara otomatis. Ruteku mendeteksi saat Anda menggunakan kendaraan, merekam rute, dan membuat ringkasan perjalanan.';

  @override
  String get onboardingPermissionsTitle => 'Izin yang dibutuhkan';

  @override
  String get onboardingPermissionsDesc =>
      'Agar perekaman otomatis berfungsi, Ruteku membutuhkan beberapa izin. Setiap izin dijelaskan sebelum diminta.';

  @override
  String get onboardingStart => 'Mulai';

  @override
  String get errorPermissionDenied =>
      'Izin ditolak. Beberapa fitur tidak akan berfungsi.';

  @override
  String get errorGpsDisabled =>
      'GPS tidak aktif. Aktifkan layanan lokasi untuk merekam perjalanan.';

  @override
  String get errorActivityUnavailable =>
      'Pengenalan aktivitas tidak tersedia di perangkat ini. Gunakan perekaman manual.';

  @override
  String get errorSupabaseUnavailable =>
      'Server tidak dapat diakses. Data tetap tersimpan lokal.';

  @override
  String get errorDatabase => 'Terjadi kesalahan pada penyimpanan lokal.';

  @override
  String get errorSensorUnavailable =>
      'Sensor tidak tersedia di perangkat ini.';

  @override
  String get errorTripTooFewPoints =>
      'Perjalanan tidak disimpan karena titik GPS terlalu sedikit.';

  @override
  String get errorEnvMissing => 'Konfigurasi Supabase belum diisi';

  @override
  String get errorEnvMissingDesc =>
      'Salin .env.example menjadi .env lalu isi SUPABASE_URL dan SUPABASE_ANON_KEY. Anda tetap dapat menggunakan mode lokal tanpa akun.';

  @override
  String get unitKm => 'km';

  @override
  String get unitKmh => 'km/jam';

  @override
  String get unitHour => 'jam';

  @override
  String get unitMinute => 'menit';

  @override
  String get recoveredTripTitle => 'Perjalanan dipulihkan';

  @override
  String get recoveredTripMessage =>
      'Perjalanan yang sedang berlangsung ditemukan dan dilanjutkan setelah aplikasi ditutup.';

  @override
  String get stateShortStop => 'Berhenti sebentar';

  @override
  String get stateRestStopCandidate => 'Berhenti cukup lama';

  @override
  String get stateDestinationCandidate => 'Kemungkinan sudah sampai';

  @override
  String get stopQuestion30Title => 'Anda sudah berhenti selama 30 menit';

  @override
  String get stopQuestion30Body =>
      'Apakah Anda sudah sampai di tujuan atau sedang beristirahat?';

  @override
  String get stopQuestion5hTitle => 'Perjalanan kemungkinan telah selesai';

  @override
  String get stopQuestion5hBody =>
      'Anda berada di lokasi yang sama selama lebih dari 5 jam.';

  @override
  String get answerArrived => 'Sudah sampai';

  @override
  String get answerResting => 'Sedang istirahat';

  @override
  String get answerContinue => 'Lanjutkan perjalanan';

  @override
  String get finishTripAction => 'Selesaikan perjalanan';

  @override
  String get keepTripAction => 'Tetap lanjutkan';

  @override
  String get finishedAutomaticallyBadge => 'Diselesaikan otomatis';

  @override
  String get editArrivalTime => 'Koreksi waktu tiba';

  @override
  String get arrivalUpdated => 'Waktu tiba diperbarui';

  @override
  String get mapPageTitle => 'Peta perjalanan';

  @override
  String get mapRecenter => 'Kembali ke rute';

  @override
  String get mapZoomIn => 'Perbesar';

  @override
  String get mapZoomOut => 'Perkecil';

  @override
  String get mapOpenFullscreen => 'Buka peta layar penuh';

  @override
  String get gpsQuality => 'Kualitas GPS';

  @override
  String get gpsGood => 'Baik';

  @override
  String get gpsFair => 'Sedang';

  @override
  String get gpsPoor => 'Buruk';

  @override
  String stopSheetTitle(int number) {
    return 'Berhenti $number';
  }

  @override
  String get stopArrivalTime => 'Waktu tiba';

  @override
  String get stopDepartureTime => 'Waktu berangkat';

  @override
  String get stopDurationLabel => 'Durasi';

  @override
  String get stopLocationLabel => 'Lokasi';

  @override
  String get stopTypeLabel => 'Jenis berhenti';

  @override
  String get stopUnconfirmed => 'Belum dikonfirmasi';

  @override
  String get stopTypeRest => 'Istirahat';

  @override
  String get stopTypeParking => 'Parkir';

  @override
  String get stopTypeFood => 'Membeli makanan';

  @override
  String get stopTypeFuel => 'Isi bahan bakar';

  @override
  String get stopTypeVisit => 'Mengunjungi lokasi';

  @override
  String get stopTypeTraffic => 'Kemacetan';

  @override
  String get stopTypeDestination => 'Tujuan';

  @override
  String get stopTypeOther => 'Lainnya';

  @override
  String get stopLabelSaved => 'Label berhenti disimpan';

  @override
  String get vehicleBicycle => 'Sepeda';

  @override
  String vehicleQuestionHigh(String vehicle) {
    return 'Apakah tadi Anda menggunakan $vehicle?';
  }

  @override
  String get vehiclePredictionInfo =>
      'Prediksi Ruteku berdasarkan pola perjalanan.';

  @override
  String vehicleConfidenceLabel(String percent) {
    return 'Keyakinan: $percent%';
  }

  @override
  String vehicleYes(String vehicle) {
    return 'Ya, $vehicle';
  }

  @override
  String get vehicleNo => 'Bukan';

  @override
  String vehicleQuestionMedium(String vehicle) {
    return 'Kemungkinan Anda menggunakan $vehicle';
  }

  @override
  String get vehicleQuestionMediumAsk => 'Apakah prediksi ini benar?';

  @override
  String get vehicleCorrect => 'Benar';

  @override
  String get vehicleChange => 'Ubah kendaraan';

  @override
  String get vehicleQuestionLow => 'Kendaraan apa yang Anda gunakan?';

  @override
  String get shareTripTitle => 'Bagikan perjalanan';

  @override
  String get sharePng => 'Gambar PNG';

  @override
  String get shareGpx => 'File GPX';

  @override
  String get shareGeoJson => 'File GeoJSON';

  @override
  String get shareCopySummary => 'Salin ringkasan';

  @override
  String get shareCopied => 'Ringkasan disalin ke clipboard';

  @override
  String get sharePreparing => 'Menyiapkan gambar perjalanan...';

  @override
  String get sharePrivacyTitle => 'Pilihan privasi';

  @override
  String get shareShowStart => 'Tampilkan lokasi awal';

  @override
  String get shareShowEnd => 'Tampilkan lokasi akhir';

  @override
  String get shareShowUserName => 'Tampilkan nama pengguna';

  @override
  String get shareShowMaxSpeed => 'Tampilkan kecepatan maksimum';

  @override
  String get sharePrivacyMode => 'Mode privasi';

  @override
  String get sharePrivacyModeDesc =>
      'Memotong ±300 m di awal dan akhir rute agar lokasi rumah tidak terlihat.';

  @override
  String get shareContinue => 'Lanjut';
}

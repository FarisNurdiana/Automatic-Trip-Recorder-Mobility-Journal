// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Motivox';

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
  String get onboardingWelcomeTitle => 'Selamat datang di Motivox';

  @override
  String get onboardingWelcomeDesc =>
      'Catat perjalanan Anda secara otomatis. Motivox mendeteksi saat Anda menggunakan kendaraan, merekam rute, dan membuat ringkasan perjalanan.';

  @override
  String get onboardingPermissionsTitle => 'Izin yang dibutuhkan';

  @override
  String get onboardingPermissionsDesc =>
      'Agar perekaman otomatis berfungsi, Motivox membutuhkan beberapa izin. Setiap izin dijelaskan sebelum diminta.';

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
      'Prediksi Motivox berdasarkan pola perjalanan.';

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

  @override
  String get signsTitle => 'Rambu lalu lintas';

  @override
  String get signsSubtitle =>
      'Referensi edukasi singkat rambu yang berlaku di Indonesia. Bukan pengganti aturan resmi atau alat navigasi.';

  @override
  String get signsSearchHint =>
      'Cari rambu... (mis. parkir, kecepatan, dilarang)';

  @override
  String get signsAll => 'Semua';

  @override
  String get signsCatWarning => 'Peringatan';

  @override
  String get signsCatProhibition => 'Larangan';

  @override
  String get signsCatMandatory => 'Perintah';

  @override
  String get signsCatGuide => 'Petunjuk';

  @override
  String get signsCatTemporary => 'Sementara';

  @override
  String get signsCatMarking => 'Marka jalan';

  @override
  String get signsMeaning => 'Arti';

  @override
  String get signsAction => 'Tindakan';

  @override
  String get signsSafetyNote => 'Catatan keselamatan';

  @override
  String get signsEmpty => 'Tidak ada rambu yang cocok dengan pencarian.';

  @override
  String get signsFavorites => 'Favorit';

  @override
  String get signsSourceNote =>
      'Sumber: UU No. 22/2009 & Permenhub PM 13/2014 (lihat dokumentasi).';

  @override
  String get tripSaved => 'Perjalanan tersimpan';

  @override
  String get errorTripNoGps =>
      'Perjalanan tidak tersimpan: tidak ada titik GPS yang terekam. Periksa GPS dan izin lokasi, lalu coba lagi.';

  @override
  String get errorNotSignedIn =>
      'Masuk atau aktifkan mode lokal terlebih dahulu untuk merekam perjalanan.';

  @override
  String get navHome => 'Beranda';

  @override
  String get navHistory => 'Riwayat';

  @override
  String get navSigns => 'Rambu';

  @override
  String get navSettings => 'Pengaturan';

  @override
  String get detectionLogTitle => 'Log deteksi';

  @override
  String get detectionLogEmpty =>
      'Belum ada aktivitas deteksi. Log terisi otomatis saat aplikasi memantau atau merekam perjalanan.';

  @override
  String get detectionLogDesc =>
      'Keputusan deteksi terbaru (mengapa perjalanan dimulai, ditunda, atau titik GPS ditolak).';

  @override
  String get homeHeroReady => 'Siap mencatat perjalananmu';

  @override
  String get homeHeroReadyDesc =>
      'Deteksi otomatis aktif — atau mulai manual kapan saja.';

  @override
  String get homeHeroActiveDesc =>
      'Perjalanan sedang direkam di latar belakang.';

  @override
  String get homeSeeAll => 'Lihat semua';

  @override
  String get homeQuickMenu => 'Menu cepat';

  @override
  String get mapPlayAnimation => 'Putar animasi perjalanan';

  @override
  String get sharePoster => 'Poster rute (PNG)';

  @override
  String get sharePhotoOverlay => 'Foto + statistik';

  @override
  String get sharePhotoOverlayDesc =>
      'Pilih foto dari galeri, statistik & rute ditimpakan di atasnya';

  @override
  String get shareSticker => 'Stiker statistik (PNG transparan)';

  @override
  String get shareStickerDesc =>
      'Tempelkan ke video/story lewat CapCut, Instagram, dll.';

  @override
  String get historyThisMonth => 'Bulan ini';

  @override
  String historyTripsCount(int count) {
    return '$count perjalanan';
  }

  @override
  String get poiButton => 'Cari SPBU & bengkel terdekat';

  @override
  String get poiSheetTitle => 'SPBU & bengkel terdekat';

  @override
  String get poiDisclaimer =>
      'Data OpenStreetMap. Posisi Anda dikirim ke server Overpass hanya saat menekan tombol pencarian.';

  @override
  String get poiFuel => 'SPBU';

  @override
  String get poiWorkshop => 'Bengkel';

  @override
  String get poiNone => 'Tidak ada SPBU atau bengkel dalam radius 5 km.';

  @override
  String get congestionLikely =>
      'Kemungkinan macet — kecepatan rendah cukup lama';

  @override
  String get congestionLabel => 'Perkiraan macet';

  @override
  String get congestionNote =>
      'Perkiraan dari pola kecepatan (merayap 3–15 km/j), bukan data lalu lintas resmi.';

  @override
  String tripFromTo(String from, String to) {
    return '$from → $to';
  }

  @override
  String get poiError =>
      'Gagal mencari lokasi sekitar. Periksa koneksi internet.';

  @override
  String get followPosition => 'Ikuti posisi saya';

  @override
  String get liveMapWaitingFix =>
      'Menunggu sinyal GPS... Peta akan muncul setelah posisi ditemukan.';

  @override
  String get liveMapIdleHint =>
      'Mulai perjalanan untuk melihat posisi Anda secara realtime di peta.';

  @override
  String homeGreetingNamed(String name) {
    return 'Halo, $name 👋';
  }

  @override
  String get homeGreetingAnon => 'Halo 👋';

  @override
  String get settingsKeepScreenOn => 'Layar tetap menyala saat merekam';

  @override
  String get settingsKeepScreenOnDesc =>
      'Berguna saat HP terpasang di holder. Sedikit menambah pemakaian baterai.';

  @override
  String get statsTitle => 'Rekap';

  @override
  String get drivingSectionTitle => 'Berkendara';

  @override
  String get settingsSpeedLimit => 'Peringatan batas kecepatan';

  @override
  String get settingsSpeedLimitOff => 'Nonaktif — ketuk untuk mengatur';

  @override
  String get serviceIntervalMotorcycle => 'Interval servis motor';

  @override
  String get serviceIntervalCar => 'Interval servis mobil';

  @override
  String get serviceIntervalOff => 'Nonaktif — ketuk untuk mengatur';

  @override
  String serviceIntervalEvery(String km) {
    return 'Setiap $km km';
  }

  @override
  String serviceDueTitle(String vehicle) {
    return 'Waktunya servis $vehicle';
  }

  @override
  String serviceDueBody(int km) {
    return 'Sudah ±$km km tercatat sejak servis terakhir.';
  }

  @override
  String get serviceMarkDone => 'Sudah servis';

  @override
  String get serviceMarked =>
      'Dicatat — pengingat dihitung ulang dari sekarang.';

  @override
  String get statsExportCsv => 'Ekspor CSV (semua perjalanan)';

  @override
  String get statsExportCsvDesc =>
      'File CSV bisa dibuka di Excel/Google Sheets untuk klaim atau pembukuan.';

  @override
  String get fuelSectionTitle => 'Konsumsi BBM';

  @override
  String get fuelSectionDesc =>
      'Masukkan konsumsi khas kendaraanmu (mis. 1 liter untuk 40 km berarti 40 km/L). Motivox memakai angka ini untuk memperkirakan BBM dan biaya tiap perjalanan dari jarak tempuh GPS.';

  @override
  String get fuelMotorcycleKmPerLiter => 'Konsumsi motor (km per liter)';

  @override
  String get fuelCarKmPerLiter => 'Konsumsi mobil (km per liter)';

  @override
  String get fuelPricePerLiter => 'Harga BBM per liter';

  @override
  String get fuelNotSet => 'Belum diatur — estimasi tidak ditampilkan';

  @override
  String get fuelInputHint => 'Kosongkan untuk menghapus';

  @override
  String get fuelEstimateLabel => 'Perkiraan BBM';

  @override
  String get fuelCostLabel => 'Perkiraan biaya';

  @override
  String get fuelEstimateNote =>
      'Estimasi dari angka km/L yang Anda masukkan, bukan pengukuran mesin.';

  @override
  String shareTripHeading(String date) {
    return 'Perjalanan $date';
  }

  @override
  String get settingsDataSection => 'Data & aplikasi';

  @override
  String get backupExport => 'Cadangkan riwayat';

  @override
  String get backupExportDesc =>
      'Simpan seluruh riwayat sebagai satu file cadangan (bisa ditaruh di Google Drive dll.)';

  @override
  String get backupImport => 'Pulihkan dari cadangan';

  @override
  String get backupImportDesc => 'Gabungkan file cadangan ke riwayat di HP ini';

  @override
  String backupImportSuccess(String count) {
    return '$count perjalanan dipulihkan dari cadangan';
  }

  @override
  String get backupImportNone =>
      'Tidak ada perjalanan baru di file cadangan itu';

  @override
  String get backupInvalidFile => 'File yang dipilih bukan cadangan Motivox';

  @override
  String get backupError => 'Gagal memproses cadangan';

  @override
  String get updateCheck => 'Periksa pembaruan';

  @override
  String updateCurrentVersion(String version) {
    return 'Versi terpasang: $version';
  }

  @override
  String updateAvailable(String build) {
    return 'Versi baru tersedia (build $build)';
  }

  @override
  String get updateUpToDate => 'Motivox sudah versi terbaru';

  @override
  String get updateCheckFailed =>
      'Tidak dapat memeriksa pembaruan. Periksa koneksi lalu coba lagi.';

  @override
  String get updateDownload => 'Unduh';

  @override
  String get shareLog => 'Bagikan log aplikasi';

  @override
  String get shareLogDesc =>
      'Membantu diagnosis masalah; tidak berisi kata sandi atau token';

  @override
  String get shareLogEmpty => 'Belum ada log untuk dibagikan';

  @override
  String get vehicleNotDriver => 'Bukan saya pengemudinya — buang perjalanan';

  @override
  String get vehicleNotDriverConfirmTitle => 'Buang perjalanan ini?';

  @override
  String get vehicleNotDriverConfirmBody =>
      'Perjalanan saat Anda menjadi penumpang akan dihapus dari riwayat dan tidak bisa dikembalikan.';

  @override
  String get vehicleNotDriverDeleted => 'Perjalanan dibuang';

  @override
  String get commonDiscard => 'Buang';

  @override
  String get permGuideIntro =>
      'Agar perekaman otomatis berjalan walau aplikasi tertutup, semua izin di bawah harus aktif dan izin lokasi disetel “Izinkan sepanjang waktu”.';

  @override
  String permAutostartTitle(String manufacturer) {
    return 'Autostart merek HP ($manufacturer)';
  }

  @override
  String get permAutostartDesc =>
      'Beberapa merek HP (Xiaomi, Oppo, Vivo, Realme, Huawei) menghentikan aplikasi latar belakang secara agresif. Buka pengaturan sistem dan aktifkan “Autostart” / “Mulai otomatis” untuk Motivox, lalu bebaskan Motivox dari pembatasan baterai.';

  @override
  String get settingsRoadSpeedLimit => 'Batas kecepatan dari peta (OSM)';

  @override
  String get settingsRoadSpeedLimitDesc =>
      'Saat merekam, batas resmi jalan yang sedang dilalui diambil dari OpenStreetMap dan dipakai alarm (posisi dikirim ke server OSM). Batas manual di atas menjadi cadangan.';
}

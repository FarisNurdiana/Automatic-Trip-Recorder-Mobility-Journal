import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In id, this message translates to:
  /// **'TripLog'**
  String get appTitle;

  /// No description provided for @commonRetry.
  ///
  /// In id, this message translates to:
  /// **'Coba lagi'**
  String get commonRetry;

  /// No description provided for @commonCancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In id, this message translates to:
  /// **'Simpan'**
  String get commonSave;

  /// No description provided for @commonDelete.
  ///
  /// In id, this message translates to:
  /// **'Hapus'**
  String get commonDelete;

  /// No description provided for @commonClose.
  ///
  /// In id, this message translates to:
  /// **'Tutup'**
  String get commonClose;

  /// No description provided for @commonLoading.
  ///
  /// In id, this message translates to:
  /// **'Memuat...'**
  String get commonLoading;

  /// No description provided for @commonError.
  ///
  /// In id, this message translates to:
  /// **'Terjadi kesalahan'**
  String get commonError;

  /// No description provided for @commonEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada data'**
  String get commonEmpty;

  /// No description provided for @commonOffline.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada koneksi internet'**
  String get commonOffline;

  /// No description provided for @commonOfflineBanner.
  ///
  /// In id, this message translates to:
  /// **'Offline — data disimpan lokal dan akan disinkronkan nanti'**
  String get commonOfflineBanner;

  /// No description provided for @commonSkip.
  ///
  /// In id, this message translates to:
  /// **'Lewati'**
  String get commonSkip;

  /// No description provided for @commonNext.
  ///
  /// In id, this message translates to:
  /// **'Lanjut'**
  String get commonNext;

  /// No description provided for @commonDone.
  ///
  /// In id, this message translates to:
  /// **'Selesai'**
  String get commonDone;

  /// No description provided for @commonConfirm.
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi'**
  String get commonConfirm;

  /// No description provided for @authLoginTitle.
  ///
  /// In id, this message translates to:
  /// **'Masuk'**
  String get authLoginTitle;

  /// No description provided for @authRegisterTitle.
  ///
  /// In id, this message translates to:
  /// **'Daftar'**
  String get authRegisterTitle;

  /// No description provided for @authEmail.
  ///
  /// In id, this message translates to:
  /// **'Email'**
  String get authEmail;

  /// No description provided for @authPassword.
  ///
  /// In id, this message translates to:
  /// **'Kata sandi'**
  String get authPassword;

  /// No description provided for @authDisplayName.
  ///
  /// In id, this message translates to:
  /// **'Nama tampilan'**
  String get authDisplayName;

  /// No description provided for @authLoginButton.
  ///
  /// In id, this message translates to:
  /// **'Masuk'**
  String get authLoginButton;

  /// No description provided for @authRegisterButton.
  ///
  /// In id, this message translates to:
  /// **'Daftar'**
  String get authRegisterButton;

  /// No description provided for @authForgotPassword.
  ///
  /// In id, this message translates to:
  /// **'Lupa kata sandi?'**
  String get authForgotPassword;

  /// No description provided for @authResetPasswordTitle.
  ///
  /// In id, this message translates to:
  /// **'Atur ulang kata sandi'**
  String get authResetPasswordTitle;

  /// No description provided for @authResetPasswordButton.
  ///
  /// In id, this message translates to:
  /// **'Kirim tautan atur ulang'**
  String get authResetPasswordButton;

  /// No description provided for @authResetPasswordSent.
  ///
  /// In id, this message translates to:
  /// **'Tautan atur ulang telah dikirim ke email Anda.'**
  String get authResetPasswordSent;

  /// No description provided for @authNoAccount.
  ///
  /// In id, this message translates to:
  /// **'Belum punya akun? Daftar'**
  String get authNoAccount;

  /// No description provided for @authHaveAccount.
  ///
  /// In id, this message translates to:
  /// **'Sudah punya akun? Masuk'**
  String get authHaveAccount;

  /// No description provided for @authLogout.
  ///
  /// In id, this message translates to:
  /// **'Keluar'**
  String get authLogout;

  /// No description provided for @authLocalMode.
  ///
  /// In id, this message translates to:
  /// **'Lanjut tanpa akun (mode lokal)'**
  String get authLocalMode;

  /// No description provided for @authLocalModeInfo.
  ///
  /// In id, this message translates to:
  /// **'Perjalanan disimpan di perangkat saja dan tidak disinkronkan.'**
  String get authLocalModeInfo;

  /// No description provided for @authEmailInvalid.
  ///
  /// In id, this message translates to:
  /// **'Format email tidak valid'**
  String get authEmailInvalid;

  /// No description provided for @authPasswordTooShort.
  ///
  /// In id, this message translates to:
  /// **'Kata sandi minimal 8 karakter'**
  String get authPasswordTooShort;

  /// No description provided for @authRegisterSuccess.
  ///
  /// In id, this message translates to:
  /// **'Pendaftaran berhasil. Periksa email Anda untuk konfirmasi.'**
  String get authRegisterSuccess;

  /// No description provided for @authLogoutUnsyncedWarning.
  ///
  /// In id, this message translates to:
  /// **'Masih ada data yang belum tersinkronisasi. Jika keluar sekarang, data tersebut tetap tersimpan di perangkat tetapi tidak akan diunggah sampai Anda masuk kembali.'**
  String get authLogoutUnsyncedWarning;

  /// No description provided for @homeTitle.
  ///
  /// In id, this message translates to:
  /// **'Beranda'**
  String get homeTitle;

  /// No description provided for @homeDetectionStatus.
  ///
  /// In id, this message translates to:
  /// **'Status deteksi'**
  String get homeDetectionStatus;

  /// No description provided for @homeStartTrip.
  ///
  /// In id, this message translates to:
  /// **'Mulai perjalanan'**
  String get homeStartTrip;

  /// No description provided for @homeLastTrip.
  ///
  /// In id, this message translates to:
  /// **'Perjalanan terakhir'**
  String get homeLastTrip;

  /// No description provided for @homeTotalDistance.
  ///
  /// In id, this message translates to:
  /// **'Total jarak'**
  String get homeTotalDistance;

  /// No description provided for @homeTripCount.
  ///
  /// In id, this message translates to:
  /// **'Jumlah perjalanan'**
  String get homeTripCount;

  /// No description provided for @homePermissions.
  ///
  /// In id, this message translates to:
  /// **'Izin'**
  String get homePermissions;

  /// No description provided for @homeSyncStatus.
  ///
  /// In id, this message translates to:
  /// **'Sinkronisasi'**
  String get homeSyncStatus;

  /// No description provided for @homeNoTrips.
  ///
  /// In id, this message translates to:
  /// **'Belum ada perjalanan tercatat'**
  String get homeNoTrips;

  /// No description provided for @homePermissionsIncomplete.
  ///
  /// In id, this message translates to:
  /// **'Beberapa izin belum diberikan'**
  String get homePermissionsIncomplete;

  /// No description provided for @homePermissionsComplete.
  ///
  /// In id, this message translates to:
  /// **'Semua izin lengkap'**
  String get homePermissionsComplete;

  /// No description provided for @stateIdle.
  ///
  /// In id, this message translates to:
  /// **'Mencari aktivitas'**
  String get stateIdle;

  /// No description provided for @statePossibleTrip.
  ///
  /// In id, this message translates to:
  /// **'Kemungkinan perjalanan terdeteksi'**
  String get statePossibleTrip;

  /// No description provided for @stateRecording.
  ///
  /// In id, this message translates to:
  /// **'Perjalanan sedang direkam'**
  String get stateRecording;

  /// No description provided for @stateTemporarilyStopped.
  ///
  /// In id, this message translates to:
  /// **'Berhenti sementara'**
  String get stateTemporarilyStopped;

  /// No description provided for @stateFinishing.
  ///
  /// In id, this message translates to:
  /// **'Menyelesaikan perjalanan'**
  String get stateFinishing;

  /// No description provided for @stateFinished.
  ///
  /// In id, this message translates to:
  /// **'Perjalanan tersimpan'**
  String get stateFinished;

  /// No description provided for @stateCancelled.
  ///
  /// In id, this message translates to:
  /// **'Perjalanan dibatalkan'**
  String get stateCancelled;

  /// No description provided for @syncPending.
  ///
  /// In id, this message translates to:
  /// **'Menunggu sinkronisasi'**
  String get syncPending;

  /// No description provided for @syncSyncing.
  ///
  /// In id, this message translates to:
  /// **'Menyinkronkan...'**
  String get syncSyncing;

  /// No description provided for @syncSynced.
  ///
  /// In id, this message translates to:
  /// **'Tersinkronisasi'**
  String get syncSynced;

  /// No description provided for @syncFailed.
  ///
  /// In id, this message translates to:
  /// **'Sinkronisasi gagal'**
  String get syncFailed;

  /// No description provided for @syncNow.
  ///
  /// In id, this message translates to:
  /// **'Sinkronkan sekarang'**
  String get syncNow;

  /// No description provided for @syncLocalOnly.
  ///
  /// In id, this message translates to:
  /// **'Mode lokal — sinkronisasi nonaktif'**
  String get syncLocalOnly;

  /// No description provided for @tripCurrentTitle.
  ///
  /// In id, this message translates to:
  /// **'Perjalanan saat ini'**
  String get tripCurrentTitle;

  /// No description provided for @tripPause.
  ///
  /// In id, this message translates to:
  /// **'Jeda'**
  String get tripPause;

  /// No description provided for @tripResume.
  ///
  /// In id, this message translates to:
  /// **'Lanjutkan'**
  String get tripResume;

  /// No description provided for @tripFinish.
  ///
  /// In id, this message translates to:
  /// **'Selesaikan'**
  String get tripFinish;

  /// No description provided for @tripCancel.
  ///
  /// In id, this message translates to:
  /// **'Batalkan'**
  String get tripCancel;

  /// No description provided for @tripCancelConfirm.
  ///
  /// In id, this message translates to:
  /// **'Batalkan perjalanan ini? Data perjalanan ini akan dihapus.'**
  String get tripCancelConfirm;

  /// No description provided for @tripDistance.
  ///
  /// In id, this message translates to:
  /// **'Jarak'**
  String get tripDistance;

  /// No description provided for @tripDuration.
  ///
  /// In id, this message translates to:
  /// **'Durasi'**
  String get tripDuration;

  /// No description provided for @tripSpeed.
  ///
  /// In id, this message translates to:
  /// **'Kecepatan'**
  String get tripSpeed;

  /// No description provided for @tripMaxSpeed.
  ///
  /// In id, this message translates to:
  /// **'Kecepatan maks'**
  String get tripMaxSpeed;

  /// No description provided for @tripAvgSpeed.
  ///
  /// In id, this message translates to:
  /// **'Kecepatan rata-rata'**
  String get tripAvgSpeed;

  /// No description provided for @tripMovingAvgSpeed.
  ///
  /// In id, this message translates to:
  /// **'Rata-rata bergerak'**
  String get tripMovingAvgSpeed;

  /// No description provided for @tripMovingTime.
  ///
  /// In id, this message translates to:
  /// **'Waktu bergerak'**
  String get tripMovingTime;

  /// No description provided for @tripStoppedTime.
  ///
  /// In id, this message translates to:
  /// **'Waktu berhenti'**
  String get tripStoppedTime;

  /// No description provided for @tripDeparture.
  ///
  /// In id, this message translates to:
  /// **'Berangkat'**
  String get tripDeparture;

  /// No description provided for @tripArrival.
  ///
  /// In id, this message translates to:
  /// **'Tiba'**
  String get tripArrival;

  /// No description provided for @tripStops.
  ///
  /// In id, this message translates to:
  /// **'Lokasi berhenti'**
  String get tripStops;

  /// No description provided for @tripStopCount.
  ///
  /// In id, this message translates to:
  /// **'Jumlah berhenti'**
  String get tripStopCount;

  /// No description provided for @tripNoPoints.
  ///
  /// In id, this message translates to:
  /// **'Perjalanan tidak memiliki cukup titik GPS'**
  String get tripNoPoints;

  /// No description provided for @tripTooShort.
  ///
  /// In id, this message translates to:
  /// **'Perjalanan terlalu pendek untuk disimpan'**
  String get tripTooShort;

  /// No description provided for @tripPoints.
  ///
  /// In id, this message translates to:
  /// **'Titik GPS'**
  String get tripPoints;

  /// No description provided for @tripSpeedChart.
  ///
  /// In id, this message translates to:
  /// **'Grafik kecepatan'**
  String get tripSpeedChart;

  /// No description provided for @tripFitRoute.
  ///
  /// In id, this message translates to:
  /// **'Tampilkan seluruh rute'**
  String get tripFitRoute;

  /// No description provided for @tripStart.
  ///
  /// In id, this message translates to:
  /// **'Mulai'**
  String get tripStart;

  /// No description provided for @tripEnd.
  ///
  /// In id, this message translates to:
  /// **'Selesai'**
  String get tripEnd;

  /// No description provided for @tripExportGpx.
  ///
  /// In id, this message translates to:
  /// **'Ekspor GPX'**
  String get tripExportGpx;

  /// No description provided for @tripExportGpxDesc.
  ///
  /// In id, this message translates to:
  /// **'Bagikan rute sebagai file GPX (dapat diimpor ke Strava, Google Earth, dll.)'**
  String get tripExportGpxDesc;

  /// No description provided for @tripExportFailed.
  ///
  /// In id, this message translates to:
  /// **'Ekspor gagal. Perjalanan tidak memiliki titik rute.'**
  String get tripExportFailed;

  /// No description provided for @historyTitle.
  ///
  /// In id, this message translates to:
  /// **'Riwayat perjalanan'**
  String get historyTitle;

  /// No description provided for @historyEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada perjalanan. Mulai perjalanan pertama Anda dari beranda.'**
  String get historyEmpty;

  /// No description provided for @vehicleConfirmTitle.
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi kendaraan'**
  String get vehicleConfirmTitle;

  /// No description provided for @vehicleConfirmMessage.
  ///
  /// In id, this message translates to:
  /// **'Kami mendeteksi perjalanan menggunakan kendaraan.'**
  String get vehicleConfirmMessage;

  /// No description provided for @vehicleConfirmQuestion.
  ///
  /// In id, this message translates to:
  /// **'Jenis kendaraan:'**
  String get vehicleConfirmQuestion;

  /// No description provided for @vehiclePrediction.
  ///
  /// In id, this message translates to:
  /// **'Prediksi: {vehicle}'**
  String vehiclePrediction(String vehicle);

  /// No description provided for @vehicleConfidence.
  ///
  /// In id, this message translates to:
  /// **'Confidence: {percent}%'**
  String vehicleConfidence(String percent);

  /// No description provided for @vehicleCar.
  ///
  /// In id, this message translates to:
  /// **'Mobil'**
  String get vehicleCar;

  /// No description provided for @vehicleMotorcycle.
  ///
  /// In id, this message translates to:
  /// **'Motor'**
  String get vehicleMotorcycle;

  /// No description provided for @vehicleBus.
  ///
  /// In id, this message translates to:
  /// **'Bus'**
  String get vehicleBus;

  /// No description provided for @vehicleTruck.
  ///
  /// In id, this message translates to:
  /// **'Truk'**
  String get vehicleTruck;

  /// No description provided for @vehicleTrain.
  ///
  /// In id, this message translates to:
  /// **'Kereta'**
  String get vehicleTrain;

  /// No description provided for @vehicleOther.
  ///
  /// In id, this message translates to:
  /// **'Lainnya'**
  String get vehicleOther;

  /// No description provided for @vehicleUnknown.
  ///
  /// In id, this message translates to:
  /// **'Tidak diketahui'**
  String get vehicleUnknown;

  /// No description provided for @profileTitle.
  ///
  /// In id, this message translates to:
  /// **'Profil'**
  String get profileTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan'**
  String get settingsTitle;

  /// No description provided for @settingsAutoDetection.
  ///
  /// In id, this message translates to:
  /// **'Deteksi perjalanan otomatis'**
  String get settingsAutoDetection;

  /// No description provided for @settingsAutoDetectionDesc.
  ///
  /// In id, this message translates to:
  /// **'Mulai dan akhiri perekaman secara otomatis berdasarkan aktivitas kendaraan.'**
  String get settingsAutoDetectionDesc;

  /// No description provided for @settingsSensorLogging.
  ///
  /// In id, this message translates to:
  /// **'Perekaman data sensor'**
  String get settingsSensorLogging;

  /// No description provided for @settingsSensorLoggingDesc.
  ///
  /// In id, this message translates to:
  /// **'Merekam accelerometer dan gyroscope selama perjalanan untuk pengembangan model klasifikasi kendaraan.'**
  String get settingsSensorLoggingDesc;

  /// No description provided for @settingsSensorLoggingWarning.
  ///
  /// In id, this message translates to:
  /// **'Perekaman sensor meningkatkan penggunaan baterai.'**
  String get settingsSensorLoggingWarning;

  /// No description provided for @settingsMountPosition.
  ///
  /// In id, this message translates to:
  /// **'Posisi ponsel'**
  String get settingsMountPosition;

  /// No description provided for @settingsMountPositionDesc.
  ///
  /// In id, this message translates to:
  /// **'Posisi ponsel memengaruhi karakteristik data sensor.'**
  String get settingsMountPositionDesc;

  /// No description provided for @mountDashboard.
  ///
  /// In id, this message translates to:
  /// **'Holder dashboard'**
  String get mountDashboard;

  /// No description provided for @mountHandlebar.
  ///
  /// In id, this message translates to:
  /// **'Holder stang motor'**
  String get mountHandlebar;

  /// No description provided for @mountPocket.
  ///
  /// In id, this message translates to:
  /// **'Saku'**
  String get mountPocket;

  /// No description provided for @mountBag.
  ///
  /// In id, this message translates to:
  /// **'Tas'**
  String get mountBag;

  /// No description provided for @mountCupHolder.
  ///
  /// In id, this message translates to:
  /// **'Cup holder'**
  String get mountCupHolder;

  /// No description provided for @mountUnknown.
  ///
  /// In id, this message translates to:
  /// **'Tidak diketahui'**
  String get mountUnknown;

  /// No description provided for @settingsLanguage.
  ///
  /// In id, this message translates to:
  /// **'Bahasa'**
  String get settingsLanguage;

  /// No description provided for @settingsTheme.
  ///
  /// In id, this message translates to:
  /// **'Tema'**
  String get settingsTheme;

  /// No description provided for @themeSystem.
  ///
  /// In id, this message translates to:
  /// **'Ikuti sistem'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In id, this message translates to:
  /// **'Terang'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In id, this message translates to:
  /// **'Gelap'**
  String get themeDark;

  /// No description provided for @settingsPermissions.
  ///
  /// In id, this message translates to:
  /// **'Diagnostik izin'**
  String get settingsPermissions;

  /// No description provided for @settingsPrivacy.
  ///
  /// In id, this message translates to:
  /// **'Privasi & keamanan'**
  String get settingsPrivacy;

  /// No description provided for @privacyTitle.
  ///
  /// In id, this message translates to:
  /// **'Privasi & keamanan'**
  String get privacyTitle;

  /// No description provided for @privacyDeleteAllLocal.
  ///
  /// In id, this message translates to:
  /// **'Hapus semua data lokal'**
  String get privacyDeleteAllLocal;

  /// No description provided for @privacyDeleteAllLocalConfirm.
  ///
  /// In id, this message translates to:
  /// **'Semua perjalanan dan data sensor di perangkat ini akan dihapus permanen. Lanjutkan?'**
  String get privacyDeleteAllLocalConfirm;

  /// No description provided for @privacyDeleteAllCloud.
  ///
  /// In id, this message translates to:
  /// **'Hapus semua data cloud saya'**
  String get privacyDeleteAllCloud;

  /// No description provided for @privacyDeleteAllCloudConfirm.
  ///
  /// In id, this message translates to:
  /// **'Semua perjalanan Anda di server akan dihapus permanen. Lanjutkan?'**
  String get privacyDeleteAllCloudConfirm;

  /// No description provided for @privacyDeleteTrip.
  ///
  /// In id, this message translates to:
  /// **'Hapus perjalanan'**
  String get privacyDeleteTrip;

  /// No description provided for @privacyDeleteTripConfirm.
  ///
  /// In id, this message translates to:
  /// **'Hapus perjalanan ini secara permanen?'**
  String get privacyDeleteTripConfirm;

  /// No description provided for @privacyDataDeleted.
  ///
  /// In id, this message translates to:
  /// **'Data berhasil dihapus'**
  String get privacyDataDeleted;

  /// No description provided for @permLocation.
  ///
  /// In id, this message translates to:
  /// **'Lokasi'**
  String get permLocation;

  /// No description provided for @permLocationDesc.
  ///
  /// In id, this message translates to:
  /// **'Digunakan untuk merekam rute perjalanan.'**
  String get permLocationDesc;

  /// No description provided for @permBackgroundLocation.
  ///
  /// In id, this message translates to:
  /// **'Lokasi latar belakang'**
  String get permBackgroundLocation;

  /// No description provided for @permBackgroundLocationDesc.
  ///
  /// In id, this message translates to:
  /// **'Digunakan agar perjalanan tetap direkam ketika layar mati atau aplikasi diminimalkan.'**
  String get permBackgroundLocationDesc;

  /// No description provided for @permActivityRecognition.
  ///
  /// In id, this message translates to:
  /// **'Pengenalan aktivitas'**
  String get permActivityRecognition;

  /// No description provided for @permActivityRecognitionDesc.
  ///
  /// In id, this message translates to:
  /// **'Digunakan untuk mendeteksi ketika perjalanan menggunakan kendaraan dimulai atau selesai.'**
  String get permActivityRecognitionDesc;

  /// No description provided for @permMotionFitness.
  ///
  /// In id, this message translates to:
  /// **'Gerakan & kebugaran'**
  String get permMotionFitness;

  /// No description provided for @permMotionFitnessDesc.
  ///
  /// In id, this message translates to:
  /// **'Digunakan untuk mengenali aktivitas seperti berjalan, diam, atau menggunakan kendaraan.'**
  String get permMotionFitnessDesc;

  /// No description provided for @permNotifications.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi'**
  String get permNotifications;

  /// No description provided for @permNotificationsDesc.
  ///
  /// In id, this message translates to:
  /// **'Digunakan untuk menunjukkan bahwa perjalanan sedang direkam.'**
  String get permNotificationsDesc;

  /// No description provided for @permBatteryOptimization.
  ///
  /// In id, this message translates to:
  /// **'Pengecualian optimasi baterai'**
  String get permBatteryOptimization;

  /// No description provided for @permBatteryOptimizationDesc.
  ///
  /// In id, this message translates to:
  /// **'Mencegah sistem menghentikan perekaman di latar belakang.'**
  String get permBatteryOptimizationDesc;

  /// No description provided for @permGranted.
  ///
  /// In id, this message translates to:
  /// **'Diberikan'**
  String get permGranted;

  /// No description provided for @permDenied.
  ///
  /// In id, this message translates to:
  /// **'Ditolak'**
  String get permDenied;

  /// No description provided for @permActive.
  ///
  /// In id, this message translates to:
  /// **'Aktif'**
  String get permActive;

  /// No description provided for @permInactive.
  ///
  /// In id, this message translates to:
  /// **'Tidak aktif'**
  String get permInactive;

  /// No description provided for @permRequest.
  ///
  /// In id, this message translates to:
  /// **'Minta izin'**
  String get permRequest;

  /// No description provided for @permOpenSettings.
  ///
  /// In id, this message translates to:
  /// **'Buka pengaturan'**
  String get permOpenSettings;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In id, this message translates to:
  /// **'Selamat datang di TripLog'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeDesc.
  ///
  /// In id, this message translates to:
  /// **'Catat perjalanan Anda secara otomatis. TripLog mendeteksi saat Anda menggunakan kendaraan, merekam rute, dan membuat ringkasan perjalanan.'**
  String get onboardingWelcomeDesc;

  /// No description provided for @onboardingPermissionsTitle.
  ///
  /// In id, this message translates to:
  /// **'Izin yang dibutuhkan'**
  String get onboardingPermissionsTitle;

  /// No description provided for @onboardingPermissionsDesc.
  ///
  /// In id, this message translates to:
  /// **'Agar perekaman otomatis berfungsi, TripLog membutuhkan beberapa izin. Setiap izin dijelaskan sebelum diminta.'**
  String get onboardingPermissionsDesc;

  /// No description provided for @onboardingStart.
  ///
  /// In id, this message translates to:
  /// **'Mulai'**
  String get onboardingStart;

  /// No description provided for @errorPermissionDenied.
  ///
  /// In id, this message translates to:
  /// **'Izin ditolak. Beberapa fitur tidak akan berfungsi.'**
  String get errorPermissionDenied;

  /// No description provided for @errorGpsDisabled.
  ///
  /// In id, this message translates to:
  /// **'GPS tidak aktif. Aktifkan layanan lokasi untuk merekam perjalanan.'**
  String get errorGpsDisabled;

  /// No description provided for @errorActivityUnavailable.
  ///
  /// In id, this message translates to:
  /// **'Pengenalan aktivitas tidak tersedia di perangkat ini. Gunakan perekaman manual.'**
  String get errorActivityUnavailable;

  /// No description provided for @errorSupabaseUnavailable.
  ///
  /// In id, this message translates to:
  /// **'Server tidak dapat diakses. Data tetap tersimpan lokal.'**
  String get errorSupabaseUnavailable;

  /// No description provided for @errorDatabase.
  ///
  /// In id, this message translates to:
  /// **'Terjadi kesalahan pada penyimpanan lokal.'**
  String get errorDatabase;

  /// No description provided for @errorSensorUnavailable.
  ///
  /// In id, this message translates to:
  /// **'Sensor tidak tersedia di perangkat ini.'**
  String get errorSensorUnavailable;

  /// No description provided for @errorTripTooFewPoints.
  ///
  /// In id, this message translates to:
  /// **'Perjalanan tidak disimpan karena titik GPS terlalu sedikit.'**
  String get errorTripTooFewPoints;

  /// No description provided for @errorEnvMissing.
  ///
  /// In id, this message translates to:
  /// **'Konfigurasi Supabase belum diisi'**
  String get errorEnvMissing;

  /// No description provided for @errorEnvMissingDesc.
  ///
  /// In id, this message translates to:
  /// **'Salin .env.example menjadi .env lalu isi SUPABASE_URL dan SUPABASE_ANON_KEY. Anda tetap dapat menggunakan mode lokal tanpa akun.'**
  String get errorEnvMissingDesc;

  /// No description provided for @unitKm.
  ///
  /// In id, this message translates to:
  /// **'km'**
  String get unitKm;

  /// No description provided for @unitKmh.
  ///
  /// In id, this message translates to:
  /// **'km/jam'**
  String get unitKmh;

  /// No description provided for @unitHour.
  ///
  /// In id, this message translates to:
  /// **'jam'**
  String get unitHour;

  /// No description provided for @unitMinute.
  ///
  /// In id, this message translates to:
  /// **'menit'**
  String get unitMinute;

  /// No description provided for @recoveredTripTitle.
  ///
  /// In id, this message translates to:
  /// **'Perjalanan dipulihkan'**
  String get recoveredTripTitle;

  /// No description provided for @recoveredTripMessage.
  ///
  /// In id, this message translates to:
  /// **'Perjalanan yang sedang berlangsung ditemukan dan dilanjutkan setelah aplikasi ditutup.'**
  String get recoveredTripMessage;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

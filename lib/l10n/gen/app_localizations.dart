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
  /// **'Motivox'**
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
  /// **'Selamat datang di Motivox'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeDesc.
  ///
  /// In id, this message translates to:
  /// **'Catat perjalanan Anda secara otomatis. Motivox mendeteksi saat Anda menggunakan kendaraan, merekam rute, dan membuat ringkasan perjalanan.'**
  String get onboardingWelcomeDesc;

  /// No description provided for @onboardingPermissionsTitle.
  ///
  /// In id, this message translates to:
  /// **'Izin yang dibutuhkan'**
  String get onboardingPermissionsTitle;

  /// No description provided for @onboardingPermissionsDesc.
  ///
  /// In id, this message translates to:
  /// **'Agar perekaman otomatis berfungsi, Motivox membutuhkan beberapa izin. Setiap izin dijelaskan sebelum diminta.'**
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

  /// No description provided for @stateShortStop.
  ///
  /// In id, this message translates to:
  /// **'Berhenti sebentar'**
  String get stateShortStop;

  /// No description provided for @stateRestStopCandidate.
  ///
  /// In id, this message translates to:
  /// **'Berhenti cukup lama'**
  String get stateRestStopCandidate;

  /// No description provided for @stateDestinationCandidate.
  ///
  /// In id, this message translates to:
  /// **'Kemungkinan sudah sampai'**
  String get stateDestinationCandidate;

  /// No description provided for @stopQuestion30Title.
  ///
  /// In id, this message translates to:
  /// **'Anda sudah berhenti selama 30 menit'**
  String get stopQuestion30Title;

  /// No description provided for @stopQuestion30Body.
  ///
  /// In id, this message translates to:
  /// **'Apakah Anda sudah sampai di tujuan atau sedang beristirahat?'**
  String get stopQuestion30Body;

  /// No description provided for @stopQuestion5hTitle.
  ///
  /// In id, this message translates to:
  /// **'Perjalanan kemungkinan telah selesai'**
  String get stopQuestion5hTitle;

  /// No description provided for @stopQuestion5hBody.
  ///
  /// In id, this message translates to:
  /// **'Anda berada di lokasi yang sama selama lebih dari 5 jam.'**
  String get stopQuestion5hBody;

  /// No description provided for @answerArrived.
  ///
  /// In id, this message translates to:
  /// **'Sudah sampai'**
  String get answerArrived;

  /// No description provided for @answerResting.
  ///
  /// In id, this message translates to:
  /// **'Sedang istirahat'**
  String get answerResting;

  /// No description provided for @answerContinue.
  ///
  /// In id, this message translates to:
  /// **'Lanjutkan perjalanan'**
  String get answerContinue;

  /// No description provided for @finishTripAction.
  ///
  /// In id, this message translates to:
  /// **'Selesaikan perjalanan'**
  String get finishTripAction;

  /// No description provided for @keepTripAction.
  ///
  /// In id, this message translates to:
  /// **'Tetap lanjutkan'**
  String get keepTripAction;

  /// No description provided for @finishedAutomaticallyBadge.
  ///
  /// In id, this message translates to:
  /// **'Diselesaikan otomatis'**
  String get finishedAutomaticallyBadge;

  /// No description provided for @editArrivalTime.
  ///
  /// In id, this message translates to:
  /// **'Koreksi waktu tiba'**
  String get editArrivalTime;

  /// No description provided for @arrivalUpdated.
  ///
  /// In id, this message translates to:
  /// **'Waktu tiba diperbarui'**
  String get arrivalUpdated;

  /// No description provided for @mapPageTitle.
  ///
  /// In id, this message translates to:
  /// **'Peta perjalanan'**
  String get mapPageTitle;

  /// No description provided for @mapRecenter.
  ///
  /// In id, this message translates to:
  /// **'Kembali ke rute'**
  String get mapRecenter;

  /// No description provided for @mapZoomIn.
  ///
  /// In id, this message translates to:
  /// **'Perbesar'**
  String get mapZoomIn;

  /// No description provided for @mapZoomOut.
  ///
  /// In id, this message translates to:
  /// **'Perkecil'**
  String get mapZoomOut;

  /// No description provided for @mapOpenFullscreen.
  ///
  /// In id, this message translates to:
  /// **'Buka peta layar penuh'**
  String get mapOpenFullscreen;

  /// No description provided for @gpsQuality.
  ///
  /// In id, this message translates to:
  /// **'Kualitas GPS'**
  String get gpsQuality;

  /// No description provided for @gpsGood.
  ///
  /// In id, this message translates to:
  /// **'Baik'**
  String get gpsGood;

  /// No description provided for @gpsFair.
  ///
  /// In id, this message translates to:
  /// **'Sedang'**
  String get gpsFair;

  /// No description provided for @gpsPoor.
  ///
  /// In id, this message translates to:
  /// **'Buruk'**
  String get gpsPoor;

  /// No description provided for @stopSheetTitle.
  ///
  /// In id, this message translates to:
  /// **'Berhenti {number}'**
  String stopSheetTitle(int number);

  /// No description provided for @stopArrivalTime.
  ///
  /// In id, this message translates to:
  /// **'Waktu tiba'**
  String get stopArrivalTime;

  /// No description provided for @stopDepartureTime.
  ///
  /// In id, this message translates to:
  /// **'Waktu berangkat'**
  String get stopDepartureTime;

  /// No description provided for @stopDurationLabel.
  ///
  /// In id, this message translates to:
  /// **'Durasi'**
  String get stopDurationLabel;

  /// No description provided for @stopLocationLabel.
  ///
  /// In id, this message translates to:
  /// **'Lokasi'**
  String get stopLocationLabel;

  /// No description provided for @stopTypeLabel.
  ///
  /// In id, this message translates to:
  /// **'Jenis berhenti'**
  String get stopTypeLabel;

  /// No description provided for @stopUnconfirmed.
  ///
  /// In id, this message translates to:
  /// **'Belum dikonfirmasi'**
  String get stopUnconfirmed;

  /// No description provided for @stopTypeRest.
  ///
  /// In id, this message translates to:
  /// **'Istirahat'**
  String get stopTypeRest;

  /// No description provided for @stopTypeParking.
  ///
  /// In id, this message translates to:
  /// **'Parkir'**
  String get stopTypeParking;

  /// No description provided for @stopTypeFood.
  ///
  /// In id, this message translates to:
  /// **'Membeli makanan'**
  String get stopTypeFood;

  /// No description provided for @stopTypeFuel.
  ///
  /// In id, this message translates to:
  /// **'Isi bahan bakar'**
  String get stopTypeFuel;

  /// No description provided for @stopTypeVisit.
  ///
  /// In id, this message translates to:
  /// **'Mengunjungi lokasi'**
  String get stopTypeVisit;

  /// No description provided for @stopTypeTraffic.
  ///
  /// In id, this message translates to:
  /// **'Kemacetan'**
  String get stopTypeTraffic;

  /// No description provided for @stopTypeDestination.
  ///
  /// In id, this message translates to:
  /// **'Tujuan'**
  String get stopTypeDestination;

  /// No description provided for @stopTypeOther.
  ///
  /// In id, this message translates to:
  /// **'Lainnya'**
  String get stopTypeOther;

  /// No description provided for @stopLabelSaved.
  ///
  /// In id, this message translates to:
  /// **'Label berhenti disimpan'**
  String get stopLabelSaved;

  /// No description provided for @vehicleBicycle.
  ///
  /// In id, this message translates to:
  /// **'Sepeda'**
  String get vehicleBicycle;

  /// No description provided for @vehicleQuestionHigh.
  ///
  /// In id, this message translates to:
  /// **'Apakah tadi Anda menggunakan {vehicle}?'**
  String vehicleQuestionHigh(String vehicle);

  /// No description provided for @vehiclePredictionInfo.
  ///
  /// In id, this message translates to:
  /// **'Prediksi Motivox berdasarkan pola perjalanan.'**
  String get vehiclePredictionInfo;

  /// No description provided for @vehicleConfidenceLabel.
  ///
  /// In id, this message translates to:
  /// **'Keyakinan: {percent}%'**
  String vehicleConfidenceLabel(String percent);

  /// No description provided for @vehicleYes.
  ///
  /// In id, this message translates to:
  /// **'Ya, {vehicle}'**
  String vehicleYes(String vehicle);

  /// No description provided for @vehicleNo.
  ///
  /// In id, this message translates to:
  /// **'Bukan'**
  String get vehicleNo;

  /// No description provided for @vehicleQuestionMedium.
  ///
  /// In id, this message translates to:
  /// **'Kemungkinan Anda menggunakan {vehicle}'**
  String vehicleQuestionMedium(String vehicle);

  /// No description provided for @vehicleQuestionMediumAsk.
  ///
  /// In id, this message translates to:
  /// **'Apakah prediksi ini benar?'**
  String get vehicleQuestionMediumAsk;

  /// No description provided for @vehicleCorrect.
  ///
  /// In id, this message translates to:
  /// **'Benar'**
  String get vehicleCorrect;

  /// No description provided for @vehicleChange.
  ///
  /// In id, this message translates to:
  /// **'Ubah kendaraan'**
  String get vehicleChange;

  /// No description provided for @vehicleQuestionLow.
  ///
  /// In id, this message translates to:
  /// **'Kendaraan apa yang Anda gunakan?'**
  String get vehicleQuestionLow;

  /// No description provided for @shareTripTitle.
  ///
  /// In id, this message translates to:
  /// **'Bagikan perjalanan'**
  String get shareTripTitle;

  /// No description provided for @sharePng.
  ///
  /// In id, this message translates to:
  /// **'Gambar PNG'**
  String get sharePng;

  /// No description provided for @shareGpx.
  ///
  /// In id, this message translates to:
  /// **'File GPX'**
  String get shareGpx;

  /// No description provided for @shareGeoJson.
  ///
  /// In id, this message translates to:
  /// **'File GeoJSON'**
  String get shareGeoJson;

  /// No description provided for @shareCopySummary.
  ///
  /// In id, this message translates to:
  /// **'Salin ringkasan'**
  String get shareCopySummary;

  /// No description provided for @shareCopied.
  ///
  /// In id, this message translates to:
  /// **'Ringkasan disalin ke clipboard'**
  String get shareCopied;

  /// No description provided for @sharePreparing.
  ///
  /// In id, this message translates to:
  /// **'Menyiapkan gambar perjalanan...'**
  String get sharePreparing;

  /// No description provided for @sharePrivacyTitle.
  ///
  /// In id, this message translates to:
  /// **'Pilihan privasi'**
  String get sharePrivacyTitle;

  /// No description provided for @shareShowStart.
  ///
  /// In id, this message translates to:
  /// **'Tampilkan lokasi awal'**
  String get shareShowStart;

  /// No description provided for @shareShowEnd.
  ///
  /// In id, this message translates to:
  /// **'Tampilkan lokasi akhir'**
  String get shareShowEnd;

  /// No description provided for @shareShowUserName.
  ///
  /// In id, this message translates to:
  /// **'Tampilkan nama pengguna'**
  String get shareShowUserName;

  /// No description provided for @shareShowMaxSpeed.
  ///
  /// In id, this message translates to:
  /// **'Tampilkan kecepatan maksimum'**
  String get shareShowMaxSpeed;

  /// No description provided for @sharePrivacyMode.
  ///
  /// In id, this message translates to:
  /// **'Mode privasi'**
  String get sharePrivacyMode;

  /// No description provided for @sharePrivacyModeDesc.
  ///
  /// In id, this message translates to:
  /// **'Memotong ±300 m di awal dan akhir rute agar lokasi rumah tidak terlihat.'**
  String get sharePrivacyModeDesc;

  /// No description provided for @shareContinue.
  ///
  /// In id, this message translates to:
  /// **'Lanjut'**
  String get shareContinue;

  /// No description provided for @signsTitle.
  ///
  /// In id, this message translates to:
  /// **'Rambu lalu lintas'**
  String get signsTitle;

  /// No description provided for @signsSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Referensi edukasi singkat rambu yang berlaku di Indonesia. Bukan pengganti aturan resmi atau alat navigasi.'**
  String get signsSubtitle;

  /// No description provided for @signsSearchHint.
  ///
  /// In id, this message translates to:
  /// **'Cari rambu... (mis. parkir, kecepatan, dilarang)'**
  String get signsSearchHint;

  /// No description provided for @signsAll.
  ///
  /// In id, this message translates to:
  /// **'Semua'**
  String get signsAll;

  /// No description provided for @signsCatWarning.
  ///
  /// In id, this message translates to:
  /// **'Peringatan'**
  String get signsCatWarning;

  /// No description provided for @signsCatProhibition.
  ///
  /// In id, this message translates to:
  /// **'Larangan'**
  String get signsCatProhibition;

  /// No description provided for @signsCatMandatory.
  ///
  /// In id, this message translates to:
  /// **'Perintah'**
  String get signsCatMandatory;

  /// No description provided for @signsCatGuide.
  ///
  /// In id, this message translates to:
  /// **'Petunjuk'**
  String get signsCatGuide;

  /// No description provided for @signsCatTemporary.
  ///
  /// In id, this message translates to:
  /// **'Sementara'**
  String get signsCatTemporary;

  /// No description provided for @signsCatMarking.
  ///
  /// In id, this message translates to:
  /// **'Marka jalan'**
  String get signsCatMarking;

  /// No description provided for @signsMeaning.
  ///
  /// In id, this message translates to:
  /// **'Arti'**
  String get signsMeaning;

  /// No description provided for @signsAction.
  ///
  /// In id, this message translates to:
  /// **'Tindakan'**
  String get signsAction;

  /// No description provided for @signsSafetyNote.
  ///
  /// In id, this message translates to:
  /// **'Catatan keselamatan'**
  String get signsSafetyNote;

  /// No description provided for @signsEmpty.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada rambu yang cocok dengan pencarian.'**
  String get signsEmpty;

  /// No description provided for @signsFavorites.
  ///
  /// In id, this message translates to:
  /// **'Favorit'**
  String get signsFavorites;

  /// No description provided for @signsSourceNote.
  ///
  /// In id, this message translates to:
  /// **'Sumber: UU No. 22/2009 & Permenhub PM 13/2014 (lihat dokumentasi).'**
  String get signsSourceNote;

  /// No description provided for @tripSaved.
  ///
  /// In id, this message translates to:
  /// **'Perjalanan tersimpan'**
  String get tripSaved;

  /// No description provided for @errorTripNoGps.
  ///
  /// In id, this message translates to:
  /// **'Perjalanan tidak tersimpan: tidak ada titik GPS yang terekam. Periksa GPS dan izin lokasi, lalu coba lagi.'**
  String get errorTripNoGps;

  /// No description provided for @errorNotSignedIn.
  ///
  /// In id, this message translates to:
  /// **'Masuk atau aktifkan mode lokal terlebih dahulu untuk merekam perjalanan.'**
  String get errorNotSignedIn;

  /// No description provided for @navHome.
  ///
  /// In id, this message translates to:
  /// **'Beranda'**
  String get navHome;

  /// No description provided for @navHistory.
  ///
  /// In id, this message translates to:
  /// **'Riwayat'**
  String get navHistory;

  /// No description provided for @navSigns.
  ///
  /// In id, this message translates to:
  /// **'Rambu'**
  String get navSigns;

  /// No description provided for @navSettings.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan'**
  String get navSettings;

  /// No description provided for @detectionLogTitle.
  ///
  /// In id, this message translates to:
  /// **'Log deteksi'**
  String get detectionLogTitle;

  /// No description provided for @detectionLogEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada aktivitas deteksi. Log terisi otomatis saat aplikasi memantau atau merekam perjalanan.'**
  String get detectionLogEmpty;

  /// No description provided for @detectionLogDesc.
  ///
  /// In id, this message translates to:
  /// **'Keputusan deteksi terbaru (mengapa perjalanan dimulai, ditunda, atau titik GPS ditolak).'**
  String get detectionLogDesc;

  /// No description provided for @homeHeroReady.
  ///
  /// In id, this message translates to:
  /// **'Siap mencatat perjalananmu'**
  String get homeHeroReady;

  /// No description provided for @homeHeroReadyDesc.
  ///
  /// In id, this message translates to:
  /// **'Deteksi otomatis aktif — atau mulai manual kapan saja.'**
  String get homeHeroReadyDesc;

  /// No description provided for @homeHeroActiveDesc.
  ///
  /// In id, this message translates to:
  /// **'Perjalanan sedang direkam di latar belakang.'**
  String get homeHeroActiveDesc;

  /// No description provided for @homeSeeAll.
  ///
  /// In id, this message translates to:
  /// **'Lihat semua'**
  String get homeSeeAll;

  /// No description provided for @homeQuickMenu.
  ///
  /// In id, this message translates to:
  /// **'Menu cepat'**
  String get homeQuickMenu;

  /// No description provided for @mapPlayAnimation.
  ///
  /// In id, this message translates to:
  /// **'Putar animasi perjalanan'**
  String get mapPlayAnimation;

  /// No description provided for @sharePoster.
  ///
  /// In id, this message translates to:
  /// **'Poster rute (PNG)'**
  String get sharePoster;

  /// No description provided for @sharePhotoOverlay.
  ///
  /// In id, this message translates to:
  /// **'Foto + statistik'**
  String get sharePhotoOverlay;

  /// No description provided for @sharePhotoOverlayDesc.
  ///
  /// In id, this message translates to:
  /// **'Pilih foto dari galeri, statistik & rute ditimpakan di atasnya'**
  String get sharePhotoOverlayDesc;

  /// No description provided for @shareSticker.
  ///
  /// In id, this message translates to:
  /// **'Stiker statistik (PNG transparan)'**
  String get shareSticker;

  /// No description provided for @shareStickerDesc.
  ///
  /// In id, this message translates to:
  /// **'Tempelkan ke video/story lewat CapCut, Instagram, dll.'**
  String get shareStickerDesc;

  /// No description provided for @historyThisMonth.
  ///
  /// In id, this message translates to:
  /// **'Bulan ini'**
  String get historyThisMonth;

  /// No description provided for @historyTripsCount.
  ///
  /// In id, this message translates to:
  /// **'{count} perjalanan'**
  String historyTripsCount(int count);

  /// No description provided for @poiButton.
  ///
  /// In id, this message translates to:
  /// **'Cari SPBU & bengkel terdekat'**
  String get poiButton;

  /// No description provided for @poiSheetTitle.
  ///
  /// In id, this message translates to:
  /// **'SPBU & bengkel terdekat'**
  String get poiSheetTitle;

  /// No description provided for @poiDisclaimer.
  ///
  /// In id, this message translates to:
  /// **'Data OpenStreetMap. Posisi Anda dikirim ke server Overpass hanya saat menekan tombol pencarian.'**
  String get poiDisclaimer;

  /// No description provided for @poiFuel.
  ///
  /// In id, this message translates to:
  /// **'SPBU'**
  String get poiFuel;

  /// No description provided for @poiWorkshop.
  ///
  /// In id, this message translates to:
  /// **'Bengkel'**
  String get poiWorkshop;

  /// No description provided for @poiNone.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada SPBU atau bengkel dalam radius 5 km.'**
  String get poiNone;

  /// No description provided for @congestionLikely.
  ///
  /// In id, this message translates to:
  /// **'Kemungkinan macet — kecepatan rendah cukup lama'**
  String get congestionLikely;

  /// No description provided for @congestionLabel.
  ///
  /// In id, this message translates to:
  /// **'Perkiraan macet'**
  String get congestionLabel;

  /// No description provided for @congestionNote.
  ///
  /// In id, this message translates to:
  /// **'Perkiraan dari pola kecepatan (merayap 3–15 km/j), bukan data lalu lintas resmi.'**
  String get congestionNote;

  /// No description provided for @tripFromTo.
  ///
  /// In id, this message translates to:
  /// **'{from} → {to}'**
  String tripFromTo(String from, String to);

  /// No description provided for @poiError.
  ///
  /// In id, this message translates to:
  /// **'Gagal mencari lokasi sekitar. Periksa koneksi internet.'**
  String get poiError;

  /// No description provided for @followPosition.
  ///
  /// In id, this message translates to:
  /// **'Ikuti posisi saya'**
  String get followPosition;

  /// No description provided for @liveMapWaitingFix.
  ///
  /// In id, this message translates to:
  /// **'Menunggu sinyal GPS... Peta akan muncul setelah posisi ditemukan.'**
  String get liveMapWaitingFix;

  /// No description provided for @liveMapIdleHint.
  ///
  /// In id, this message translates to:
  /// **'Mulai perjalanan untuk melihat posisi Anda secara realtime di peta.'**
  String get liveMapIdleHint;

  /// No description provided for @homeGreetingNamed.
  ///
  /// In id, this message translates to:
  /// **'Halo, {name} 👋'**
  String homeGreetingNamed(String name);

  /// No description provided for @homeGreetingAnon.
  ///
  /// In id, this message translates to:
  /// **'Halo 👋'**
  String get homeGreetingAnon;

  /// No description provided for @settingsKeepScreenOn.
  ///
  /// In id, this message translates to:
  /// **'Layar tetap menyala saat merekam'**
  String get settingsKeepScreenOn;

  /// No description provided for @settingsKeepScreenOnDesc.
  ///
  /// In id, this message translates to:
  /// **'Berguna saat HP terpasang di holder. Sedikit menambah pemakaian baterai.'**
  String get settingsKeepScreenOnDesc;

  /// No description provided for @statsTitle.
  ///
  /// In id, this message translates to:
  /// **'Rekap'**
  String get statsTitle;

  /// No description provided for @drivingSectionTitle.
  ///
  /// In id, this message translates to:
  /// **'Berkendara'**
  String get drivingSectionTitle;

  /// No description provided for @settingsSpeedLimit.
  ///
  /// In id, this message translates to:
  /// **'Peringatan batas kecepatan'**
  String get settingsSpeedLimit;

  /// No description provided for @settingsSpeedLimitOff.
  ///
  /// In id, this message translates to:
  /// **'Nonaktif — ketuk untuk mengatur'**
  String get settingsSpeedLimitOff;

  /// No description provided for @serviceIntervalMotorcycle.
  ///
  /// In id, this message translates to:
  /// **'Interval servis motor'**
  String get serviceIntervalMotorcycle;

  /// No description provided for @serviceIntervalCar.
  ///
  /// In id, this message translates to:
  /// **'Interval servis mobil'**
  String get serviceIntervalCar;

  /// No description provided for @serviceIntervalOff.
  ///
  /// In id, this message translates to:
  /// **'Nonaktif — ketuk untuk mengatur'**
  String get serviceIntervalOff;

  /// No description provided for @serviceIntervalEvery.
  ///
  /// In id, this message translates to:
  /// **'Setiap {km} km'**
  String serviceIntervalEvery(String km);

  /// No description provided for @serviceDueTitle.
  ///
  /// In id, this message translates to:
  /// **'Waktunya servis {vehicle}'**
  String serviceDueTitle(String vehicle);

  /// No description provided for @serviceDueBody.
  ///
  /// In id, this message translates to:
  /// **'Sudah ±{km} km tercatat sejak servis terakhir.'**
  String serviceDueBody(int km);

  /// No description provided for @serviceMarkDone.
  ///
  /// In id, this message translates to:
  /// **'Sudah servis'**
  String get serviceMarkDone;

  /// No description provided for @serviceMarked.
  ///
  /// In id, this message translates to:
  /// **'Dicatat — pengingat dihitung ulang dari sekarang.'**
  String get serviceMarked;

  /// No description provided for @statsExportCsv.
  ///
  /// In id, this message translates to:
  /// **'Ekspor CSV (semua perjalanan)'**
  String get statsExportCsv;

  /// No description provided for @statsExportCsvDesc.
  ///
  /// In id, this message translates to:
  /// **'File CSV bisa dibuka di Excel/Google Sheets untuk klaim atau pembukuan.'**
  String get statsExportCsvDesc;

  /// No description provided for @fuelSectionTitle.
  ///
  /// In id, this message translates to:
  /// **'Konsumsi BBM'**
  String get fuelSectionTitle;

  /// No description provided for @fuelSectionDesc.
  ///
  /// In id, this message translates to:
  /// **'Masukkan konsumsi khas kendaraanmu (mis. 1 liter untuk 40 km berarti 40 km/L). Motivox memakai angka ini untuk memperkirakan BBM dan biaya tiap perjalanan dari jarak tempuh GPS.'**
  String get fuelSectionDesc;

  /// No description provided for @fuelMotorcycleKmPerLiter.
  ///
  /// In id, this message translates to:
  /// **'Konsumsi motor (km per liter)'**
  String get fuelMotorcycleKmPerLiter;

  /// No description provided for @fuelCarKmPerLiter.
  ///
  /// In id, this message translates to:
  /// **'Konsumsi mobil (km per liter)'**
  String get fuelCarKmPerLiter;

  /// No description provided for @fuelPricePerLiter.
  ///
  /// In id, this message translates to:
  /// **'Harga BBM per liter'**
  String get fuelPricePerLiter;

  /// No description provided for @fuelNotSet.
  ///
  /// In id, this message translates to:
  /// **'Belum diatur — estimasi tidak ditampilkan'**
  String get fuelNotSet;

  /// No description provided for @fuelInputHint.
  ///
  /// In id, this message translates to:
  /// **'Kosongkan untuk menghapus'**
  String get fuelInputHint;

  /// No description provided for @fuelEstimateLabel.
  ///
  /// In id, this message translates to:
  /// **'Perkiraan BBM'**
  String get fuelEstimateLabel;

  /// No description provided for @fuelCostLabel.
  ///
  /// In id, this message translates to:
  /// **'Perkiraan biaya'**
  String get fuelCostLabel;

  /// No description provided for @fuelEstimateNote.
  ///
  /// In id, this message translates to:
  /// **'Estimasi dari angka km/L yang Anda masukkan, bukan pengukuran mesin.'**
  String get fuelEstimateNote;

  /// No description provided for @shareTripHeading.
  ///
  /// In id, this message translates to:
  /// **'Perjalanan {date}'**
  String shareTripHeading(String date);

  /// No description provided for @settingsDataSection.
  ///
  /// In id, this message translates to:
  /// **'Data & aplikasi'**
  String get settingsDataSection;

  /// No description provided for @backupExport.
  ///
  /// In id, this message translates to:
  /// **'Cadangkan riwayat'**
  String get backupExport;

  /// No description provided for @backupExportDesc.
  ///
  /// In id, this message translates to:
  /// **'Simpan seluruh riwayat sebagai satu file cadangan (bisa ditaruh di Google Drive dll.)'**
  String get backupExportDesc;

  /// No description provided for @backupImport.
  ///
  /// In id, this message translates to:
  /// **'Pulihkan dari cadangan'**
  String get backupImport;

  /// No description provided for @backupImportDesc.
  ///
  /// In id, this message translates to:
  /// **'Gabungkan file cadangan ke riwayat di HP ini'**
  String get backupImportDesc;

  /// No description provided for @backupImportSuccess.
  ///
  /// In id, this message translates to:
  /// **'{count} perjalanan dipulihkan dari cadangan'**
  String backupImportSuccess(String count);

  /// No description provided for @backupImportNone.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada perjalanan baru di file cadangan itu'**
  String get backupImportNone;

  /// No description provided for @backupInvalidFile.
  ///
  /// In id, this message translates to:
  /// **'File yang dipilih bukan cadangan Motivox'**
  String get backupInvalidFile;

  /// No description provided for @backupError.
  ///
  /// In id, this message translates to:
  /// **'Gagal memproses cadangan'**
  String get backupError;

  /// No description provided for @updateCheck.
  ///
  /// In id, this message translates to:
  /// **'Periksa pembaruan'**
  String get updateCheck;

  /// No description provided for @updateCurrentVersion.
  ///
  /// In id, this message translates to:
  /// **'Versi terpasang: {version}'**
  String updateCurrentVersion(String version);

  /// No description provided for @updateAvailable.
  ///
  /// In id, this message translates to:
  /// **'Versi baru tersedia (build {build})'**
  String updateAvailable(String build);

  /// No description provided for @updateUpToDate.
  ///
  /// In id, this message translates to:
  /// **'Motivox sudah versi terbaru'**
  String get updateUpToDate;

  /// No description provided for @updateCheckFailed.
  ///
  /// In id, this message translates to:
  /// **'Tidak dapat memeriksa pembaruan. Periksa koneksi lalu coba lagi.'**
  String get updateCheckFailed;

  /// No description provided for @updateDownload.
  ///
  /// In id, this message translates to:
  /// **'Unduh'**
  String get updateDownload;

  /// No description provided for @shareLog.
  ///
  /// In id, this message translates to:
  /// **'Bagikan log aplikasi'**
  String get shareLog;

  /// No description provided for @shareLogDesc.
  ///
  /// In id, this message translates to:
  /// **'Membantu diagnosis masalah; tidak berisi kata sandi atau token'**
  String get shareLogDesc;

  /// No description provided for @shareLogEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada log untuk dibagikan'**
  String get shareLogEmpty;

  /// No description provided for @vehicleNotDriver.
  ///
  /// In id, this message translates to:
  /// **'Bukan saya pengemudinya — buang perjalanan'**
  String get vehicleNotDriver;

  /// No description provided for @vehicleNotDriverConfirmTitle.
  ///
  /// In id, this message translates to:
  /// **'Buang perjalanan ini?'**
  String get vehicleNotDriverConfirmTitle;

  /// No description provided for @vehicleNotDriverConfirmBody.
  ///
  /// In id, this message translates to:
  /// **'Perjalanan saat Anda menjadi penumpang akan dihapus dari riwayat dan tidak bisa dikembalikan.'**
  String get vehicleNotDriverConfirmBody;

  /// No description provided for @vehicleNotDriverDeleted.
  ///
  /// In id, this message translates to:
  /// **'Perjalanan dibuang'**
  String get vehicleNotDriverDeleted;

  /// No description provided for @commonDiscard.
  ///
  /// In id, this message translates to:
  /// **'Buang'**
  String get commonDiscard;

  /// No description provided for @permGuideIntro.
  ///
  /// In id, this message translates to:
  /// **'Agar perekaman otomatis berjalan walau aplikasi tertutup, semua izin di bawah harus aktif dan izin lokasi disetel “Izinkan sepanjang waktu”.'**
  String get permGuideIntro;

  /// No description provided for @permAutostartTitle.
  ///
  /// In id, this message translates to:
  /// **'Autostart merek HP ({manufacturer})'**
  String permAutostartTitle(String manufacturer);

  /// No description provided for @permAutostartDesc.
  ///
  /// In id, this message translates to:
  /// **'Beberapa merek HP (Xiaomi, Oppo, Vivo, Realme, Huawei) menghentikan aplikasi latar belakang secara agresif. Buka pengaturan sistem dan aktifkan “Autostart” / “Mulai otomatis” untuk Motivox, lalu bebaskan Motivox dari pembatasan baterai.'**
  String get permAutostartDesc;
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

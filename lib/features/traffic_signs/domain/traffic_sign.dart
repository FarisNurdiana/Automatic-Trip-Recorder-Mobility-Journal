/// Kategori rambu sesuai penggolongan Peraturan Menteri Perhubungan
/// No. PM 13 Tahun 2014 tentang Rambu Lalu Lintas.
enum TrafficSignCategory {
  peringatan, // warning — kuning, belah ketupat
  larangan, // prohibition — putih, lingkaran tepi merah
  perintah, // mandatory — biru, lingkaran
  petunjuk, // guide — hijau/biru, persegi panjang
  sementara, // temporary — oranye (pekerjaan jalan dsb.)
  marka, // marka jalan dasar
}

/// Simbol sederhana yang digambar oleh ilustrator CustomPaint. Ilustrasi
/// digambar sendiri mengikuti deskripsi regulasi (bentuk & warna dasar per
/// kategori), bukan menyalin aset pihak lain.
enum SignSymbol {
  text, // tampilkan symbolText (mis. "40", "STOP", "P")
  arrowLeft,
  arrowRight,
  arrowUp,
  noEntry, // balok horizontal putih
  crossedP, // P dicoret (dilarang parkir)
  crossedS, // S dicoret (dilarang berhenti)
  crossedU, // U dicoret (dilarang putar balik)
  pedestrian,
  children,
  crossroad,
  bend,
  bump,
  narrowRoad,
  trafficLight,
  slippery,
  railway,
  roundabout,
  hospital,
  fuel,
  parking,
  busStop,
  mosque,
  roadWork,
  zebraCross,
  yellowLine,
}

/// Satu entri referensi rambu.
class TrafficSign {
  const TrafficSign({
    required this.id,
    required this.name,
    required this.category,
    required this.meaning,
    required this.action,
    required this.symbol,
    this.symbolText,
    this.safetyNote,
    this.keywords = const [],
  });

  final String id;
  final String name;
  final TrafficSignCategory category;

  /// Arti singkat rambu.
  final String meaning;

  /// Tindakan yang harus dilakukan pengendara.
  final String action;
  final SignSymbol symbol;

  /// Teks pada rambu (untuk [SignSymbol.text]).
  final String? symbolText;
  final String? safetyNote;
  final List<String> keywords;

  bool matches(String query) {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return true;
    return name.toLowerCase().contains(q) ||
        meaning.toLowerCase().contains(q) ||
        action.toLowerCase().contains(q) ||
        keywords.any((k) => k.toLowerCase().contains(q));
  }
}

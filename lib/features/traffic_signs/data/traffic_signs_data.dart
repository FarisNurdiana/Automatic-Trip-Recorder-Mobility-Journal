import '../domain/traffic_sign.dart';

/// Referensi edukasi rambu lalu lintas Indonesia.
///
/// Nama, arti, dan penggolongan mengikuti UU No. 22 Tahun 2009 tentang Lalu
/// Lintas dan Angkutan Jalan serta Permenhub No. PM 13 Tahun 2014 tentang
/// Rambu Lalu Lintas (lihat docs/traffic-signs-sources.md). Ini referensi
/// singkat, BUKAN pengganti aturan resmi ataupun sistem navigasi.
const List<TrafficSign> trafficSigns = [
  // ------------------------------------------------------------------
  // Rambu larangan (putih, lingkaran tepi merah)
  // ------------------------------------------------------------------
  TrafficSign(
    id: 'larangan-masuk',
    name: 'Dilarang masuk',
    category: TrafficSignCategory.larangan,
    meaning:
        'Kendaraan tidak diperbolehkan memasuki jalan dari arah ini '
        '(lingkaran merah dengan balok putih mendatar).',
    action: 'Cari jalur lain dan jangan melawan arah.',
    safetyNote: 'Melawan arah adalah penyebab umum kecelakaan fatal.',
    symbol: SignSymbol.noEntry,
    keywords: ['masuk', 'verboden', 'satu arah', 'dilarang'],
  ),
  TrafficSign(
    id: 'larangan-berhenti',
    name: 'Dilarang berhenti',
    category: TrafficSignCategory.larangan,
    meaning:
        'Kendaraan dilarang berhenti (huruf S dicoret) di sepanjang area '
        'berlakunya rambu, walaupun hanya sebentar.',
    action: 'Jangan berhenti di area ini; lanjutkan sampai area yang aman.',
    symbol: SignSymbol.crossedS,
    keywords: ['berhenti', 'stop', 's coret', 'dilarang'],
  ),
  TrafficSign(
    id: 'larangan-parkir',
    name: 'Dilarang parkir',
    category: TrafficSignCategory.larangan,
    meaning:
        'Kendaraan dilarang parkir (huruf P dicoret) di area berlakunya '
        'rambu; berhenti sebentar untuk menaikkan/menurunkan penumpang '
        'masih dimungkinkan bila aman.',
    action: 'Parkir di tempat lain yang diperbolehkan.',
    symbol: SignSymbol.crossedP,
    keywords: ['parkir', 'p coret', 'dilarang'],
  ),
  TrafficSign(
    id: 'larangan-batas-kecepatan',
    name: 'Batas kecepatan maksimum',
    category: TrafficSignCategory.larangan,
    meaning:
        'Pengendara tidak boleh melebihi angka kecepatan (km/jam) yang '
        'tertulis pada rambu.',
    action: 'Sesuaikan kecepatan agar tidak melebihi angka pada rambu.',
    safetyNote:
        'Batas kecepatan ditetapkan sesuai kondisi jalan; melebihi batas '
        'memperpanjang jarak pengereman.',
    symbol: SignSymbol.text,
    symbolText: '40',
    keywords: ['kecepatan', 'maksimum', 'batas', 'km'],
  ),
  TrafficSign(
    id: 'larangan-putar-balik',
    name: 'Dilarang berbalik arah',
    category: TrafficSignCategory.larangan,
    meaning:
        'Kendaraan dilarang berputar balik (huruf U dengan panah dicoret) '
        'pada titik ini.',
    action: 'Gunakan titik putar balik berikutnya yang diperbolehkan.',
    symbol: SignSymbol.crossedU,
    keywords: ['putar balik', 'u turn', 'belok', 'dilarang'],
  ),
  TrafficSign(
    id: 'larangan-belok-kiri',
    name: 'Dilarang belok kiri',
    category: TrafficSignCategory.larangan,
    meaning: 'Kendaraan dilarang belok ke kiri pada persimpangan ini.',
    action: 'Lanjutkan lurus atau ikuti arah lain yang diizinkan.',
    symbol: SignSymbol.arrowLeft,
    keywords: ['belok', 'kiri', 'dilarang'],
  ),
  TrafficSign(
    id: 'larangan-stop',
    name: 'Berhenti (STOP)',
    category: TrafficSignCategory.larangan,
    meaning:
        'Segi delapan merah bertuliskan STOP: kendaraan wajib berhenti '
        'sesaat sebelum melanjutkan perjalanan.',
    action:
        'Berhenti penuh, pastikan lalu lintas aman, baru melanjutkan '
        'perjalanan.',
    safetyNote: 'Wajib berhenti walaupun persimpangan terlihat kosong.',
    symbol: SignSymbol.text,
    symbolText: 'STOP',
    keywords: ['stop', 'berhenti', 'wajib'],
  ),

  // ------------------------------------------------------------------
  // Rambu peringatan (kuning, belah ketupat)
  // ------------------------------------------------------------------
  TrafficSign(
    id: 'peringatan-tikungan',
    name: 'Tikungan tajam',
    category: TrafficSignCategory.peringatan,
    meaning: 'Di depan terdapat tikungan tajam (arah sesuai simbol panah).',
    action: 'Kurangi kecepatan sebelum memasuki tikungan.',
    safetyNote: 'Jangan mendahului di tikungan.',
    symbol: SignSymbol.bend,
    keywords: ['tikungan', 'belok', 'hati-hati'],
  ),
  TrafficSign(
    id: 'peringatan-persimpangan',
    name: 'Persimpangan',
    category: TrafficSignCategory.peringatan,
    meaning: 'Di depan terdapat persimpangan jalan.',
    action: 'Kurangi kecepatan dan perhatikan kendaraan dari arah lain.',
    symbol: SignSymbol.crossroad,
    keywords: ['persimpangan', 'simpang', 'hati-hati'],
  ),
  TrafficSign(
    id: 'peringatan-penyeberangan',
    name: 'Penyeberangan pejalan kaki',
    category: TrafficSignCategory.peringatan,
    meaning: 'Di depan terdapat penyeberangan pejalan kaki.',
    action: 'Kurangi kecepatan dan dahulukan pejalan kaki yang menyeberang.',
    safetyNote: 'Pejalan kaki memiliki hak utama di zebra cross.',
    symbol: SignSymbol.pedestrian,
    keywords: ['penyeberangan', 'pejalan kaki', 'zebra', 'hati-hati'],
  ),
  TrafficSign(
    id: 'peringatan-anak',
    name: 'Banyak anak-anak',
    category: TrafficSignCategory.peringatan,
    meaning:
        'Area rawan anak-anak (sekitar sekolah atau permukiman); anak dapat '
        'muncul tiba-tiba ke jalan.',
    action: 'Kurangi kecepatan dan tingkatkan kewaspadaan.',
    symbol: SignSymbol.children,
    keywords: ['anak', 'sekolah', 'hati-hati'],
  ),
  TrafficSign(
    id: 'peringatan-tanjakan-polisi-tidur',
    name: 'Alat pembatas kecepatan',
    category: TrafficSignCategory.peringatan,
    meaning:
        'Di depan terdapat alat pembatas kecepatan (speed bump / '
        '"polisi tidur").',
    action: 'Kurangi kecepatan sebelum melintas.',
    symbol: SignSymbol.bump,
    keywords: ['polisi tidur', 'pembatas kecepatan', 'gundukan'],
  ),
  TrafficSign(
    id: 'peringatan-jalan-menyempit',
    name: 'Penyempitan jalan',
    category: TrafficSignCategory.peringatan,
    meaning: 'Lebar jalan di depan menyempit.',
    action: 'Kurangi kecepatan dan bersiap memberi jalan.',
    symbol: SignSymbol.narrowRoad,
    keywords: ['sempit', 'menyempit', 'hati-hati'],
  ),
  TrafficSign(
    id: 'peringatan-licin',
    name: 'Jalan licin',
    category: TrafficSignCategory.peringatan,
    meaning: 'Permukaan jalan licin, terutama saat hujan.',
    action: 'Kurangi kecepatan, hindari pengereman dan manuver mendadak.',
    symbol: SignSymbol.slippery,
    keywords: ['licin', 'hujan', 'selip', 'hati-hati'],
  ),
  TrafficSign(
    id: 'peringatan-lampu-lalu-lintas',
    name: 'Lampu lalu lintas',
    category: TrafficSignCategory.peringatan,
    meaning: 'Di depan terdapat alat pemberi isyarat lalu lintas (APILL).',
    action: 'Bersiap berhenti bila isyarat menyala merah.',
    symbol: SignSymbol.trafficLight,
    keywords: ['lampu', 'apill', 'traffic light'],
  ),
  TrafficSign(
    id: 'peringatan-perlintasan-ka',
    name: 'Perlintasan kereta api',
    category: TrafficSignCategory.peringatan,
    meaning: 'Di depan terdapat perlintasan sebidang dengan jalur kereta.',
    action:
        'Kurangi kecepatan, tengok kiri-kanan, dan berhenti bila sinyal '
        'berbunyi atau palang menutup.',
    safetyNote: 'Wajib mendahulukan kereta api; jangan menerobos palang pintu.',
    symbol: SignSymbol.railway,
    keywords: ['kereta', 'perlintasan', 'rel', 'hati-hati'],
  ),

  // ------------------------------------------------------------------
  // Rambu perintah (biru, lingkaran)
  // ------------------------------------------------------------------
  TrafficSign(
    id: 'perintah-ikuti-kiri',
    name: 'Wajib mengikuti arah kiri',
    category: TrafficSignCategory.perintah,
    meaning: 'Pengendara wajib mengikuti arah panah (ke kiri).',
    action: 'Ikuti arah yang ditunjukkan panah.',
    symbol: SignSymbol.arrowLeft,
    keywords: ['wajib', 'kiri', 'belok', 'arah'],
  ),
  TrafficSign(
    id: 'perintah-ikuti-lurus',
    name: 'Wajib lurus',
    category: TrafficSignCategory.perintah,
    meaning: 'Pengendara wajib berjalan lurus mengikuti panah.',
    action: 'Jangan berbelok pada titik ini.',
    symbol: SignSymbol.arrowUp,
    keywords: ['wajib', 'lurus', 'arah'],
  ),
  TrafficSign(
    id: 'perintah-bundaran',
    name: 'Wajib mengitari bundaran',
    category: TrafficSignCategory.perintah,
    meaning: 'Pengendara wajib mengikuti arah putaran bundaran.',
    action:
        'Masuk bundaran sesuai arah panah dan dahulukan kendaraan di '
        'dalam bundaran.',
    symbol: SignSymbol.roundabout,
    keywords: ['bundaran', 'wajib', 'putar'],
  ),
  TrafficSign(
    id: 'perintah-kecepatan-minimum',
    name: 'Batas kecepatan minimum',
    category: TrafficSignCategory.perintah,
    meaning:
        'Kendaraan wajib berjalan minimal pada kecepatan yang tertulis '
        '(lingkaran biru dengan angka).',
    action: 'Jaga kecepatan di atas angka tersebut selama kondisi aman.',
    symbol: SignSymbol.text,
    symbolText: '60',
    keywords: ['kecepatan', 'minimum', 'wajib'],
  ),

  // ------------------------------------------------------------------
  // Rambu petunjuk (biru/hijau, persegi)
  // ------------------------------------------------------------------
  TrafficSign(
    id: 'petunjuk-parkir',
    name: 'Tempat parkir',
    category: TrafficSignCategory.petunjuk,
    meaning: 'Menunjukkan lokasi/area parkir (huruf P).',
    action: 'Parkir kendaraan pada area yang disediakan.',
    symbol: SignSymbol.parking,
    keywords: ['parkir', 'tempat', 'p'],
  ),
  TrafficSign(
    id: 'petunjuk-rumah-sakit',
    name: 'Rumah sakit',
    category: TrafficSignCategory.petunjuk,
    meaning: 'Menunjukkan arah/lokasi fasilitas kesehatan.',
    action: 'Ikuti petunjuk bila membutuhkan; jaga ketenangan area.',
    symbol: SignSymbol.hospital,
    keywords: ['rumah sakit', 'kesehatan', 'darurat'],
  ),
  TrafficSign(
    id: 'petunjuk-spbu',
    name: 'Pengisian bahan bakar',
    category: TrafficSignCategory.petunjuk,
    meaning: 'Menunjukkan lokasi stasiun pengisian bahan bakar (SPBU).',
    action: 'Ikuti petunjuk bila perlu mengisi bahan bakar.',
    symbol: SignSymbol.fuel,
    keywords: ['spbu', 'bensin', 'bahan bakar', 'isi'],
  ),
  TrafficSign(
    id: 'petunjuk-halte',
    name: 'Halte bus',
    category: TrafficSignCategory.petunjuk,
    meaning: 'Menunjukkan tempat pemberhentian angkutan umum.',
    action: 'Waspada terhadap bus yang berhenti dan penumpang yang turun.',
    symbol: SignSymbol.busStop,
    keywords: ['halte', 'bus', 'berhenti', 'angkutan'],
  ),
  TrafficSign(
    id: 'petunjuk-masjid',
    name: 'Tempat ibadah',
    category: TrafficSignCategory.petunjuk,
    meaning: 'Menunjukkan lokasi tempat ibadah di sekitar jalan.',
    action: 'Waspada aktivitas penyeberang di sekitar lokasi.',
    symbol: SignSymbol.mosque,
    keywords: ['masjid', 'ibadah'],
  ),

  // ------------------------------------------------------------------
  // Rambu sementara (oranye)
  // ------------------------------------------------------------------
  TrafficSign(
    id: 'sementara-pekerjaan-jalan',
    name: 'Pekerjaan jalan',
    category: TrafficSignCategory.sementara,
    meaning:
        'Terdapat pekerjaan jalan di depan (rambu sementara berwarna '
        'oranye).',
    action: 'Kurangi kecepatan, ikuti pengaturan petugas atau rambu sementara.',
    safetyNote: 'Perhatikan pekerja dan alat berat di sekitar area.',
    symbol: SignSymbol.roadWork,
    keywords: ['pekerjaan', 'proyek', 'perbaikan', 'sementara', 'hati-hati'],
  ),

  // ------------------------------------------------------------------
  // Marka jalan dasar
  // ------------------------------------------------------------------
  TrafficSign(
    id: 'marka-zebra',
    name: 'Zebra cross',
    category: TrafficSignCategory.marka,
    meaning:
        'Marka penyeberangan pejalan kaki berupa garis-garis putih '
        'melintang.',
    action: 'Berhenti atau perlambat untuk mendahulukan penyeberang.',
    symbol: SignSymbol.zebraCross,
    keywords: ['zebra', 'penyeberangan', 'marka', 'pejalan kaki'],
  ),
  TrafficSign(
    id: 'marka-garis-putus',
    name: 'Marka putus-putus',
    category: TrafficSignCategory.marka,
    meaning:
        'Garis pembagi lajur putus-putus: kendaraan boleh berpindah lajur '
        'atau mendahului bila aman.',
    action: 'Mendahului hanya bila pandangan bebas dan aman.',
    symbol: SignSymbol.text,
    symbolText: '– – –',
    keywords: ['marka', 'putus', 'mendahului', 'lajur'],
  ),
  TrafficSign(
    id: 'marka-garis-utuh',
    name: 'Marka garis utuh',
    category: TrafficSignCategory.marka,
    meaning:
        'Garis utuh (tidak putus): kendaraan dilarang melintasi garis, '
        'termasuk untuk mendahului.',
    action: 'Tetap di lajur; jangan mendahului melewati garis utuh.',
    symbol: SignSymbol.text,
    symbolText: '———',
    keywords: ['marka', 'utuh', 'dilarang', 'mendahului', 'lajur'],
  ),
  TrafficSign(
    id: 'marka-kuning-tepi',
    name: 'Marka kuning tepi jalan',
    category: TrafficSignCategory.marka,
    meaning:
        'Garis kuning berbiku-biku/utuh di tepi jalan menandakan larangan '
        'parkir atau berhenti pada sisi tersebut.',
    action: 'Jangan parkir/berhenti pada tepi jalan bermarka kuning.',
    symbol: SignSymbol.yellowLine,
    keywords: ['marka', 'kuning', 'parkir', 'berhenti', 'tepi'],
  ),
];

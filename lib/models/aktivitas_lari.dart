// File: aktivitas_lari.dart
// Model data untuk satu sesi aktivitas lari
// Menyimpan semua informasi satu kali lari: jarak, waktu, tanggal, catatan

/// Model AktivitasLari merepresentasikan satu sesi lari yang sudah dicatat.
/// Bersifat immutable — perubahan data dilakukan via copyWith().
class AktivitasLari {
  // ID unik aktivitas, digunakan untuk operasi update dan hapus
  final String id;

  // ID pengguna pemilik aktivitas — dipakai untuk isolasi data antar user
  final String userId;

  // Jarak yang ditempuh dalam kilometer
  final double jarakKm;

  // Total durasi lari dalam menit (contoh: 65 menit = 1 jam 5 menit)
  final int waktuMenit;

  // Tanggal aktivitas dilakukan
  final DateTime tanggal;

  // Catatan bebas opsional dari pengguna (bisa kosong)
  final String catatan;
  // Konstruktor konstan untuk menginisialisasi sesi aktivitas lari
  const AktivitasLari({
    required this.id,
    required this.userId,
    required this.jarakKm,
    required this.waktuMenit,
    required this.tanggal,
    this.catatan = '',
  });

  // ===== COMPUTED GETTERS =====

  /// Menghitung pace (kecepatan) dalam menit per kilometer.
  /// Kembalikan 0 jika jarak 0 untuk menghindari pembagian dengan nol.
  double get paceMinPerKm => jarakKm > 0 ? waktuMenit / jarakKm : 0;

  /// Mengubah pace menjadi string yang mudah dibaca.
  /// Format: "6:15 /km" (menit:detik per kilometer)
  String get paceFormatted {
    if (jarakKm <= 0) return '-';
    // Konversi menit desimal ke total detik, lalu pisahkan ke menit dan detik
    final totalDetik = (paceMinPerKm * 60).round();
    final menit = totalDetik ~/ 60;
    final detik = totalDetik % 60;
    // padLeft(2, '0') memastikan format "06" bukan "6"
    return '$menit:${detik.toString().padLeft(2, '0')} /km';
  }

  /// Mengubah durasi waktu menjadi string yang mudah dibaca.
  /// Format: "32m" atau "1j 5m" jika lebih dari 1 jam
  String get waktuFormatted {
    final jam = waktuMenit ~/ 60;
    final menit = waktuMenit % 60;
    if (jam > 0) return '${jam}j ${menit}m';
    return '${menit}m';
  }

  /// Estimasi jumlah kalori yang terbakar.
  /// Menggunakan rumus sederhana: 60 kalori per kilometer.
  int get kaloriEstimasi => (jarakKm * 60).round();

  /// String kalori dengan satuan untuk ditampilkan di UI
  String get kaloriFormatted => '$kaloriEstimasi kal';

  /// String jarak dengan satu angka desimal untuk ditampilkan di UI
  String get jarakFormatted => '${jarakKm.toStringAsFixed(1)} km';

  /// Membuat salinan objek dengan nilai tertentu yang diganti.
  /// Pola immutable: tidak mengubah objek asli, tapi membuat objek baru.
  AktivitasLari copyWith({
    String? id,
    String? userId,
    double? jarakKm,
    int? waktuMenit,
    DateTime? tanggal,
    String? catatan,
  }) {
    return AktivitasLari(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      jarakKm: jarakKm ?? this.jarakKm,
      waktuMenit: waktuMenit ?? this.waktuMenit,
      tanggal: tanggal ?? this.tanggal,
      catatan: catatan ?? this.catatan,
    );
  }
}

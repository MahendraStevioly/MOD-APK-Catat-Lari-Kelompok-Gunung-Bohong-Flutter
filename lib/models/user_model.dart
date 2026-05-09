// File: user_model.dart
// Model data yang merepresentasikan pengguna aplikasi Catat Lari
// Digunakan untuk menyimpan dan meneruskan data user antar screen

/// Kelas UserModel merepresentasikan data seorang pengguna.
/// Bersifat immutable (tidak bisa diubah setelah dibuat) menggunakan final.
class UserModel {
  // ID unik pengguna (misal: dari database atau Firebase)
  final String id;

  // Nama lengkap pengguna
  final String nama;

  // Alamat email pengguna (digunakan untuk login)
  final String email;

  // URL foto profil pengguna (opsional, boleh null)
  final String? fotoUrl;

  // Total jarak yang sudah ditempuh (dalam kilometer)
  final double totalJarakKm;

  // Total sesi lari yang sudah dilakukan
  final int totalSesiLari;

  /// Konstruktor utama UserModel.
  /// Parameter [id], [nama], [email] wajib diisi.
  /// Parameter [fotoUrl], [totalJarakKm], [totalSesiLari] opsional.
  const UserModel({
    required this.id,
    required this.nama,
    required this.email,
    this.fotoUrl,
    this.totalJarakKm = 0.0,
    this.totalSesiLari = 0,
  });

  /// Factory constructor untuk membuat UserModel dari Map (misal: dari JSON/API)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      nama: map['nama'] as String,
      email: map['email'] as String,
      fotoUrl: map['fotoUrl'] as String?,
      // Mengonversi tipe 'num' ke 'double' untuk fleksibilitas tipe data angka
      totalJarakKm: (map['totalJarakKm'] as num?)?.toDouble() ?? 0.0,
      totalSesiLari: (map['totalSesiLari'] as int?) ?? 0,
    );
  }

  /// Mengubah UserModel menjadi Map (untuk disimpan ke database/API)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'email': email,
      'fotoUrl': fotoUrl,
      'totalJarakKm': totalJarakKm,
      'totalSesiLari': totalSesiLari,
    };
  }

  /// Membuat salinan UserModel dengan nilai yang diubah sebagian.
  /// Berguna untuk memperbarui data tanpa mengubah objek asli.
  UserModel copyWith({
    String? id,
    String? nama,
    String? email,
    String? fotoUrl,
    double? totalJarakKm,
    int? totalSesiLari,
  }) {
    return UserModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      email: email ?? this.email,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      totalJarakKm: totalJarakKm ?? this.totalJarakKm,
      totalSesiLari: totalSesiLari ?? this.totalSesiLari,
    );
  }

  /// Data pengguna contoh (dummy) untuk keperluan tampilan/testing
  static UserModel dummy() {
    return const UserModel(
      id: 'usr_001',
      nama: 'Ahmad Pelari',
      email: 'ahmad@gunungbohong.id',
      totalJarakKm: 42.5,
      totalSesiLari: 15,
    );
  }
}

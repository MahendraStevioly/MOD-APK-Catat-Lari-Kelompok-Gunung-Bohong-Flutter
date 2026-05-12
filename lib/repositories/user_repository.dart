// File: user_repository.dart
// Layer Repository untuk operasi data pengguna
// Mengabstraksikan DatabaseHelper sehingga ViewModel tidak perlu tahu detail SQLite

import '../database/database_helper.dart';
import '../models/user_model.dart';

/// Merepresentasikan satu akun terdaftar: data publik pengguna dan password-nya.
class AkunTerdaftar {
  final UserModel user;
  final String password;

  const AkunTerdaftar({required this.user, required this.password});
}

/// UserRepository menangani semua operasi baca-tulis data pengguna ke SQLite.
///
/// Dalam pola MVVM, Repository adalah satu-satunya kelas yang boleh
/// berinteraksi langsung dengan [DatabaseHelper]. ViewModel hanya memanggil
/// metode Repository tanpa mengetahui cara data disimpan.
class UserRepository {
  final DatabaseHelper _db;

  const UserRepository(this._db);

  /// Mengambil semua akun terdaftar dari database dan mengonversinya ke [AkunTerdaftar].
  Future<List<AkunTerdaftar>> getAllUsers() async {
    final rows = await _db.getAllUsers();
    return rows.map((row) {
      return AkunTerdaftar(
        user: UserModel(
          id: row[DatabaseHelper.colUserId] as String,
          nama: row[DatabaseHelper.colUserNama] as String,
          email: row[DatabaseHelper.colUserEmail] as String,
        ),
        password: row[DatabaseHelper.colUserPassword] as String,
      );
    }).toList();
  }

  /// Menyimpan akun baru ke database.
  Future<void> insertUser({
    required String id,
    required String nama,
    required String email,
    required String password,
  }) {
    return _db.insertUser({
      DatabaseHelper.colUserId: id,
      DatabaseHelper.colUserNama: nama,
      DatabaseHelper.colUserEmail: email,
      DatabaseHelper.colUserPassword: password,
    });
  }

  /// Memeriksa apakah tabel users kosong (belum ada akun terdaftar).
  Future<bool> isEmpty() async {
    final users = await getAllUsers();
    return users.isEmpty;
  }

  /// Menyisipkan akun demo saat pertama kali install aplikasi.
  Future<void> seedDemoUser() {
    return insertUser(
      id: 'demo_usr_001',
      nama: 'Ahmad Pelari',
      email: 'demo@catatlari.com',
      password: 'demo123',
    );
  }
}

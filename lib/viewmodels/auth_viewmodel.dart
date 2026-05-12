// File: auth_viewmodel.dart
// ViewModel untuk autentikasi — mengelola state akun dan pengguna aktif
// Memanggil UserRepository untuk akses data dan memperbarui View melalui notifyListeners()

import 'package:flutter/foundation.dart';

import '../repositories/user_repository.dart';
import '../models/user_model.dart';
import '../utils/auth_state.dart';

/// AuthViewModel mengelola state autentikasi di seluruh aplikasi.
///
/// Dalam pola MVVM:
/// - Model     : [UserModel], [AkunTerdaftar]
/// - Repository: [UserRepository] (akses data ke SQLite)
/// - ViewModel (ini): logika bisnis autentikasi + state pengguna aktif
/// - View      : [LoginView], [RegisterView] (mengamati ViewModel ini)
class AuthViewModel extends ChangeNotifier {
  final UserRepository _repo;

  AuthViewModel(this._repo);

  final List<AkunTerdaftar> _daftarAkun = [];
  UserModel? _currentUser;

  // ===== GETTERS =====

  /// Pengguna yang sedang aktif login. Null jika belum login.
  UserModel? get currentUser => _currentUser;

  /// true jika ada pengguna yang sedang login.
  bool get sudahLogin => _currentUser != null;

  // ===== INISIALISASI =====

  /// Memuat semua akun dari database ke memori.
  ///
  /// Dipanggil sekali di main() sebelum runApp. Jika DB kosong, seed akun demo.
  Future<void> initialize() async {
    if (await _repo.isEmpty()) {
      await _repo.seedDemoUser();
    }
    _daftarAkun
      ..clear()
      ..addAll(await _repo.getAllUsers());
  }

  // ===== METODE AUTENTIKASI =====

  /// Memvalidasi kredensial dan menyimpan pengguna aktif jika berhasil.
  ///
  /// Mengembalikan null jika login sukses, atau pesan error jika gagal.
  String? login(String email, String password) {
    final emailBersih = email.trim().toLowerCase();
    AkunTerdaftar? akun;

    for (final a in _daftarAkun) {
      if (a.user.email.toLowerCase() == emailBersih) {
        akun = a;
        break;
      }
    }

    if (akun == null) {
      return 'Akun tidak ditemukan. Silakan daftar terlebih dahulu.';
    }
    if (akun.password != password) {
      return 'Password salah. Periksa kembali password Anda.';
    }

    _currentUser = akun.user;
    AuthState.masuk();
    notifyListeners();
    return null;
  }

  /// Mendaftarkan akun baru dan menyimpannya ke database.
  ///
  /// Mengembalikan null jika registrasi sukses, atau pesan error jika gagal.
  String? register(String nama, String email, String password) {
    final emailBersih = email.trim().toLowerCase();
    final sudahAda = _daftarAkun.any(
      (a) => a.user.email.toLowerCase() == emailBersih,
    );

    if (sudahAda) {
      return 'Email ini sudah digunakan. Silakan gunakan email lain atau masuk.';
    }

    final id = 'usr_${DateTime.now().millisecondsSinceEpoch}';
    final user = UserModel(id: id, nama: nama.trim(), email: email.trim());

    // Simpan ke DB secara async (fire-and-forget)
    _repo.insertUser(
      id: id,
      nama: nama.trim(),
      email: email.trim(),
      password: password,
    );

    _daftarAkun.add(AkunTerdaftar(user: user, password: password));
    notifyListeners();
    return null;
  }

  /// Menghapus pengguna aktif dari memori dan menutup sesi.
  void logout() {
    _currentUser = null;
    AuthState.keluar();
    notifyListeners();
  }
}

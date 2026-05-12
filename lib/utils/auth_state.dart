// File: auth_state.dart
// Menyimpan status autentikasi (sudah login atau belum) sebagai flag statis
// Dipakai oleh GoRouter untuk logika redirect — tidak menyimpan data user
// Data user yang lengkap dikelola oleh AuthViewModel

/// AuthState menyimpan satu flag boolean untuk keperluan GoRouter redirect.
/// Sengaja dibuat statis karena GoRouter redirect tidak bisa akses context Provider.
class AuthState {
  AuthState._();

  // Flag: true jika pengguna sudah berhasil login
  static bool isLoggedIn = false;

  /// Dipanggil saat login berhasil untuk mengaktifkan akses ke halaman dalam app
  static void masuk() {
    isLoggedIn = true;
  }

  /// Dipanggil saat logout untuk memblokir akses kembali ke halaman dalam app
  static void keluar() {
    isLoggedIn = false;
  }
}

// File: login_viewmodel.dart
// ViewModel untuk halaman Login — mengelola state form dan orkestrasi proses login
// Memisahkan state loading dari widget UI sehingga LoginView bisa StatelessWidget

import 'package:flutter/foundation.dart';

import 'auth_viewmodel.dart';

/// LoginViewModel mengelola state yang diperlukan oleh [LoginView].
///
/// Dalam pola MVVM:
/// - ViewModel (ini): state form login (isLoading) + orkestrasi pemanggilan AuthViewModel
/// - View      : `LoginView` mengamati ViewModel ini via `context.watch<LoginViewModel>()`
class LoginViewModel extends ChangeNotifier {
  bool _isLoading = false;

  /// true saat proses login sedang berlangsung (simulasi network / validasi).
  bool get isLoading => _isLoading;

  /// Menjalankan proses login: simulasi delay jaringan → panggil [AuthViewModel.login].
  ///
  /// Mengembalikan null jika login sukses, atau pesan error jika gagal.
  Future<String?> login(
    AuthViewModel authVM,
    String email,
    String password,
  ) async {
    _isLoading = true;
    notifyListeners();

    // Simulasi delay jaringan
    await Future.delayed(const Duration(seconds: 2));

    _isLoading = false;
    notifyListeners();

    return authVM.login(email, password);
  }
}

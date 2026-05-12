// File: register_viewmodel.dart
// ViewModel untuk halaman Register — mengelola state form dan orkestrasi proses registrasi
// Memisahkan state loading dari widget UI sehingga RegisterView bisa StatelessWidget

import 'package:flutter/foundation.dart';

import 'auth_viewmodel.dart';

/// RegisterViewModel mengelola state yang diperlukan oleh [RegisterView].
///
/// Dalam pola MVVM:
/// - ViewModel (ini): state form registrasi (isLoading) + orkestrasi pemanggilan AuthViewModel
/// - View      : `RegisterView` mengamati ViewModel ini via `context.watch<RegisterViewModel>()`
class RegisterViewModel extends ChangeNotifier {
  bool _isLoading = false;

  /// true saat proses registrasi sedang berlangsung (simulasi network / validasi).
  bool get isLoading => _isLoading;

  /// Menjalankan proses registrasi: simulasi delay jaringan → panggil [AuthViewModel.register].
  ///
  /// Mengembalikan null jika registrasi sukses, atau pesan error jika gagal.
  Future<String?> register(
    AuthViewModel authVM,
    String nama,
    String email,
    String password,
  ) async {
    _isLoading = true;
    notifyListeners();

    // Simulasi delay jaringan
    await Future.delayed(const Duration(seconds: 2));

    _isLoading = false;
    notifyListeners();

    return authVM.register(nama, email, password);
  }
}

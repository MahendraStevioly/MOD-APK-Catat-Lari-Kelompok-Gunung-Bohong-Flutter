// File: main.dart
// Titik masuk utama aplikasi Catat Lari
// Mengatur dependency injection MVVM dan meneruskan konfigurasi router ke MaterialApp

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Layer Database
import 'database/database_helper.dart';

// Layer Repository — mengabstraksikan akses data ke DatabaseHelper
import 'repositories/user_repository.dart';
import 'repositories/aktivitas_repository.dart';

// Layer ViewModel — mengelola state dan logika bisnis
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/aktivitas_viewmodel.dart';
import 'viewmodels/login_viewmodel.dart';
import 'viewmodels/register_viewmodel.dart';

// Konfigurasi tema dan router
import 'utils/app_theme.dart';
import 'utils/app_router.dart';

/// Titik masuk aplikasi. Menginisialisasi seluruh lapisan MVVM sebelum UI dirender.
///
/// Urutan inisialisasi (penting — jangan diubah):
/// 1. DatabaseHelper (singleton, dipakai oleh semua Repository)
/// 2. Repository (mengabstraksikan DB untuk ViewModel)
/// 3. ViewModel (menggunakan Repository untuk mengakses data)
/// 4. Initialize ViewModels (load data dari DB sebelum UI tampil)
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ===== LAYER DATABASE =====
  final db = DatabaseHelper();

  // ===== LAYER REPOSITORY =====
  // Repository dibuat dengan menerima DatabaseHelper via konstruktor (dependency injection)
  final userRepo = UserRepository(db);
  final aktivitasRepo = AktivitasRepository(db);

  // ===== LAYER VIEWMODEL =====
  // ViewModel dibuat dengan menerima Repository via konstruktor (dependency injection)
  final authVM = AuthViewModel(userRepo);
  final aktivitasVM = AktivitasViewModel(aktivitasRepo);

  // Muat data dari SQLite sebelum UI dirender
  // AuthViewModel harus diinisialisasi dulu karena aktivitas butuh user_id dari akun demo
  await authVM.initialize();
  await aktivitasVM.initialize();

  // MultiProvider mendistribusikan semua ViewModel ke seluruh widget tree
  runApp(
    MultiProvider(
      providers: [
        // App-level ViewModels: dipakai oleh banyak View sekaligus
        ChangeNotifierProvider.value(value: authVM),
        ChangeNotifierProvider.value(value: aktivitasVM),

        // Screen-level ViewModels: mengelola state spesifik per halaman
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => RegisterViewModel()),
      ],
      child: const CatatLariApp(),
    ),
  );
}

/// CatatLariApp adalah widget root aplikasi.
class CatatLariApp extends StatelessWidget {
  const CatatLariApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Catat Lari',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
    );
  }
}

// File: app_router.dart
// Konfigurasi utama sistem navigasi GoRouter untuk aplikasi Catat Lari
// Menentukan semua rute, struktur navigasi, dan logika redirect (guard)

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Import dari layer View (pola MVVM)
import '../views/home/home_view.dart';
import '../views/login/login_view.dart';
import '../views/profile/profile_view.dart';
import '../views/register/register_view.dart';
import '../widgets/main_shell.dart';
import 'app_routes.dart';
import 'auth_state.dart';

/// AppRouter menyediakan instance GoRouter tunggal yang dipakai di seluruh aplikasi.
class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.login,

    // ===== LOGIKA REDIRECT (ROUTE GUARD) =====
    redirect: (BuildContext context, GoRouterState state) {
      final lokasiTujuan = state.matchedLocation;
      final sudahLogin = AuthState.isLoggedIn;

      final halamanPublik = [AppRoutes.login, AppRoutes.register];
      final menujuHalamanPublik = halamanPublik.contains(lokasiTujuan);

      if (!sudahLogin && !menujuHalamanPublik) return AppRoutes.login;
      if (sudahLogin && lokasiTujuan == AppRoutes.login) return AppRoutes.home;

      return null;
    },

    // ===== DAFTAR SEMUA RUTE APLIKASI =====
    routes: [
      // Rute Login — menggunakan LoginView (layer View MVVM)
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: LoginView(),
        ),
      ),

      // Rute Register — animasi slide dari bawah
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const RegisterView(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: animation.drive(
                Tween(begin: const Offset(0, 1), end: Offset.zero).chain(
                  CurveTween(curve: Curves.easeInOut),
                ),
              ),
              child: child,
            );
          },
        ),
      ),

      // ShellRoute — pembungkus Bottom Navigation Bar
      ShellRoute(
        builder: (context, state, child) {
          return MainShell(
            lokasiSaatIni: state.matchedLocation,
            child: child,
          );
        },
        routes: [
          // Tab Home — menggunakan HomeView (layer View MVVM)
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeView(),
            ),
          ),

          // Tab Profile — menggunakan ProfileView (layer View MVVM)
          GoRoute(
            path: AppRoutes.profile,
            name: 'profile',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileView(),
            ),
          ),
        ],
      ),
    ],
  );
}

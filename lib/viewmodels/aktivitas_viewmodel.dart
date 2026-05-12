// File: aktivitas_viewmodel.dart
// ViewModel untuk daftar aktivitas lari — mengelola state dan komputasi statistik
// Memanggil AktivitasRepository untuk akses data dan memperbarui View melalui notifyListeners()

import 'package:flutter/foundation.dart';

import '../repositories/aktivitas_repository.dart';
import '../models/aktivitas_lari.dart';

/// AktivitasViewModel mengelola state daftar aktivitas lari di seluruh aplikasi.
///
/// Dalam pola MVVM:
/// - Model     : [AktivitasLari]
/// - Repository: [AktivitasRepository] (akses data ke SQLite)
/// - ViewModel (ini): state aktivitas + logika CRUD + komputasi statistik
/// - View      : [HomeView], [ProfileView] (mengamati ViewModel ini)
class AktivitasViewModel extends ChangeNotifier {
  final AktivitasRepository _repo;

  AktivitasViewModel(this._repo);

  // Daftar semua aktivitas dari semua user — difilter saat dibaca per-user
  final List<AktivitasLari> _aktivitas = [];

  // ===== INISIALISASI =====

  /// Memuat semua aktivitas dari database ke memori.
  ///
  /// Dipanggil sekali di main() sebelum runApp. Jika DB kosong, seed data demo.
  Future<void> initialize() async {
    if (await _repo.isEmpty()) {
      await _repo.seedDemoData();
    }
    _aktivitas
      ..clear()
      ..addAll(await _repo.getAllActivities());
  }

  // ===== GETTERS PER-USER =====

  /// Mengembalikan daftar aktivitas milik user tertentu, diurutkan terbaru dulu.
  List<AktivitasLari> getAktivitasByUser(String userId) {
    final filtered = _aktivitas.where((a) => a.userId == userId).toList();
    filtered.sort((a, b) => b.tanggal.compareTo(a.tanggal));
    return filtered;
  }

  /// Total jarak (km) dari semua aktivitas milik user tertentu.
  double getTotalJarakKmByUser(String userId) {
    return _aktivitas
        .where((a) => a.userId == userId)
        .fold(0.0, (jumlah, a) => jumlah + a.jarakKm);
  }

  /// Total jarak diformat ke satu desimal, misal "26.1 km".
  String getTotalJarakFormattedByUser(String userId) =>
      '${getTotalJarakKmByUser(userId).toStringAsFixed(1)} km';

  /// Jumlah total sesi lari milik user tertentu.
  int getTotalSesiByUser(String userId) =>
      _aktivitas.where((a) => a.userId == userId).length;

  /// Total durasi semua aktivitas milik user tertentu (dalam menit).
  int getTotalWaktuMenitByUser(String userId) {
    return _aktivitas
        .where((a) => a.userId == userId)
        .fold(0, (jumlah, a) => jumlah + a.waktuMenit);
  }

  /// Total estimasi kalori terbakar milik user tertentu.
  int getTotalKaloriByUser(String userId) {
    return _aktivitas
        .where((a) => a.userId == userId)
        .fold(0, (jumlah, a) => jumlah + a.kaloriEstimasi);
  }

  /// Rata-rata pace dari semua aktivitas milik user tertentu, format "6:14 /km".
  String getAvgPaceFormattedByUser(String userId) {
    final totalJarak = getTotalJarakKmByUser(userId);
    if (totalJarak <= 0) return '--:--';
    final totalWaktu = getTotalWaktuMenitByUser(userId);
    final avgMenPerKm = totalWaktu / totalJarak;
    final totalDetik = (avgMenPerKm * 60).round();
    final menit = totalDetik ~/ 60;
    final detik = totalDetik % 60;
    return '$menit:${detik.toString().padLeft(2, '0')}';
  }

  // ===== OPERASI CRUD =====

  /// CREATE — Menambahkan aktivitas baru ke memori dan menyimpan ke DB.
  void tambah(AktivitasLari aktivitas) {
    _aktivitas.add(aktivitas);
    notifyListeners();
    _repo.tambah(aktivitas);
  }

  /// UPDATE — Memperbarui aktivitas di memori dan di DB berdasarkan ID.
  void perbarui(AktivitasLari aktivitasBaru) {
    final indeks = _aktivitas.indexWhere((a) => a.id == aktivitasBaru.id);
    if (indeks != -1) {
      _aktivitas[indeks] = aktivitasBaru;
      notifyListeners();
      _repo.perbarui(aktivitasBaru);
    }
  }

  /// DELETE — Menghapus aktivitas dari memori dan DB.
  ///
  /// Pemeriksaan ganda (id + userId) mencegah user A menghapus data user B.
  void hapus(String id, String userId) {
    _aktivitas.removeWhere((a) => a.id == id && a.userId == userId);
    notifyListeners();
    _repo.hapus(id);
  }
}

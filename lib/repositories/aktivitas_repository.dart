// File: aktivitas_repository.dart
// Layer Repository untuk operasi data aktivitas lari
// Mengabstraksikan DatabaseHelper sehingga ViewModel tidak perlu tahu detail SQLite

import '../database/database_helper.dart';
import '../models/aktivitas_lari.dart';

/// AktivitasRepository menangani semua operasi CRUD aktivitas lari ke SQLite.
///
/// Dalam pola MVVM, Repository adalah satu-satunya kelas yang boleh
/// berinteraksi langsung dengan [DatabaseHelper]. ViewModel hanya memanggil
/// metode Repository tanpa mengetahui cara data disimpan.
class AktivitasRepository {
  final DatabaseHelper _db;

  const AktivitasRepository(this._db);

  /// Mengambil semua aktivitas dari database dan mengonversinya ke [AktivitasLari].
  Future<List<AktivitasLari>> getAllActivities() async {
    final rows = await _db.getAllActivities();
    return rows.map(_fromRow).toList();
  }

  /// Menambahkan aktivitas baru ke database.
  Future<void> tambah(AktivitasLari a) => _db.insertActivity(_toMap(a));

  /// Memperbarui aktivitas yang sudah ada di database.
  Future<void> perbarui(AktivitasLari a) => _db.updateActivity(_toMap(a));

  /// Menghapus aktivitas dari database berdasarkan ID.
  Future<void> hapus(String id) => _db.deleteActivity(id);

  /// Memeriksa apakah tabel activities kosong.
  Future<bool> isEmpty() async {
    final list = await getAllActivities();
    return list.isEmpty;
  }

  /// Menyisipkan 5 aktivitas demo untuk akun Ahmad Pelari saat install pertama.
  Future<void> seedDemoData() async {
    final demoData = [
      {
        DatabaseHelper.colActId: 'seed_1',
        DatabaseHelper.colActUserId: 'demo_usr_001',
        DatabaseHelper.colActJarak: 5.2,
        DatabaseHelper.colActWaktu: 32,
        DatabaseHelper.colActTanggal: DateTime(2026, 5, 6).toIso8601String(),
        DatabaseHelper.colActCatatan: 'Lari pagi yang menyegarkan',
      },
      {
        DatabaseHelper.colActId: 'seed_2',
        DatabaseHelper.colActUserId: 'demo_usr_001',
        DatabaseHelper.colActJarak: 10.0,
        DatabaseHelper.colActWaktu: 65,
        DatabaseHelper.colActTanggal: DateTime(2026, 5, 4).toIso8601String(),
        DatabaseHelper.colActCatatan: 'Lari kelompok — seru!',
      },
      {
        DatabaseHelper.colActId: 'seed_3',
        DatabaseHelper.colActUserId: 'demo_usr_001',
        DatabaseHelper.colActJarak: 3.8,
        DatabaseHelper.colActWaktu: 22,
        DatabaseHelper.colActTanggal: DateTime(2026, 5, 2).toIso8601String(),
        DatabaseHelper.colActCatatan: '',
      },
      {
        DatabaseHelper.colActId: 'seed_4',
        DatabaseHelper.colActUserId: 'demo_usr_001',
        DatabaseHelper.colActJarak: 7.1,
        DatabaseHelper.colActWaktu: 44,
        DatabaseHelper.colActTanggal: DateTime(2026, 4, 30).toIso8601String(),
        DatabaseHelper.colActCatatan: 'Latihan ringan sebelum lomba',
      },
      {
        DatabaseHelper.colActId: 'seed_5',
        DatabaseHelper.colActUserId: 'demo_usr_001',
        DatabaseHelper.colActJarak: 8.5,
        DatabaseHelper.colActWaktu: 52,
        DatabaseHelper.colActTanggal: DateTime(2026, 4, 27).toIso8601String(),
        DatabaseHelper.colActCatatan: 'Sesi akhir pekan bersama tim',
      },
    ];

    for (final data in demoData) {
      await _db.insertActivity(data);
    }
  }

  // ===== HELPER KONVERSI =====

  AktivitasLari _fromRow(Map<String, dynamic> row) {
    return AktivitasLari(
      id: row[DatabaseHelper.colActId] as String,
      userId: row[DatabaseHelper.colActUserId] as String,
      jarakKm: (row[DatabaseHelper.colActJarak] as num).toDouble(),
      waktuMenit: row[DatabaseHelper.colActWaktu] as int,
      tanggal: DateTime.parse(row[DatabaseHelper.colActTanggal] as String),
      catatan: row[DatabaseHelper.colActCatatan] as String? ?? '',
    );
  }

  Map<String, dynamic> _toMap(AktivitasLari a) {
    return {
      DatabaseHelper.colActId: a.id,
      DatabaseHelper.colActUserId: a.userId,
      DatabaseHelper.colActJarak: a.jarakKm,
      DatabaseHelper.colActWaktu: a.waktuMenit,
      DatabaseHelper.colActTanggal: a.tanggal.toIso8601String(),
      DatabaseHelper.colActCatatan: a.catatan,
    };
  }
}

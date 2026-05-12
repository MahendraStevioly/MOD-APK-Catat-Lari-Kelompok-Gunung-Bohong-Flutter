// File: database_helper.dart
// Helper singleton untuk mengelola database SQLite lokal
// Menyimpan data akun dan aktivitas lari agar persist antar sesi

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// DatabaseHelper adalah singleton yang mengelola koneksi SQLite.
///
/// Dua tabel yang dikelola:
/// - [_tabelUsers]: menyimpan akun terdaaftar (id, nama, email, password)
/// - [_tabelActivities]: menyimpan aktivitas lari per-user
///
/// Pola singleton memastikan hanya ada satu koneksi DB di seluruh app.
class DatabaseHelper {
  // ===== SINGLETON =====

  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  // Instance database yang di-lazy-init saat pertama diakses
  Database? _database;

  // ===== NAMA TABEL & KOLOM =====

  static const String _namaDb = 'catat_lari.db';
  static const int _versiDb = 1;

  static const String _tabelUsers = 'users';
  static const String _tabelActivities = 'activities';

  // Kolom tabel users
  static const String colUserId = 'id';
  static const String colUserNama = 'nama';
  static const String colUserEmail = 'email';
  static const String colUserPassword = 'password';

  // Kolom tabel activities
  static const String colActId = 'id';
  static const String colActUserId = 'user_id';
  static const String colActJarak = 'jarak_km';
  static const String colActWaktu = 'waktu_menit';
  static const String colActTanggal = 'tanggal';
  static const String colActCatatan = 'catatan';

  // ===== INISIALISASI =====

  /// Mengembalikan instance database, membukanya jika belum ada.
  Future<Database> get database async {
    _database ??= await _bukaDatabse();
    return _database!;
  }

  /// Membuka atau membuat file database di direktori default device.
  Future<Database> _bukaDatabse() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _namaDb);

    return openDatabase(
      path,
      version: _versiDb,
      onCreate: _onCreate,
    );
  }

  /// Membuat skema tabel saat database pertama kali dibuat.
  Future<void> _onCreate(Database db, int version) async {
    // Tabel akun terdaftar — email harus unik
    await db.execute('''
      CREATE TABLE $_tabelUsers (
        $colUserId       TEXT PRIMARY KEY,
        $colUserNama     TEXT NOT NULL,
        $colUserEmail    TEXT UNIQUE NOT NULL,
        $colUserPassword TEXT NOT NULL
      )
    ''');

    // Tabel aktivitas lari — diindeks per user_id untuk query cepat
    await db.execute('''
      CREATE TABLE $_tabelActivities (
        $colActId     TEXT PRIMARY KEY,
        $colActUserId TEXT NOT NULL,
        $colActJarak  REAL NOT NULL,
        $colActWaktu  INTEGER NOT NULL,
        $colActTanggal TEXT NOT NULL,
        $colActCatatan TEXT NOT NULL DEFAULT ""
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_activities_user ON $_tabelActivities ($colActUserId)',
    );
  }

  // ===== CRUD: USERS =====

  /// Mengambil semua akun terdaftar dari database
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await database;
    return db.query(_tabelUsers);
  }

  /// Menyisipkan satu akun baru. Diabaikan jika email sudah ada (IGNORE).
  Future<void> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    await db.insert(
      _tabelUsers,
      user,
      // IGNORE: jangan lempar error jika email duplikat saat seed ulang
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  // ===== CRUD: ACTIVITIES =====

  /// Mengambil semua aktivitas dari database (semua user)
  Future<List<Map<String, dynamic>>> getAllActivities() async {
    final db = await database;
    return db.query(_tabelActivities);
  }

  /// Menyisipkan satu aktivitas baru ke database.
  /// REPLACE: timpa jika ID sudah ada (dipakai saat seed ulang).
  Future<void> insertActivity(Map<String, dynamic> activity) async {
    final db = await database;
    await db.insert(
      _tabelActivities,
      activity,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Memperbarui data aktivitas yang sudah ada berdasarkan kolom 'id'.
  Future<void> updateActivity(Map<String, dynamic> activity) async {
    final db = await database;
    await db.update(
      _tabelActivities,
      activity,
      where: '$colActId = ?',
      whereArgs: [activity[colActId]],
    );
  }

  /// Menghapus satu aktivitas berdasarkan ID.
  Future<void> deleteActivity(String id) async {
    final db = await database;
    await db.delete(
      _tabelActivities,
      where: '$colActId = ?',
      whereArgs: [id],
    );
  }
}

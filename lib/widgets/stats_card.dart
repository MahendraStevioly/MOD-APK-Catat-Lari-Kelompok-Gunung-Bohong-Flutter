// File: stats_card.dart
// Widget kartu statistik ringkas yang dapat digunakan ulang di seluruh aplikasi
// Menampilkan satu angka statistik dengan ikon, nilai, dan label

import 'package:flutter/material.dart';

/// StatsCard menampilkan satu buah statistik dalam format kartu persegi panjang.
/// Terdiri dari kotak ikon berwarna, nilai besar, dan label di bawahnya.
///
/// Biasanya digunakan dalam baris scroll horizontal di HomeView dan
/// bagian statistik keseluruhan di ProfileView.
///
/// Contoh penggunaan:
/// ```dart
/// StatsCard(
///   label: 'Jarak',
///   nilai: '26.1 km',
///   ikon: Icons.map_outlined,
///   warna: colorScheme.primary,
/// )
/// ```
class StatsCard extends StatelessWidget {
  /// Label deskripsi statistik yang ditampilkan di bawah nilai.
  /// Contoh: "Jarak", "Waktu", "Kalori", "Sesi"
  final String label;

  /// Nilai statistik yang ditampilkan dengan font tebal.
  /// Contoh: "26.1 km", "1j 5m", "1530 kal"
  final String nilai;

  /// Ikon yang mewakili jenis statistik — ditampilkan di kotak berwarna
  final IconData ikon;

  /// Warna aksen kartu — dipakai untuk ikon dan latar kotak ikonnya
  final Color warna;

  const StatsCard({
    super.key,
    required this.label,
    required this.nilai,
    required this.ikon,
    required this.warna,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Kotak ikon dengan latar warna transparan — warna sesuai jenis statistik
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              // Warna 10% opasitas agar tidak mendominasi
              color: warna.withAlpha(26),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(ikon, color: warna, size: 18),
          ),

          // Nilai statistik — ukuran dan bobot font besar agar mudah terbaca
          Text(
            nilai,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),

          // Label jenis statistik di bawah nilai
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

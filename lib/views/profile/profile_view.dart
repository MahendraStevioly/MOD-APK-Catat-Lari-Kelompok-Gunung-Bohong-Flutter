// File: profile_view.dart
// View untuk halaman profil — hanya bertanggung jawab menampilkan UI
// Data dan logika bersumber dari AuthViewModel dan AktivitasViewModel

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/aktivitas_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../utils/app_constants.dart';
import '../../utils/app_routes.dart';

/// ProfileView menampilkan profil pengguna yang sedang login.
///
/// Dalam pola MVVM:
/// - View (ini): rendering UI + meneruskan aksi logout ke ViewModel
/// - ViewModel : [AuthViewModel] (data user + logout), [AktivitasViewModel] (statistik)
class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // View mengamati kedua ViewModel sekaligus
    return Consumer2<AuthViewModel, AktivitasViewModel>(
      builder: (context, authVM, aktivitasVM, _) {
        final user = authVM.currentUser;
        final nama = user?.nama ?? 'Pengguna';
        final email = user?.email ?? '-';
        final userId = user?.id ?? '';

        return Scaffold(
          backgroundColor: colorScheme.surfaceContainerLowest,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text(AppStrings.judulProfil),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () {},
                tooltip: AppStrings.editProfil,
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeaderProfil(nama, email, colorScheme),
                const SizedBox(height: AppSizes.paddingKonten),
                _buildStatistikKeseluruhan(aktivitasVM, colorScheme, userId),
                const SizedBox(height: AppSizes.paddingKonten),
                _buildPencapaian(aktivitasVM, colorScheme, userId),
                const SizedBox(height: AppSizes.paddingKonten),
                _buildMenuPengaturan(context, colorScheme),
                const SizedBox(height: AppSizes.paddingKonten),
                _buildTombolKeluar(context, colorScheme),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderProfil(
    String nama,
    String email,
    ColorScheme colorScheme,
  ) {
    final inisial = nama
        .split(' ')
        .take(2)
        .map((kata) => kata.isNotEmpty ? kata[0] : '')
        .join()
        .toUpperCase();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [colorScheme.primary, colorScheme.primaryContainer],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSizes.paddingKonten,
        AppSizes.paddingHalamanH,
        AppSizes.paddingKonten,
        32,
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: AppSizes.ukuranAvatarBesar,
                height: AppSizes.ukuranAvatarBesar,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.primaryContainer,
                  border: Border.all(color: AppColors.overlay, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.bayangan
                          .withAlpha(AppColors.alphaOverlayLemah),
                      blurRadius: AppSizes.blurBayanganBesar,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    inisial,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: colorScheme.secondary,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.overlay, width: 2),
                ),
                child: Icon(
                  Icons.camera_alt_rounded,
                  size: AppSizes.ikonKecil,
                  color: colorScheme.onSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingKartu),
          Text(
            nama,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: colorScheme.onPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: TextStyle(
              fontSize: AppSizes.teksSedang,
              color: colorScheme.onPrimary.withAlpha(AppColors.alphaTeksNormal),
            ),
          ),
          const SizedBox(height: AppSizes.paddingKecil),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingKecil,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: AppColors.overlay.withAlpha(AppColors.alphaOverlayLemah),
              borderRadius: BorderRadius.circular(AppSizes.radiusBadge),
              border: Border.all(
                color: AppColors.overlay.withAlpha(AppColors.alphaPemisah),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.group_rounded,
                  size: AppSizes.ikonKecil,
                  color: colorScheme.onPrimary,
                ),
                const SizedBox(width: 6),
                Text(
                  AppStrings.namaKelompok,
                  style: TextStyle(
                    fontSize: AppSizes.teksLabel,
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistikKeseluruhan(
    AktivitasViewModel aktivitasVM,
    ColorScheme colorScheme,
    String userId,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingKonten),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingKonten),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusKartu),
          boxShadow: [
            BoxShadow(
              color: AppColors.bayangan.withAlpha(AppColors.alphaBayanganHalus),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.pencapaianKeseluruhan,
              style: TextStyle(
                fontSize: AppSizes.teksNormal,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSizes.paddingKartu),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildItemStatistik(
                  nilai: aktivitasVM
                      .getTotalJarakKmByUser(userId)
                      .toStringAsFixed(1),
                  satuan: 'km',
                  label: AppStrings.totalJarak,
                  ikon: Icons.route_rounded,
                  warnaPrimary: colorScheme.primary,
                  colorScheme: colorScheme,
                ),
                Container(
                  height: 50,
                  width: 1,
                  color: colorScheme.outlineVariant,
                ),
                _buildItemStatistik(
                  nilai: '${aktivitasVM.getTotalSesiByUser(userId)}',
                  satuan: 'sesi',
                  label: 'Sesi Lari',
                  ikon: Icons.flag_rounded,
                  warnaPrimary: colorScheme.tertiary,
                  colorScheme: colorScheme,
                ),
                Container(
                  height: 50,
                  width: 1,
                  color: colorScheme.outlineVariant,
                ),
                _buildItemStatistik(
                  nilai: '${aktivitasVM.getTotalKaloriByUser(userId)}',
                  satuan: 'kal',
                  label: AppStrings.kalori,
                  ikon: Icons.local_fire_department_outlined,
                  warnaPrimary: AppColors.kalori,
                  colorScheme: colorScheme,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemStatistik({
    required String nilai,
    required String satuan,
    required String label,
    required IconData ikon,
    required Color warnaPrimary,
    required ColorScheme colorScheme,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: warnaPrimary.withAlpha(AppColors.alphaLatarIkon),
            shape: BoxShape.circle,
          ),
          child: Icon(ikon, color: warnaPrimary, size: 22),
        ),
        const SizedBox(height: AppSizes.paddingTerkecil),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: nilai,
                style: TextStyle(
                  fontSize: AppSizes.teksSub,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              TextSpan(
                text: ' $satuan',
                style: TextStyle(
                  fontSize: AppSizes.teksLabel,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: AppSizes.teksLabel,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildPencapaian(
    AktivitasViewModel aktivitasVM,
    ColorScheme colorScheme,
    String userId,
  ) {
    final totalJarak = aktivitasVM.getTotalJarakKmByUser(userId);
    final totalSesi = aktivitasVM.getTotalSesiByUser(userId);

    final daftarBadge = [
      {
        'label': AppStrings.badge5k,
        'ikon': Icons.emoji_events_rounded,
        'tercapai': totalJarak >= 5,
      },
      {
        'label': AppStrings.badge10k,
        'ikon': Icons.workspace_premium_rounded,
        'tercapai': totalJarak >= 10,
      },
      {
        'label': AppStrings.badge5Sesi,
        'ikon': Icons.military_tech_rounded,
        'tercapai': totalSesi >= 5,
      },
      {
        'label': AppStrings.badge10Sesi,
        'ikon': Icons.calendar_month_rounded,
        'tercapai': totalSesi >= 10,
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingKonten),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingKonten),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusKartu),
          boxShadow: [
            BoxShadow(
              color: AppColors.bayangan.withAlpha(AppColors.alphaBayanganHalus),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.badgePencapaian,
              style: TextStyle(
                fontSize: AppSizes.teksNormal,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSizes.paddingKartu),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: daftarBadge.map((badge) {
                final tercapai = badge['tercapai'] as bool;
                return Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: tercapai
                            ? colorScheme.primaryContainer
                            : colorScheme.surfaceContainerHighest,
                      ),
                      child: Icon(
                        badge['ikon'] as IconData,
                        color: tercapai
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant
                                .withAlpha(AppColors.alphaPemisah),
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      badge['label'] as String,
                      style: TextStyle(
                        fontSize: AppSizes.teksMini,
                        color: tercapai
                            ? colorScheme.onSurface
                            : colorScheme.onSurfaceVariant
                                .withAlpha(AppColors.alphaTeksSekunder),
                        fontWeight:
                            tercapai ? FontWeight.w600 : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuPengaturan(BuildContext context, ColorScheme colorScheme) {
    final daftarMenu = [
      {
        'ikon': Icons.person_outline_rounded,
        'judul': AppStrings.editProfil,
        'subjudul': 'Ubah nama, foto, dan data diri',
      },
      {
        'ikon': Icons.notifications_outlined,
        'judul': 'Notifikasi',
        'subjudul': 'Atur preferensi notifikasi',
      },
      {
        'ikon': Icons.privacy_tip_outlined,
        'judul': 'Privasi',
        'subjudul': 'Kelola data dan privasi akun',
      },
      {
        'ikon': Icons.help_outline_rounded,
        'judul': 'Bantuan',
        'subjudul': 'Pusat bantuan dan FAQ',
      },
      {
        'ikon': Icons.info_outline_rounded,
        'judul': 'Tentang Aplikasi',
        'subjudul': 'Versi 1.0.0 - ${AppStrings.namaApp}',
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingKonten),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusKartu),
          boxShadow: [
            BoxShadow(
              color: AppColors.bayangan.withAlpha(AppColors.alphaBayanganHalus),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: daftarMenu.asMap().entries.map((entry) {
            final isLast = entry.key == daftarMenu.length - 1;
            final menu = entry.value;
            return Column(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingKartu,
                    vertical: 4,
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(AppSizes.paddingTerkecil),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withAlpha(128),
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusKecil + 2),
                    ),
                    child: Icon(
                      menu['ikon'] as IconData,
                      color: colorScheme.primary,
                      size: AppSizes.ikonStandar,
                    ),
                  ),
                  title: Text(
                    menu['judul'] as String,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                  subtitle: Text(
                    menu['subjudul'] as String,
                    style: TextStyle(
                      fontSize: AppSizes.teksLabel,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  onTap: () {},
                ),
                if (!isLast)
                  Divider(
                    height: 1,
                    indent: 56,
                    color: colorScheme.outlineVariant.withAlpha(128),
                  ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTombolKeluar(BuildContext context, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingKonten),
      child: OutlinedButton.icon(
        onPressed: () {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text(AppStrings.keluarDariAkun),
              content: const Text(AppStrings.konfirmasiKeluar),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusKartu),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text(AppStrings.tombolBatal),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.error,
                    foregroundColor: colorScheme.onError,
                  ),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    // View meneruskan aksi logout ke AuthViewModel
                    context.read<AuthViewModel>().logout();
                    context.go(AppRoutes.login);
                  },
                  child: const Text(AppStrings.tombolKeluar),
                ),
              ],
            ),
          );
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.error,
          side: BorderSide(color: colorScheme.error),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusButton),
          ),
        ),
        icon: const Icon(Icons.logout_rounded),
        label: const Text(
          AppStrings.keluarDariAkun,
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

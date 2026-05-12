// File: home_view.dart
// View untuk halaman utama — hanya bertanggung jawab menampilkan UI
// Data dan logika bersumber dari AuthViewModel dan AktivitasViewModel

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/aktivitas_lari.dart';
import '../../viewmodels/aktivitas_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../utils/app_constants.dart';
import '../../utils/app_routes.dart';
import '../../widgets/activity_card.dart';
import '../../widgets/stats_card.dart';
import '../../widgets/weekly_stats_widget.dart';
import 'form_aktivitas_view.dart';

/// HomeView adalah halaman utama yang menampilkan sapaan, statistik, dan daftar aktivitas.
///
/// Dalam pola MVVM:
/// - View (ini): rendering UI + meneruskan aksi pengguna ke ViewModel
/// - ViewModel : [AuthViewModel] (data user), [AktivitasViewModel] (data aktivitas + CRUD)
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  void _tampilkanForm(BuildContext context, {AktivitasLari? aktivitasYangDiEdit}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FormAktivitasView(aktivitasYangDiEdit: aktivitasYangDiEdit),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // View mengamati kedua ViewModel sekaligus — rebuild otomatis saat data berubah
    return Consumer2<AuthViewModel, AktivitasViewModel>(
      builder: (context, authVM, aktivitasVM, _) {
        final user = authVM.currentUser!;
        final userId = user.id;
        final namaDepan = user.nama.split(' ').first;
        final inisial = user.nama.isNotEmpty ? user.nama[0].toUpperCase() : 'U';

        final daftarAktivitas = aktivitasVM.getAktivitasByUser(userId);

        return Scaffold(
          backgroundColor: colorScheme.surfaceContainerLowest,
          appBar: _buildAppBar(context, colorScheme, inisial),
          body: RefreshIndicator(
            onRefresh: () async {
              await Future.delayed(const Duration(milliseconds: 500));
            },
            color: colorScheme.primary,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _buildBannerHeader(
                    colorScheme,
                    namaDepan,
                    aktivitasVM,
                    userId,
                  ),
                ),
                SliverToBoxAdapter(
                  child: WeeklyStatsWidget(daftarAktivitas: daftarAktivitas),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSizes.paddingKonten,
                      AppSizes.paddingKonten,
                      AppSizes.paddingKonten,
                      0,
                    ),
                    child: Text(
                      AppStrings.statistikKeseluruhan,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _buildStatistikRow(colorScheme, aktivitasVM, userId),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSizes.paddingKonten,
                      AppSizes.paddingHalamanH,
                      4,
                      AppSizes.paddingTerkecil,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppStrings.aktivitasTerkini,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        if (daftarAktivitas.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusBadge,
                              ),
                            ),
                            child: Text(
                              '${daftarAktivitas.length} sesi',
                              style: TextStyle(
                                fontSize: AppSizes.teksLabel,
                                color: colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (daftarAktivitas.isEmpty)
                  SliverFillRemaining(
                    child: _buildEmptyState(context, colorScheme),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSizes.paddingKonten,
                      0,
                      AppSizes.paddingKonten,
                      120,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final aktivitas = daftarAktivitas[index];
                          return AktivitasCard(
                            aktivitas: aktivitas,
                            onEdit: () => _tampilkanForm(
                              context,
                              aktivitasYangDiEdit: aktivitas,
                            ),
                            onHapus: () {
                              // View meneruskan aksi hapus ke AktivitasViewModel
                              context
                                  .read<AktivitasViewModel>()
                                  .hapus(aktivitas.id, userId);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    AppStrings.aktivitasDihapus,
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: colorScheme.error,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppSizes.radiusSnackbar,
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        childCount: daftarAktivitas.length,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _tampilkanForm(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text(
              AppStrings.fabCatatLari,
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    ColorScheme colorScheme,
    String inisial,
  ) {
    return AppBar(
      title: Row(
        children: [
          Icon(Icons.directions_run_rounded, color: colorScheme.onPrimary),
          const SizedBox(width: AppSizes.paddingTerkecil),
          const Text(AppStrings.namaApp),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {},
          tooltip: 'Notifikasi',
        ),
        GestureDetector(
          onTap: () => context.go(AppRoutes.profile),
          child: Container(
            margin: const EdgeInsets.only(right: AppSizes.paddingKartu),
            child: CircleAvatar(
              radius: AppSizes.radiusAvatarKecil,
              backgroundColor: colorScheme.primaryContainer,
              child: Text(
                inisial,
                style: TextStyle(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBannerHeader(
    ColorScheme colorScheme,
    String namaDepan,
    AktivitasViewModel aktivitasVM,
    String userId,
  ) {
    final totalSesi = aktivitasVM.getTotalSesiByUser(userId);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorScheme.primary, colorScheme.tertiary],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSizes.paddingHalamanH,
        AppSizes.paddingHalamanH,
        AppSizes.paddingHalamanH,
        36,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Halo, $namaDepan! 👋',
            style: TextStyle(
              fontSize: AppSizes.teksHeading,
              fontWeight: FontWeight.bold,
              color: colorScheme.onPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            totalSesi == 0 ? AppStrings.pesanAjakan : AppStrings.pesanMotivasi,
            style: TextStyle(
              fontSize: AppSizes.teksSedang,
              color: colorScheme.onPrimary.withAlpha(AppColors.alphaTeksNormal),
            ),
          ),
          const SizedBox(height: AppSizes.paddingKonten),
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingKartu),
            decoration: BoxDecoration(
              color: AppColors.overlay.withAlpha(AppColors.alphaOverlayLemah),
              borderRadius: BorderRadius.circular(AppSizes.radiusKartu),
              border: Border.all(
                color: AppColors.overlay.withAlpha(AppColors.alphaOverlaySedang),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildRingkasanItem(
                    label: AppStrings.totalJarak,
                    nilai: aktivitasVM.getTotalJarakFormattedByUser(userId),
                    ikon: Icons.route_rounded,
                    warna: colorScheme.onPrimary,
                  ),
                ),
                Container(
                  height: 40,
                  width: 1,
                  color: AppColors.overlay.withAlpha(AppColors.alphaPemisah),
                ),
                Expanded(
                  child: _buildRingkasanItem(
                    label: AppStrings.totalSesi,
                    nilai: '${totalSesi}x',
                    ikon: Icons.flag_rounded,
                    warna: colorScheme.onPrimary,
                  ),
                ),
                Container(
                  height: 40,
                  width: 1,
                  color: AppColors.overlay.withAlpha(AppColors.alphaPemisah),
                ),
                Expanded(
                  child: _buildRingkasanItem(
                    label: AppStrings.avgPace,
                    nilai: aktivitasVM.getAvgPaceFormattedByUser(userId),
                    ikon: Icons.speed_rounded,
                    warna: colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRingkasanItem({
    required String label,
    required String nilai,
    required IconData ikon,
    required Color warna,
  }) {
    return Column(
      children: [
        Icon(
          ikon,
          color: warna.withAlpha(AppColors.alphaTeksNormal),
          size: AppSizes.ikonStandar,
        ),
        const SizedBox(height: 4),
        Text(
          nilai,
          style: TextStyle(
            fontSize: AppSizes.teksNormal,
            fontWeight: FontWeight.bold,
            color: warna,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: AppSizes.teksMini,
            color: warna.withAlpha(AppColors.alphaTeksIkon),
          ),
        ),
      ],
    );
  }

  Widget _buildStatistikRow(
    ColorScheme colorScheme,
    AktivitasViewModel aktivitasVM,
    String userId,
  ) {
    final totalWaktuMenit = aktivitasVM.getTotalWaktuMenitByUser(userId);

    return SizedBox(
      height: AppSizes.tinggiScrollStat,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(
          AppSizes.paddingKonten,
          AppSizes.paddingKecil,
          AppSizes.paddingKonten,
          0,
        ),
        children: [
          StatsCard(
            label: AppStrings.jarak,
            nilai: aktivitasVM.getTotalJarakFormattedByUser(userId),
            ikon: Icons.map_outlined,
            warna: colorScheme.primary,
          ),
          StatsCard(
            label: AppStrings.waktu,
            nilai: totalWaktuMenit >= 60
                ? '${totalWaktuMenit ~/ 60}j ${totalWaktuMenit % 60}m'
                : '${totalWaktuMenit}m',
            ikon: Icons.timer_outlined,
            warna: colorScheme.tertiary,
          ),
          StatsCard(
            label: AppStrings.kalori,
            nilai: '${aktivitasVM.getTotalKaloriByUser(userId)}',
            ikon: Icons.local_fire_department_outlined,
            warna: AppColors.kalori,
          ),
          StatsCard(
            label: AppStrings.sesi,
            nilai: '${aktivitasVM.getTotalSesiByUser(userId)}x',
            ikon: Icons.repeat_rounded,
            warna: colorScheme.secondary,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: AppSizes.ukuranAvatarBesar,
              height: AppSizes.ukuranAvatarBesar,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withAlpha(128),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.directions_run_rounded,
                size: AppSizes.ikonBesar,
                color: colorScheme.primary.withAlpha(AppColors.alphaTeksSekunder),
              ),
            ),
            const SizedBox(height: AppSizes.paddingKonten),
            Text(
              AppStrings.belumAdaAktivitas,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSizes.paddingTerkecil),
            Text(
              AppStrings.pesanEmptyAktivitas,
              style: TextStyle(
                fontSize: AppSizes.teksSedang,
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.paddingHalamanH),
            FilledButton.icon(
              onPressed: () => _tampilkanForm(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text(AppStrings.catatLariSekarang),
            ),
          ],
        ),
      ),
    );
  }
}

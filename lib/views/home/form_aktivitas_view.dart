// File: form_aktivitas_view.dart
// View untuk form tambah/edit aktivitas lari — ditampilkan sebagai modal bottom sheet
// Logika CRUD didelegasikan ke AktivitasViewModel; logika UI form tetap di View

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/aktivitas_lari.dart';
import '../../viewmodels/aktivitas_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../utils/app_constants.dart';

/// FormAktivitasView adalah form modal untuk operasi CREATE dan UPDATE aktivitas lari.
///
/// Dalam pola MVVM:
/// - View (ini): rendering form UI + validasi input
/// - ViewModel : [AktivitasViewModel] (operasi CRUD), [AuthViewModel] (userId saat CREATE)
///
/// Mode ditentukan oleh [aktivitasYangDiEdit]:
/// - null → mode TAMBAH BARU
/// - berisi objek → mode EDIT (form pre-filled)
class FormAktivitasView extends StatefulWidget {
  final AktivitasLari? aktivitasYangDiEdit;

  const FormAktivitasView({super.key, this.aktivitasYangDiEdit});

  @override
  State<FormAktivitasView> createState() => _FormAktivitasViewState();
}

class _FormAktivitasViewState extends State<FormAktivitasView> {
  final _formKey = GlobalKey<FormState>();
  final _jarakController = TextEditingController();
  final _jamController = TextEditingController();
  final _menitController = TextEditingController();
  final _catatanController = TextEditingController();

  late DateTime _tanggalDipilih;
  bool _isLoading = false;

  bool get _isEditMode => widget.aktivitasYangDiEdit != null;

  @override
  void initState() {
    super.initState();
    _tanggalDipilih = DateTime.now();

    if (_isEditMode) {
      final a = widget.aktivitasYangDiEdit!;
      _jarakController.text = a.jarakKm.toStringAsFixed(1);
      _jamController.text = (a.waktuMenit ~/ 60).toString();
      _menitController.text = (a.waktuMenit % 60).toString();
      _catatanController.text = a.catatan;
      _tanggalDipilih = a.tanggal;
    }
  }

  @override
  void dispose() {
    _jarakController.dispose();
    _jamController.dispose();
    _menitController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _pilihTanggal() async {
    final terpilih = await showDatePicker(
      context: context,
      initialDate: _tanggalDipilih,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'Pilih Tanggal Lari',
      confirmText: 'Pilih',
      cancelText: AppStrings.tombolBatal,
    );
    if (terpilih != null) {
      setState(() => _tanggalDipilih = terpilih);
    }
  }

  /// Memvalidasi input lalu mendelegasikan operasi simpan ke [AktivitasViewModel].
  void _simpan() {
    if (!_formKey.currentState!.validate()) return;

    final jam = int.tryParse(_jamController.text) ?? 0;
    final menit = int.tryParse(_menitController.text) ?? 0;
    final totalMenit = jam * 60 + menit;

    if (totalMenit <= 0) {
      final colorScheme = Theme.of(context).colorScheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(AppStrings.validasiDurasi),
          backgroundColor: colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusSnackbar),
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // View membaca AktivitasViewModel untuk operasi CRUD
    final aktivitasVM = context.read<AktivitasViewModel>();
    final jarak = double.parse(_jarakController.text.replaceAll(',', '.'));

    if (_isEditMode) {
      // UPDATE — buat objek baru dengan nilai yang diperbarui (immutable pattern)
      final aktivitasBaru = widget.aktivitasYangDiEdit!.copyWith(
        jarakKm: jarak,
        waktuMenit: totalMenit,
        tanggal: _tanggalDipilih,
        catatan: _catatanController.text.trim(),
      );
      aktivitasVM.perbarui(aktivitasBaru);
    } else {
      // CREATE — userId diambil dari AuthViewModel
      final userId = context.read<AuthViewModel>().currentUser!.id;
      final aktivitasBaru = AktivitasLari(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        jarakKm: jarak,
        waktuMenit: totalMenit,
        tanggal: _tanggalDipilih,
        catatan: _catatanController.text.trim(),
      );
      aktivitasVM.tambah(aktivitasBaru);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isEditMode
              ? 'Aktivitas berhasil diperbarui!'
              : 'Aktivitas lari berhasil dicatat!',
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSnackbar),
        ),
      ),
    );

    Navigator.of(context).pop();
  }

  String _formatTanggal(DateTime tanggal) {
    const namaHari = [
      'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu',
    ];
    const namaBulan = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    final hari = namaHari[tanggal.weekday - 1];
    final bulan = namaBulan[tanggal.month - 1];
    return '$hari, ${tanggal.day} $bulan ${tanggal.year}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.paddingHalamanH,
            AppSizes.paddingKecil,
            AppSizes.paddingHalamanH,
            AppSizes.paddingHalamanH,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== DRAG HANDLE =====
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: AppSizes.paddingKonten),
                    decoration: BoxDecoration(
                      color: colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // ===== JUDUL FORM =====
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSizes.paddingTerkecil),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusKecil + 2),
                      ),
                      child: Icon(
                        Icons.directions_run_rounded,
                        color: colorScheme.onPrimaryContainer,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: AppSizes.paddingKecil),
                    Text(
                      _isEditMode
                          ? AppStrings.judulFormEdit
                          : AppStrings.judulFormTambah,
                      style: TextStyle(
                        fontSize: AppSizes.teksSub,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSizes.paddingHalamanH),

                // ===== PILIH TANGGAL =====
                Text(
                  'Tanggal',
                  style: TextStyle(
                    fontSize: AppSizes.teksKecil,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingTerkecil),
                InkWell(
                  onTap: _pilihTanggal,
                  borderRadius: BorderRadius.circular(AppSizes.radiusButton),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingKartu,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: colorScheme.outline.withAlpha(128),
                      ),
                      borderRadius: BorderRadius.circular(AppSizes.radiusButton),
                      color: colorScheme.surfaceContainerHighest.withAlpha(
                        AppColors.alphaOverlaySedang,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: AppSizes.ikonKartu,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: AppSizes.paddingKecil),
                        Text(
                          _formatTanggal(_tanggalDipilih),
                          style: TextStyle(
                            fontSize: 15,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.arrow_drop_down_rounded,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSizes.paddingKonten),

                // ===== INPUT JARAK =====
                Text(
                  'Jarak (km)',
                  style: TextStyle(
                    fontSize: AppSizes.teksKecil,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingTerkecil),
                TextFormField(
                  controller: _jarakController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                  ],
                  decoration: const InputDecoration(
                    hintText: 'Contoh: 5.2',
                    prefixIcon: Icon(Icons.route_rounded),
                    suffixText: 'km',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Jarak tidak boleh kosong';
                    }
                    final jarak = double.tryParse(value.replaceAll(',', '.'));
                    if (jarak == null || jarak <= 0) {
                      return 'Masukkan jarak yang valid (lebih dari 0)';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSizes.paddingKonten),

                // ===== INPUT DURASI =====
                Text(
                  'Durasi',
                  style: TextStyle(
                    fontSize: AppSizes.teksKecil,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingTerkecil),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _jamController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: const InputDecoration(
                          hintText: '0',
                          prefixIcon: Icon(Icons.timer_outlined),
                          suffixText: 'jam',
                        ),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (int.tryParse(value) == null) {
                              return 'Angka tidak valid';
                            }
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: AppSizes.paddingKecil),
                    Expanded(
                      child: TextFormField(
                        controller: _menitController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          hintText: '30',
                          prefixIcon: Icon(Icons.schedule_rounded),
                          suffixText: 'menit',
                        ),
                        validator: (value) {
                          final menit = int.tryParse(value ?? '');
                          if (menit != null && (menit < 0 || menit > 59)) {
                            return 'Menit harus 0–59';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSizes.paddingKonten),

                // ===== CATATAN OPSIONAL =====
                Text(
                  'Catatan (opsional)',
                  style: TextStyle(
                    fontSize: AppSizes.teksKecil,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingTerkecil),
                TextFormField(
                  controller: _catatanController,
                  maxLines: 3,
                  maxLength: 200,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    hintText: 'Ceritakan sesi lari kamu...',
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(bottom: 48),
                      child: Icon(Icons.notes_rounded),
                    ),
                    alignLabelWithHint: true,
                  ),
                ),

                const SizedBox(height: AppSizes.paddingTerkecil),

                // ===== TOMBOL AKSI =====
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusButton),
                          ),
                        ),
                        child: const Text(AppStrings.tombolBatal),
                      ),
                    ),
                    const SizedBox(width: AppSizes.paddingKecil),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _simpan,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusButton),
                          ),
                        ),
                        icon: _isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(
                                _isEditMode
                                    ? Icons.check_rounded
                                    : Icons.save_rounded,
                                size: AppSizes.ikonKartu,
                              ),
                        label: Text(
                          _isEditMode
                              ? AppStrings.tombolPerbarui
                              : AppStrings.tombolSimpan,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

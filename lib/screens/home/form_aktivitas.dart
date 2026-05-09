// File: form_aktivitas.dart
// Widget form untuk mencatat aktivitas lari baru atau mengedit yang sudah ada
// Ditampilkan sebagai modal bottom sheet dari HomeScreen

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/aktivitas_lari.dart';
import '../../providers/aktivitas_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_constants.dart';

/// FormAktivitas adalah form untuk operasi CREATE dan UPDATE aktivitas lari.
/// Jika [aktivitasYangDiEdit] diisi → mode EDIT (form pre-filled).
/// Jika null → mode TAMBAH BARU.
class FormAktivitas extends StatefulWidget {
  // Aktivitas yang ingin diedit. Null jika sedang menambah aktivitas baru.
  final AktivitasLari? aktivitasYangDiEdit;

  const FormAktivitas({super.key, this.aktivitasYangDiEdit});

  @override
  State<FormAktivitas> createState() => _FormAktivitasState();
}

class _FormAktivitasState extends State<FormAktivitas> {
  // Kunci global untuk mengakses dan memvalidasi seluruh Form
  final _formKey = GlobalKey<FormState>();

  // Controller untuk field input jarak (km)
  final _jarakController = TextEditingController();

  // Controller untuk field input jam (bagian dari durasi)
  final _jamController = TextEditingController();

  // Controller untuk field input menit (bagian dari durasi)
  final _menitController = TextEditingController();

  // Controller untuk field catatan bebas
  final _catatanController = TextEditingController();

  // Tanggal yang dipilih oleh pengguna — default hari ini
  late DateTime _tanggalDipilih;

  // Status loading saat proses menyimpan
  bool _isLoading = false;

  /// true = sedang mengedit aktivitas lama, false = menambah baru
  bool get _isEditMode => widget.aktivitasYangDiEdit != null;

  @override
  void initState() {
    super.initState();
    _tanggalDipilih = DateTime.now();

    // Jika mode edit, isi semua field dengan data aktivitas yang ada
    if (_isEditMode) {
      final a = widget.aktivitasYangDiEdit!;
      _jarakController.text = a.jarakKm.toStringAsFixed(1);
      // Pisahkan total menit menjadi jam dan menit
      _jamController.text = (a.waktuMenit ~/ 60).toString();
      _menitController.text = (a.waktuMenit % 60).toString();
      _catatanController.text = a.catatan;
      _tanggalDipilih = a.tanggal;
    }
  }

  /// Membersihkan semua controller saat widget dihapus dari tree
  @override
  void dispose() {
    _jarakController.dispose();
    _jamController.dispose();
    _menitController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  /// Membuka dialog date picker untuk memilih tanggal aktivitas
  Future<void> _pilihTanggal() async {
    final terpilih = await showDatePicker(
      context: context,
      initialDate: _tanggalDipilih,
      // Batasi pilihan tanggal: mulai 2020 hingga hari ini
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'Pilih Tanggal Lari',
      confirmText: 'Pilih',
      cancelText: AppStrings.tombolBatal,
    );

    // Update state hanya jika pengguna benar-benar memilih tanggal
    if (terpilih != null) {
      setState(() => _tanggalDipilih = terpilih);
    }
  }

  /// Menyimpan aktivitas baru atau memperbarui aktivitas yang ada.
  /// Dipanggil saat tombol "Simpan" ditekan.
  void _simpan() {
    // Hentikan jika ada field yang tidak lolos validasi
    if (!_formKey.currentState!.validate()) return;

    // Hitung total durasi dalam menit dari jam dan menit yang diinput
    final jam = int.tryParse(_jamController.text) ?? 0;
    final menit = int.tryParse(_menitController.text) ?? 0;
    final totalMenit = jam * 60 + menit;

    // Validasi tambahan: durasi harus lebih dari 0
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

    // Ambil provider dari context untuk operasi CRUD
    final provider = context.read<AktivitasProvider>();
    final jarak = double.parse(_jarakController.text.replaceAll(',', '.'));

    if (_isEditMode) {
      // UPDATE — buat objek baru dengan nilai yang diperbarui (immutable pattern)
      final aktivitasBaru = widget.aktivitasYangDiEdit!.copyWith(
        jarakKm: jarak,
        waktuMenit: totalMenit,
        tanggal: _tanggalDipilih,
        catatan: _catatanController.text.trim(),
      );
      provider.perbarui(aktivitasBaru);
    } else {
      // CREATE — buat objek baru dengan ID unik dari timestamp
      // userId diambil dari AuthProvider agar aktivitas terikat ke akun yang sedang login
      final userId = context.read<AuthProvider>().currentUser!.id;
      final aktivitasBaru = AktivitasLari(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        jarakKm: jarak,
        waktuMenit: totalMenit,
        tanggal: _tanggalDipilih,
        catatan: _catatanController.text.trim(),
      );
      provider.tambah(aktivitasBaru);
    }

    // Tampilkan notifikasi bahwa telah sukses sebelum menutup form
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

    // Tutup bottom sheet setelah menyimpan
    Navigator.of(context).pop();
  }

  /// Memformat DateTime menjadi string yang mudah dibaca.
  /// Contoh: "Selasa, 6 Mei 2026"
  String _formatTanggal(DateTime tanggal) {
    const namaHari = [
      'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
    ];
    const namaBulan = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    // weekday: 1=Senin, 7=Minggu; index list mulai 0 jadi -1
    final hari = namaHari[tanggal.weekday - 1];
    final bulan = namaBulan[tanggal.month - 1];
    return '$hari, ${tanggal.day} $bulan ${tanggal.year}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      // Padding bawah mengikuti tinggi keyboard agar form tidak tertutup
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
                        borderRadius: BorderRadius.circular(AppSizes.radiusKecil + 2),
                      ),
                      child: Icon(
                        Icons.directions_run_rounded,
                        color: colorScheme.onPrimaryContainer,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: AppSizes.paddingKecil),
                    Text(
                      // Judul berubah tergantung mode (tambah atau edit)
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
                // Tombol yang menampilkan tanggal terpilih dan membuka date picker
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
                  // Keyboard angka dengan desimal
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  // Hanya izinkan angka dan titik/koma desimal
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                  ],
                  decoration: const InputDecoration(
                    hintText: 'Contoh: 5.2',
                    prefixIcon: Icon(Icons.route_rounded),
                    suffixText: 'km',
                  ),
                  // Validasi: jarak tidak boleh kosong dan harus > 0
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

                // ===== INPUT DURASI (JAM + MENIT) =====
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
                    // Field jam — opsional (boleh kosong/0 untuk lari < 1 jam)
                    Expanded(
                      child: TextFormField(
                        controller: _jamController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: const InputDecoration(
                          hintText: '0',
                          prefixIcon: Icon(Icons.timer_outlined),
                          suffixText: 'jam',
                        ),
                        // Jam boleh kosong, tapi jika diisi harus angka valid
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

                    // Field menit — wajib diisi setidaknya salah satu (jam atau menit)
                    Expanded(
                      child: TextFormField(
                        controller: _menitController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          hintText: '30',
                          prefixIcon: Icon(Icons.schedule_rounded),
                          suffixText: 'menit',
                        ),
                        // Validasi: menit harus 0-59
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
                  // Izinkan banyak baris untuk catatan panjang
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
                    // Tombol Batal — menutup form tanpa menyimpan
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusButton),
                          ),
                        ),
                        child: const Text(AppStrings.tombolBatal),
                      ),
                    ),

                    const SizedBox(width: AppSizes.paddingKecil),

                    // Tombol Simpan — menjalankan _simpan()
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _simpan,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusButton),
                          ),
                        ),
                        // Tampilkan spinner saat loading, ikon saat normal
                        icon: _isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
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

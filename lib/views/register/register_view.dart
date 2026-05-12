// File: register_view.dart
// View untuk halaman Register — hanya bertanggung jawab menampilkan UI
// State loading diambil dari RegisterViewModel; logika registrasi dari AuthViewModel

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/register_viewmodel.dart';
import '../../utils/app_constants.dart';
import '../../utils/app_routes.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

/// RegisterView adalah halaman pendaftaran akun baru.
///
/// Dalam pola MVVM:
/// - View (ini): rendering UI + meneruskan aksi pengguna ke ViewModel
/// - ViewModel : [RegisterViewModel] (state loading), [AuthViewModel] (logika register)
class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _konfirmasiPasswordController = TextEditingController();

  // State UI murni — toggle tampilan password
  bool _passwordTerlihat = false;
  bool _konfirmasiTerlihat = false;

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _konfirmasiPasswordController.dispose();
    super.dispose();
  }

  /// Meneruskan aksi register ke ViewModel, lalu menangani respons di View.
  Future<void> _handleDaftar() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    // RegisterViewModel mengelola state loading + delay jaringan
    final registerVM = context.read<RegisterViewModel>();
    final authVM = context.read<AuthViewModel>();

    final error = await registerVM.register(
      authVM,
      _namaController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    final colorScheme = Theme.of(context).colorScheme;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusSnackbar),
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(AppStrings.registerBerhasil),
        backgroundColor: colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSnackbar),
        ),
      ),
    );

    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final colorScheme = Theme.of(context).colorScheme;

    // View mengamati RegisterViewModel untuk state loading tombol
    final isLoading = context.watch<RegisterViewModel>().isLoading;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go(AppRoutes.login),
        ),
        title: const Text(AppStrings.judulDaftar),
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingHalamanH,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: size.height * 0.02),
                _buildHeader(colorScheme),
                SizedBox(height: size.height * 0.04),
                _buildForm(),
                const SizedBox(height: 28),
                CustomButton(
                  teks: AppStrings.tombolDaftar,
                  onPressed: _handleDaftar,
                  isLoading: isLoading,
                  icon: Icons.person_add_rounded,
                ),
                const SizedBox(height: AppSizes.paddingKartu),
                _buildTautanLogin(colorScheme),
                const SizedBox(height: AppSizes.paddingKartu),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(AppSizes.radiusButton),
          ),
          child: Icon(
            Icons.directions_run_rounded,
            color: colorScheme.onPrimaryContainer,
            size: 28,
          ),
        ),
        const SizedBox(height: AppSizes.paddingKartu),
        Text(
          AppStrings.judulBesarDaftar,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
            height: 1.2,
          ),
        ),
        const SizedBox(height: AppSizes.paddingTerkecil),
        Text(
          AppStrings.subJudulDaftar,
          style: TextStyle(
            fontSize: AppSizes.teksSedang,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        CustomTextField(
          controller: _namaController,
          label: AppStrings.fieldNamaLengkap,
          prefixIcon: Icons.person_outline_rounded,
          keyboardType: TextInputType.name,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppStrings.validasiNamaKosong;
            }
            if (value.trim().length < 3) return AppStrings.validasiNamaMin;
            return null;
          },
        ),
        const SizedBox(height: AppSizes.paddingKartu),
        CustomTextField(
          controller: _emailController,
          label: AppStrings.fieldAlamatEmail,
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppStrings.validasiEmailKosong;
            }
            final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
            if (!emailRegex.hasMatch(value)) {
              return AppStrings.validasiEmailInvalid;
            }
            return null;
          },
        ),
        const SizedBox(height: AppSizes.paddingKartu),
        CustomTextField(
          controller: _passwordController,
          label: AppStrings.fieldPassword,
          prefixIcon: Icons.lock_outline_rounded,
          obscureText: !_passwordTerlihat,
          suffixIcon: IconButton(
            icon: Icon(
              _passwordTerlihat
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
            ),
            onPressed: () =>
                setState(() => _passwordTerlihat = !_passwordTerlihat),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppStrings.validasiPasswordKosong;
            }
            if (value.length < 8) return AppStrings.validasiPasswordMinDaftar;
            return null;
          },
        ),
        const SizedBox(height: AppSizes.paddingKartu),
        CustomTextField(
          controller: _konfirmasiPasswordController,
          label: AppStrings.fieldKonfirmasiPassword,
          prefixIcon: Icons.lock_person_outlined,
          obscureText: !_konfirmasiTerlihat,
          textInputAction: TextInputAction.done,
          suffixIcon: IconButton(
            icon: Icon(
              _konfirmasiTerlihat
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
            ),
            onPressed: () =>
                setState(() => _konfirmasiTerlihat = !_konfirmasiTerlihat),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppStrings.validasiKonfirmasiKosong;
            }
            if (value != _passwordController.text) {
              return AppStrings.validasiPasswordTidakCocok;
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTautanLogin(ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppStrings.sudahPunyaAkun,
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
        GestureDetector(
          onTap: () => context.go(AppRoutes.login),
          child: Text(
            AppStrings.tombolMasuk,
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

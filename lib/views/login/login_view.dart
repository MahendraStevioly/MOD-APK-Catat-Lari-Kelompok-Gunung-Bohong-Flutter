// File: login_view.dart
// View untuk halaman Login — hanya bertanggung jawab menampilkan UI
// State loading diambil dari LoginViewModel; logika autentikasi dari AuthViewModel

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/login_viewmodel.dart';
import '../../utils/app_constants.dart';
import '../../utils/app_routes.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

/// LoginView menampilkan form email dan password untuk autentikasi pengguna.
///
/// Dalam pola MVVM:
/// - View (ini): rendering UI + meneruskan aksi pengguna ke ViewModel
/// - ViewModel : [LoginViewModel] (state loading), [AuthViewModel] (logika login)
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // State UI murni — toggle tampilan password, tidak perlu di ViewModel
  bool _passwordTerlihat = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Meneruskan aksi login ke ViewModel, lalu menangani respons di View.
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    // LoginViewModel mengelola state loading + delay jaringan
    final loginVM = context.read<LoginViewModel>();
    final authVM = context.read<AuthViewModel>();

    final error = await loginVM.login(
      authVM,
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (error != null) {
      final colorScheme = Theme.of(context).colorScheme;
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

    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final colorScheme = Theme.of(context).colorScheme;

    // View mengamati LoginViewModel untuk state loading tombol
    final isLoading = context.watch<LoginViewModel>().isLoading;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingHalamanH,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: size.height * 0.08),
                _buildHeader(colorScheme),
                SizedBox(height: size.height * 0.06),
                _buildForm(),
                const SizedBox(height: AppSizes.paddingTerkecil),
                _buildLupaPassword(colorScheme),
                const SizedBox(height: AppSizes.paddingKecil * 2),
                CustomButton(
                  teks: AppStrings.tombolMasuk,
                  onPressed: _handleLogin,
                  isLoading: isLoading,
                  icon: Icons.login_rounded,
                ),
                const SizedBox(height: 32),
                _buildTautanDaftar(colorScheme),
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
      children: [
        Container(
          width: AppSizes.ukuranLogoLogin,
          height: AppSizes.ukuranLogoLogin,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withAlpha(AppColors.alphaTeksSekunder),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            Icons.directions_run_rounded,
            size: AppSizes.ikonBesar,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          AppStrings.namaApp,
          style: TextStyle(
            fontSize: AppSizes.teksJudulBesar,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          AppStrings.subJudulLogin,
          style: TextStyle(
            fontSize: AppSizes.teksSedang,
            color: colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        CustomTextField(
          controller: _emailController,
          label: AppStrings.fieldEmail,
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppStrings.validasiEmailKosong;
            }
            if (!value.contains('@')) return AppStrings.validasiEmailInvalid;
            return null;
          },
        ),
        const SizedBox(height: AppSizes.paddingKartu),
        CustomTextField(
          controller: _passwordController,
          label: AppStrings.fieldPassword,
          prefixIcon: Icons.lock_outline_rounded,
          obscureText: !_passwordTerlihat,
          textInputAction: TextInputAction.done,
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
            if (value.length < 6) return AppStrings.validasiPasswordMinLogin;
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildLupaPassword(ColorScheme colorScheme) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {},
        child: Text(
          AppStrings.lupaPassword,
          style: TextStyle(
            color: colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildTautanDaftar(ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppStrings.belumPunyaAkun,
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
        GestureDetector(
          onTap: () => context.go(AppRoutes.register),
          child: Text(
            AppStrings.daftarSekarang,
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

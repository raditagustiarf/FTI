import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/theme.dart';
import 'main_navigation.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // 1. Controller untuk menangkap semua ketikan
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repeatPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureRepeatPassword = true;
  bool _isLoading = false;

  // FUNGSI UTAMA: Mendaftar ke Supabase
  Future<void> _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final repeatPassword = _repeatPasswordController.text;

    // VALIDASI 1: Cek apakah ada kolom yang kosong
    if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty || repeatPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua kolom wajib diisi!'), backgroundColor: Colors.orangeAccent),
      );
      return;
    }

    // VALIDASI 2: Cek apakah password cocok
    if (password != repeatPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kata sandi tidak cocok!'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    // VALIDASI 3: Minimal 6 karakter
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kata sandi minimal 6 karakter!'), backgroundColor: Colors.orangeAccent),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Mendaftarkan Akun ke Supabase Auth
      final AuthResponse res = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      final user = res.user;
      if (user != null) {
        // 2. Menyimpan Nama dan Nomor HP ke Tabel Profiles
        await Supabase.instance.client.from('profiles').upsert({
          'id': user.id,
          'full_name': name,
          'phone': phone,
          // Set nilai default agar aman
          'rating': 0.0,
          'review_count': 0,
          'is_store_visible': true,
        });

        // 3. Arahkan masuk ke dalam aplikasi
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pendaftaran berhasil! Selamat datang! 🎉'), backgroundColor: AppTheme.neonGreen),
          );
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MainNavigation()),
            (route) => false,
          );
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal mendaftar: ${e.message}'), backgroundColor: Colors.red));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _repeatPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. JUDUL
              const Text(
                'Buat Akun Baru',
                style: TextStyle(
                  color: AppTheme.textWhite,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                  letterSpacing: -1.0,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Mulai jelajahi dan jual produk di sekitar lingkunganmu.',
                style: TextStyle(color: AppTheme.textGray, fontSize: 13),
              ),
              const SizedBox(height: 32),

              // 2. FORM INPUT
              _buildInputField(
                label: 'Nama Pengguna',
                hint: 'Contoh: Asep Knalpot',
                icon: Icons.person_outline,
                controller: _nameController,
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 16),
              
              _buildInputField(
                label: 'Email',
                hint: 'Contoh: asep@gmail.com',
                icon: Icons.email_outlined,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              _buildInputField(
                label: 'Nomor HP',
                hint: 'Contoh: 08123456789',
                icon: Icons.phone_android_outlined,
                controller: _phoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              // Kata Sandi
              _buildPasswordField(
                label: 'Kata Sandi',
                hint: 'Minimal 6 karakter',
                controller: _passwordController,
                isObscure: _obscurePassword,
                onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              const SizedBox(height: 16),

              // Ulangi Kata Sandi
              _buildPasswordField(
                label: 'Ulangi Kata Sandi',
                hint: 'Ketik ulang kata sandi',
                controller: _repeatPasswordController,
                isObscure: _obscureRepeatPassword,
                onToggleVisibility: () => setState(() => _obscureRepeatPassword = !_obscureRepeatPassword),
              ),
              
              const SizedBox(height: 40),

              // 3. TOMBOL DAFTAR
              ElevatedButton(
                onPressed: _isLoading ? null : _register,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  backgroundColor: AppTheme.neonGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                    : const Text('Daftar Sekarang', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15)),
              ),
              const SizedBox(height: 24),

              // 4. LINK KE LOGIN
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Sudah punya akun? ', style: TextStyle(color: AppTheme.textGray, fontSize: 12)),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context); // Kembali ke halaman login
                    },
                    child: const Text('Masuk di sini', style: TextStyle(color: AppTheme.neonGreen, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // REUSABLE WIDGET: Text Input Standard
  Widget _buildInputField({
    required String label, 
    required String hint, 
    required IconData icon, 
    required TextEditingController controller,
    required TextInputType keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.045),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.14)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(color: AppTheme.textWhite, fontSize: 13),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              prefixIcon: Icon(icon, color: Colors.white38, size: 18),
            ),
          ),
        ),
      ],
    );
  }

  // REUSABLE WIDGET: Text Input Khusus Password
  Widget _buildPasswordField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool isObscure,
    required VoidCallback onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.045),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.14)),
          ),
          child: TextField(
            controller: controller,
            obscureText: isObscure,
            style: const TextStyle(color: AppTheme.textWhite, fontSize: 13),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              prefixIcon: const Icon(Icons.lock_outline, color: Colors.white38, size: 18),
              suffixIcon: GestureDetector(
                onTap: onToggleVisibility,
                child: Icon(
                  isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: Colors.white38,
                  size: 18,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
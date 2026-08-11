import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/theme.dart';
import 'edit_profile_screen.dart';
import 'reviews_screen.dart';
// import 'login_screen.dart'; // Aktifkan ini jika ingin fungsi logoutnya jalan

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  final _supabase = Supabase.instance.client;
  String _userName = 'Memuat...';
  String _userInitials = '..';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Mengambil data pengguna dari Supabase
  Future<void> _fetchUserData() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      final response = await _supabase
          .from('profiles')
          .select('full_name')
          .eq('id', user.id)
          .maybeSingle();

      if (mounted) {
        setState(() {
          _userName = response?['full_name'] ?? 'Penjual';
          _userInitials = _userName.isNotEmpty
              ? _userName.substring(0, _userName.length >= 2 ? 2 : 1).toUpperCase()
              : '?';
        });
      }
    }
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
        title: const Text(
          'Pengaturan Akun',
          style: TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.bold, fontSize: 17),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. INFO PROFIL (Tengah - Sekarang Dinamis!)
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFFF1B18F), Color(0xFF945B44)],
                ),
              ),
              child: Center(
                child: Text(_userInitials, style: const TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_userName, style: const TextStyle(color: AppTheme.textWhite, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                const SizedBox(width: 6),
                const Icon(Icons.verified, color: Color(0xFFFFD700), size: 16),
              ],
            ),
            const SizedBox(height: 4),
            const Text('Penjual lokal · Pangkalpinang', style: TextStyle(color: AppTheme.textGray, fontSize: 12)),
            const SizedBox(height: 32),

            // 2. KARTU AKUN TERVERIFIKASI
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [Color(0xFF292516), Color(0xFF171717)],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0x3FFFD600)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD600).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(child: Text('✓', style: TextStyle(color: AppTheme.textWhite, fontSize: 18))),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Akun Terverifikasi', style: TextStyle(color: Color(0xFFFFD700), fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text(
                          'Bubble lokasi Anda di peta sekarang berwarna spesial.',
                          style: TextStyle(color: Color(0xFFB9B3A1), fontSize: 11, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 3. MENU PENGATURAN PROFIL
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('PENGATURAN PROFIL', style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            ),
            const SizedBox(height: 12),
            _buildSettingsMenu(
              context: context,
              emoji: '✏️', title: 'Edit Profil', subtitle: 'Ubah nama, foto, dan bio',
              onTap: () async {
                // Menunggu halaman edit profil ditutup
                final didUpdate = await Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => const EditProfileScreen())
                );
                // Jika menyimpan (mengirim nilai true), panggil ulang data Supabase
                if (didUpdate == true) {
                  _fetchUserData();
                }
              },
            ),
            const SizedBox(height: 12),
            _buildSettingsMenu(
              context: context,
              emoji: '⭐', title: 'Ulasan & Rating Penjual', subtitle: 'Lihat penilaian dari pembeli',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ReviewsScreen())),
            ),
            const SizedBox(height: 32),

            // 4. TOMBOL LOGOUT (Tersedia jika butuh)
            GestureDetector(
              onTap: () async {
                // await _supabase.auth.signOut();
                // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFA1A2).withOpacity(0.06), 
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFF6366).withOpacity(0.35)),
                ),
                child: const Center(
                  child: Text('Logout', style: TextStyle(color: Color(0xFFFFA1A2), fontSize: 14, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // REUSABLE WIDGET: Menu Pengaturan
  Widget _buildSettingsMenu({required BuildContext context, required String emoji, required String title, required String subtitle, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.12))),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
              child: Center(child: Text(emoji, style: const TextStyle(fontSize: 14))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: AppTheme.textWhite, fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: AppTheme.textGray, fontSize: 10)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.textGray, size: 18),
          ],
        ),
      ),
    );
  }
}
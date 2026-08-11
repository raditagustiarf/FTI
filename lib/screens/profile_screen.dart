import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 
import '../core/theme.dart';
import 'manage_catalog_screen.dart';
import 'location_settings_screen.dart';
import 'account_settings_screen.dart';
import 'notifications_screen.dart';
import 'login_screen.dart'; 

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _supabase = Supabase.instance.client;
  
  String _userName = 'Memuat...';
  String _userInitials = '...';
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  // MENGAMBIL DATA DARI SUPABASE
  Future<void> _fetchProfileData() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        if (mounted) {
          setState(() => _userEmail = user.email ?? '');
        }

        // Ambil nama dari tabel 'profiles'
        final response = await _supabase
            .from('profiles')
            .select('full_name')
            .eq('id', user.id)
            .maybeSingle(); 

        if (mounted) {
          setState(() {
            // PERBAIKAN DI SINI: Menggunakan response?['full_name']
            _userName = response?['full_name'] ?? 'Pengguna';
            
            // Membuat inisial nama
            _userInitials = _userName.isNotEmpty
                ? _userName.substring(0, _userName.length >= 2 ? 2 : 1).toUpperCase()
                : '?';
          });
        }
      }
    } catch (e) {
      debugPrint('Error ambil profil: $e');
      if (mounted) {
        setState(() {
          _userName = 'Pengguna';
          _userInitials = 'P';
        });
      }
    }
  }

  // FUNGSI LOGOUT
  Future<void> _logout() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppTheme.neonGreen),
      ),
    );

    try {
      await _supabase.auth.signOut();
      
      if (mounted) {
        Navigator.pop(context); 
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal logout: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. HEADER PROFIL
                    Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFFF1B18F), Color(0xFF945B44)],
                            ),
                          ),
                          child: Center(
                            child: Text(
                              _userInitials, 
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _userName, 
                                style: const TextStyle(
                                  color: AppTheme.textWhite,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _userEmail.isNotEmpty ? _userEmail : 'Penjual lokal', 
                                style: const TextStyle(
                                  color: AppTheme.textGray,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                            );
                          },
                          child: Stack(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.12),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.notifications_outlined, 
                                  color: AppTheme.textWhite,
                                  size: 18,
                                ),
                              ),
                              Positioned(
                                right: 6,
                                top: 6,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppTheme.darkBackground, width: 1.5),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // 2. JUDUL DASHBOARD
                    const Text(
                      'DASHBOARD PENJUAL',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Kelola tokomu\ndengan mudah.',
                      style: TextStyle(
                        color: AppTheme.textWhite,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                        letterSpacing: -1.0,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 3. DAFTAR MENU
                    _buildMenuCard(
                      emoji: '🛍️',
                      title: 'Kelola Katalog',
                      subtitle: 'Produk dan stok jualan',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ManageCatalogScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildMenuCard(
                      emoji: '📍',
                      title: 'Pengaturan Lokasi Jualan',
                      subtitle: 'Lokasi live & patokan alamat',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LocationSettingsScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildMenuCard(
                      emoji: '⚙️',
                      title: 'Pengaturan Akun',
                      subtitle: 'Profil dan preferensi',
                      // PERUBAHAN DI SINI:
                      onTap: () async {
                        // Tunggu sampai user selesai buka pengaturan akun
                        await Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (context) => const AccountSettingsScreen())
                        );
                        // JIKA SUDAH KEMBALI, REFRESH PROFIL!
                        _fetchProfileData();
                      },
                    ),
                    
                    const SizedBox(height: 24),

                    // 4. TOMBOL LOGOUT BARU
                    ElevatedButton(
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent.withOpacity(0.1),
                        foregroundColor: Colors.redAccent,
                        elevation: 0,
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: Colors.redAccent, width: 1),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout, size: 20),
                          SizedBox(width: 8),
                          Text('Keluar Akun', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // REUSABLE WIDGET: Kartu Menu
  Widget _buildMenuCard({
    required String emoji, 
    required String title, 
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A), 
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppTheme.textWhite,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppTheme.textGray,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppTheme.textGray,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
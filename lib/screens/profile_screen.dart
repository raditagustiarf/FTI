import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/theme.dart';
import '../providers/notification_provider.dart';
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
  String? _avatarUrl; 

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        if (mounted) {
          setState(() => _userEmail = user.email ?? '');
        }
        final response = await _supabase
            .from('profiles')
            .select('full_name, avatar_url') 
            .eq('id', user.id)
            .maybeSingle();

        if (mounted) {
          setState(() {
            _userName = response?['full_name'] ?? 'Pengguna';
            _avatarUrl = response?['avatar_url']; 
            
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
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white12,
                            image: _avatarUrl != null 
                                ? DecorationImage(image: NetworkImage(_avatarUrl!), fit: BoxFit.cover)
                                : null,
                            gradient: _avatarUrl == null 
                                ? const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [Color(0xFFF1B18F), Color(0xFF945B44)],
                                  )
                                : null,
                          ),
                          child: _avatarUrl == null
                            ? Center(
                                child: Text(
                                  _userInitials,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : null, 
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
                          child: Consumer<NotificationProvider>(
                            builder: (context, notifProvider, child) {
                              return Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white.withOpacity(0.12)),
                                    ),
                                    child: const Icon(Icons.notifications_outlined, color: AppTheme.textWhite, size: 18),
                                  ),
                                  if (notifProvider.unreadCount > 0)
                                    Positioned(
                                      right: -4,
                                      top: -4,
                                      child: Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          color: Colors.redAccent,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: AppTheme.darkBackground, width: 2),
                                        ),
                                        child: Text(
                                          notifProvider.unreadCount.toString(),
                                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            }
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    
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
                    
                  
                    _buildMenuCard(
                      icon: Icons.inventory_2_outlined,
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
                      icon: Icons.pin_drop_outlined,
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
                      icon: Icons.settings_outlined,
                      title: 'Pengaturan Akun',
                      subtitle: 'Profil dan preferensi',
                      onTap: () async {
                        await Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (context) => const AccountSettingsScreen())
                        );
                        _fetchProfileData();
                      },
                    ),
                    
                    const SizedBox(height: 24),
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

  Widget _buildMenuCard({
    required IconData icon, 
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
                color: AppTheme.neonGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(icon, color: AppTheme.neonGreen, size: 20),
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
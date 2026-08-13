import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/theme.dart';
import 'edit_profile_screen.dart';
import 'reviews_screen.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  final _supabase = Supabase.instance.client;
  String _userName = 'Memuat...';
  String _userInitials = '..';
  String? _avatarUrl; 
  
  String _userId = '';
  double _currentRating = 0.0;
  int _reviewCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      _userId = user.id;

      final response = await _supabase
          .from('profiles')
          .select('full_name, avatar_url, rating, review_count')
          .eq('id', user.id)
          .maybeSingle();

      if (mounted) {
        setState(() {
          _userName = response?['full_name'] ?? 'Penjual';
          _avatarUrl = response?['avatar_url']; 
          
          _currentRating = (response?['rating'] ?? 0.0).toDouble();
          _reviewCount = (response?['review_count'] ?? 0).toInt();
          
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
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white12,
                image: _avatarUrl != null 
                    ? DecorationImage(image: NetworkImage(_avatarUrl!), fit: BoxFit.cover)
                    : null,
                gradient: _avatarUrl == null 
                    ? const LinearGradient(
                        colors: [Color(0xFFF1B18F), Color(0xFF945B44)],
                      )
                    : null,
              ),
              child: _avatarUrl == null
                ? Center(
                    child: Text(_userInitials, style: const TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
                  )
                : null,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_userName, style: const TextStyle(color: AppTheme.textWhite, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                // Centang emas sementara disembunyikan sampai fitur verifikasi siap
              ],
            ),
            const SizedBox(height: 4),
            const Text('Penjual lokal • Pangkalpinang', style: TextStyle(color: AppTheme.textGray, fontSize: 12)),
            
            const SizedBox(height: 32),
            
            // ==========================================
            // KOTAK COMING SOON - Verifikasi Akun
            // ==========================================
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(child: Text('⏳', style: TextStyle(color: AppTheme.textWhite, fontSize: 18))),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Verifikasi Akun', style: TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text(
                          'Fitur centang toko dan warna bubble lokasi spesial akan segera hadir. Nantikan update selanjutnya!',
                          style: TextStyle(color: Colors.white38, fontSize: 11, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('PENGATURAN PROFIL', style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            ),
            const SizedBox(height: 12),
            
            _buildSettingsMenu(
              context: context,
              emoji: '✏️', title: 'Edit Profil', subtitle: 'Ubah nama, foto, dan bio',
              onTap: () async {
                final didUpdate = await Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => const EditProfileScreen())
                );
                if (didUpdate == true) {
                  _fetchUserData();
                }
              },
            ),
            const SizedBox(height: 12),
            _buildSettingsMenu(
              context: context,
              emoji: '⭐', title: 'Ulasan & Rating Penjual', subtitle: 'Lihat penilaian dari pembeli',
              onTap: () {
                if (_userId.isNotEmpty) {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ReviewsScreen(
                    sellerId: _userId,
                    sellerName: _userName,
                    currentRating: _currentRating,
                    reviewCount: _reviewCount,
                  )));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

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
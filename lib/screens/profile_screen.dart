import 'package:flutter/material.dart';
import '../core/theme.dart';
import 'manage_catalog_screen.dart';
import 'location_settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Konten Profil yang bisa di-scroll
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
                          child: const Center(
                            child: Text(
                              'RA', 
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Radit Agustiar', 
                                style: TextStyle(
                                  color: AppTheme.textWhite,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Penjual lokal · Pangkalpinang',
                                style: TextStyle(
                                  color: AppTheme.textGray,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.12),
                            ),
                          ),
                          child: const Icon(
                            Icons.edit_outlined,
                            color: AppTheme.textWhite,
                            size: 18,
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

                    // 3. DAFTAR MENU (Sudah ditambahkan navigasi onTap)
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
                      onTap: () {
                        // Nanti ditambahkan navigasi untuk pengaturan akun jika ada
                      },
                    ),
                    
                    // Jarak aman agar konten bawah tidak tertutup Bottom Nav
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

  // REUSABLE WIDGET: Kartu Menu (Sudah dibungkus GestureDetector)
  Widget _buildMenuCard({
    required String emoji, 
    required String title, 
    required String subtitle,
    required VoidCallback onTap, // Parameter baru untuk aksi klik
  }) {
    return GestureDetector(
      onTap: onTap, // Menjalankan navigasi saat diklik
      behavior: HitTestBehavior.opaque, // Memastikan seluruh area kartu bisa diklik
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
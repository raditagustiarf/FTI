import 'package:flutter/material.dart';
import '../core/theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

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
          'Notifikasi',
          style: TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.bold, fontSize: 17),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildNotificationItem(
            icon: Icons.star,
            iconColor: const Color(0xFFFFD700), // Warna Emas
            title: 'Ulasan Baru!',
            message: 'Rina Putri memberikan 5 bintang dan ulasan positif untuk produk Nasi Liwet Spesial Anda.',
            time: '2 jam yang lalu',
            isUnread: true,
          ),
          const SizedBox(height: 12),
          _buildNotificationItem(
            icon: Icons.chat_bubble,
            iconColor: AppTheme.neonGreen,
            title: 'Pesan Baru',
            message: 'Fahmi Arif mengirim pesan: "Permisi bu, apakah ayam gorengnya masih ada?"',
            time: '5 jam yang lalu',
            isUnread: true,
          ),
          const SizedBox(height: 12),
          _buildNotificationItem(
            icon: Icons.check_circle,
            iconColor: Colors.blueAccent,
            title: 'Akun Terverifikasi',
            message: 'Selamat! Akun Anda telah terverifikasi. Bubble lokasi Anda di peta sekarang berwarna spesial.',
            time: '1 hari yang lalu',
            isUnread: false,
          ),
          const SizedBox(height: 12),
          _buildNotificationItem(
            icon: Icons.storefront,
            iconColor: Colors.orangeAccent,
            title: 'Tips Penjualan',
            message: 'Tambahkan deskripsi yang menarik dan foto yang terang agar tetangga makin suka dengan produkmu.',
            time: '3 hari yang lalu',
            isUnread: false,
          ),
        ],
      ),
    );
  }

  // REUSABLE WIDGET: Kartu Notifikasi
  Widget _buildNotificationItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
    required String time,
    required bool isUnread,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // Jika belum dibaca, background sedikit lebih terang
        color: isUnread ? Colors.white.withOpacity(0.08) : const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          // Jika belum dibaca, beri border hijau neon tipis
          color: isUnread ? AppTheme.neonGreen.withOpacity(0.3) : Colors.white.withOpacity(0.05),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: AppTheme.textWhite,
                        fontSize: 14,
                        fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                      ),
                    ),
                    // Indikator titik hijau untuk notifikasi belum dibaca
                    if (isUnread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppTheme.neonGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: TextStyle(
                    color: isUnread ? Colors.white70 : AppTheme.textGray,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  time,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
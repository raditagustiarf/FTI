import 'package:flutter/material.dart';
import '../core/theme.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: SafeArea(
        child: Column(
          children: [
            // 1. HEADER LOGO
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 24, right: 24),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppTheme.neonGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.chat_bubble, 
                      color: Colors.black,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'tetangga.',
                    style: TextStyle(
                      color: AppTheme.textWhite,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1.0,
                    ),
                  ),
                ],
              ),
            ),

            // 2. KONTEN TENGAH (Empty State)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Ikon Chat Besar
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.neonGreen.withOpacity(0.05), 
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppTheme.neonGreen.withOpacity(0.2), 
                      ),
                    ),
                    child: const Icon(
                      Icons.chat_bubble_outline,
                      color: AppTheme.neonGreen,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Teks Judul
                  const Text(
                    'Belum ada pesan.',
                    style: TextStyle(
                      color: AppTheme.textWhite,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1.0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Teks Deskripsi
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'Mulai ngobrol dengan penjual untuk\nbertanya tentang produk sekitar kamu.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.textGray,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Tombol "Jelajahi peta"
                  OutlinedButton(
                    onPressed: () {
                      // Nanti kita tambahkan logika untuk pindah ke Tab Peta
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.white.withOpacity(0.15)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    ),
                    child: const Text(
                      'Jelajahi peta',
                      style: TextStyle(
                        color: AppTheme.textWhite,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
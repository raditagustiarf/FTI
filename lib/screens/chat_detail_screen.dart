import 'package:flutter/material.dart';
import '../core/theme.dart';

class ChatDetailScreen extends StatelessWidget {
  const ChatDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: SafeArea(
        child: Column(
          children: [
            // 1. HEADER (Profil Penjual)
            _buildHeader(context),

            // 2. AREA OBROLAN (Bisa di-scroll)
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Pesan dari Pembeli (Kamu)
                  const _ChatBubble(
                    message: 'Halo Bu Retno, saya sudah sampai di\nlokasi.',
                    isMe: true,
                  ),
                  const SizedBox(height: 16),
                  
                  // Pesan dari Penjual
                  const _ChatBubble(
                    message: 'Baik, terima kasih ya. Semoga produknya\ncocok!',
                    isMe: false,
                  ),
                  const SizedBox(height: 24),
                  
                  // Kotak Permintaan Ulasan (Warna Kuning/Emas)
                  _buildReviewCard(),
                ],
              ),
            ),

            // 3. AREA INPUT PESAN (Tulis pesan & Tombol Kirim)
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // KOMPONEN UI
  // ==========================================

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xBF151414), // Sedikit transparan
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: Row(
        children: [
          // Tombol Kembali
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.arrow_back, color: Colors.white60, size: 22),
            ),
          ),
          
          // Avatar Penjual
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFFE7B48E), Color(0xFF925B44)],
              ),
            ),
            child: const Center(
              child: Text(
                'BR',
                style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Nama & Status
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bu Retno',
                  style: TextStyle(color: AppTheme.textWhite, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 2),
                Text(
                  '● Online sekarang',
                  style: TextStyle(color: AppTheme.neonGreen, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xBF242015), // Warna dasar kekuningan gelap
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x72FFD700)), // Garis tepi emas
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Apakah transaksi Anda selesai? Bantu Bu Retno\ndengan ulasan!',
            style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.5),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Aksi beri ulasan nantinya
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.neonGreen,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Beri Ulasan',
                style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkBackground,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: Row(
        children: [
          // Kolom Input Teks
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.14)),
              ),
              child: const TextField(
                style: TextStyle(color: AppTheme.textWhite, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Tulis pesan...',
                  hintStyle: TextStyle(color: Colors.white38, fontSize: 13),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          
          // Tombol Kirim (Send)
          GestureDetector(
            onTap: () {
              // Aksi kirim pesan nantinya
            },
            child: Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: AppTheme.neonGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.send, color: Colors.black, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

// =========================================================
// REUSABLE WIDGET: GELEMBUNG CHAT (CHAT BUBBLE)
// =========================================================
class _ChatBubble extends StatelessWidget {
  final String message;
  final bool isMe; // Menentukan posisi (Kanan/Kiri) dan Warna

  const _ChatBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      // Jika pesanku, posisikan di kanan. Jika pesan penjual, di kiri.
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          left: isMe ? 50 : 0, // Memberi jarak agar tidak menabrak tepi seberang
          right: isMe ? 0 : 50,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isMe ? Colors.white.withOpacity(0.06) : AppTheme.neonGreen.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isMe ? Colors.white.withOpacity(0.12) : AppTheme.neonGreen.withOpacity(0.75),
          ),
        ),
        child: Text(
          message,
          style: const TextStyle(
            color: Colors.white, // Teks selalu putih agar terbaca jelas di background gelap
            fontSize: 13,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}
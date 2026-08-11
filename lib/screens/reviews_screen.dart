import 'package:flutter/material.dart';
import '../core/theme.dart';

class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({super.key});

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
          'Ulasan Pembeli',
          style: TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.bold, fontSize: 17),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. HEADER RATING BESAR
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1)))),
              child: Column(
                children: [
                  const Text('4.9', style: TextStyle(color: Color(0xFFFFD700), fontSize: 48, fontWeight: FontWeight.bold, letterSpacing: -2)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) => const Icon(Icons.star, color: Color(0xFFFFD700), size: 20)),
                  ),
                  const SizedBox(height: 8),
                  const Text('Berdasarkan 128 ulasan', style: TextStyle(color: AppTheme.textGray, fontSize: 11)),
                ],
              ),
            ),

            // 2. DAFTAR ULASAN
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildReviewCard(
                    initials: 'RP', name: 'Rina Putri', time: '2 hari lalu',
                    review: 'Pelayanan mantap, lokasi akurat!',
                  ),
                  const SizedBox(height: 12),
                  _buildReviewCard(
                    initials: 'FA', name: 'Fahmi Arif', time: '1 minggu lalu',
                    review: 'Ayam gorengnya enak dan masih hangat.',
                  ),
                  const SizedBox(height: 12),
                  _buildReviewCard(
                    initials: 'NS', name: 'Nadia S.', time: '2 minggu lalu',
                    review: 'Penjual ramah, pasti pesan lagi.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard({required String initials, required String name, required String time, required String review}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.1))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar Pembeli
          Container(
            width: 36, height: 36,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [Color(0xFF5C6B64), Color(0xFF28332E)]), // Hijau abu-abu gelap
            ),
            child: Center(child: Text(initials, style: const TextStyle(color: AppTheme.textWhite, fontSize: 10, fontWeight: FontWeight.bold))),
          ),
          const SizedBox(width: 12),
          
          // Konten Ulasan
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: AppTheme.textWhite, fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(children: List.generate(5, (index) => const Icon(Icons.star, color: Color(0xFFFFD700), size: 12))),
                const SizedBox(height: 8),
                Text(review, style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.5)),
                const SizedBox(height: 8),
                Text(time, style: const TextStyle(color: AppTheme.textGray, fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../core/theme.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xEA0C0B0B),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. HEADER (Tombol Back & Judul)
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.14)),
                      ),
                      child: const Icon(Icons.arrow_back, color: AppTheme.textWhite, size: 20),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Cari Lokasi',
                    style: TextStyle(
                      color: AppTheme.textWhite,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 2. INPUT PENCARIAN (Pasangan Hero Animation)
              Hero(
                tag: 'search_bar_hero',
                child: Material(
                  type: MaterialType.transparency,
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xD8171616),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.neonGreen.withOpacity(0.75)),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.neonGreen.withOpacity(0.1),
                          blurRadius: 22,
                        ),
                      ],
                    ),
                    child: TextField(
                      autofocus: true, 
                      style: const TextStyle(color: AppTheme.textWhite),
                      decoration: InputDecoration(
                        hintText: 'Cari area atau jalan...',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                        prefixIcon: const Icon(Icons.search, color: AppTheme.textGray),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // 3. JUDUL RIWAYAT
              const Text(
                'RIWAYAT PENCARIAN',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),

              // 4. DAFTAR RIWAYAT
              _buildHistoryItem('Jl. Batu Akik, Antapani'),
              _buildHistoryItem('Dago Atas, Bandung'),
              _buildHistoryItem('Jl. Kenangan Indah Blok B2'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryItem(String location) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.035),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Row(
        children: [
          const Icon(Icons.history, color: AppTheme.textGray, size: 18),
          const SizedBox(width: 12),
          Text(
            location,
            style: TextStyle(
              color: Colors.white.withOpacity(0.82),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
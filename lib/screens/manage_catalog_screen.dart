import 'package:flutter/material.dart';
import '../core/theme.dart';
import 'add_product_screen.dart'; // Import layar Tambah Produk

class ManageCatalogScreen extends StatelessWidget {
  const ManageCatalogScreen({super.key});

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
          'Katalog Saya',
          style: TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.bold, fontSize: 17),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'PRODUK AKTIF',
                  style: TextStyle(
                    color: Colors.white38, // Sudah diperbaiki dari white40
                    fontSize: 10, 
                    fontWeight: FontWeight.bold, 
                    letterSpacing: 1.5
                  ),
                ),
                Text(
                  '4 item',
                  style: TextStyle(color: AppTheme.neonGreen, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Grid Produk
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(), // Agar scroll mengikuti SingleChildScrollView induk
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.8, // Menyesuaikan tinggi kotak produk
              children: [
                _buildCatalogItem('Ayam Goreng', 'Rp 25.000', const [Color(0xFFD59845), Color(0xFF4F2411)]),
                _buildCatalogItem('Nasi Liwet', 'Rp 15.000', const [Color(0xFFBF7928), Color(0xFF3F1D0F)]),
                _buildCatalogItem('Sayur Asem', 'Rp 12.000', const [Color(0xFF6D8D45), Color(0xFF20301D)]),
                _buildCatalogItem('Es Teh Manis', 'Rp 5.000', const [Color(0xFF89623D), Color(0xFF251912)]),
              ],
            ),
            const SizedBox(height: 16),
            
            // Tombol Tambah Produk Baru (Membutuhkan context untuk navigasi)
            _buildAddProductButton(context),
          ],
        ),
      ),
    );
  }

  // REUSABLE WIDGET: Kartu Produk di Katalog
  Widget _buildCatalogItem(String title, String price, List<Color> gradientColors) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF202020),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar / Gradient Cover
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                gradient: LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: gradientColors,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppTheme.textWhite, fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(price, style: const TextStyle(color: AppTheme.neonGreen, fontSize: 10, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                // Tombol Edit & Hapus
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white.withOpacity(0.13)),
                        ),
                        child: const Center(child: Text('✎ Edit', style: TextStyle(color: Colors.white70, fontSize: 10))),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white.withOpacity(0.13)),
                      ),
                      child: const Text('⌫', style: TextStyle(color: Colors.white60, fontSize: 10)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // REUSABLE WIDGET: Tombol Tambah Produk (Dengan Navigasi)
  Widget _buildAddProductButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigasi ke halaman AddProductScreen saat ditekan
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddProductScreen()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40),
        decoration: BoxDecoration(
          color: AppTheme.neonGreen.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.neonGreen.withOpacity(0.4)),
        ),
        child: const Column(
          children: [
            Text('+', style: TextStyle(color: AppTheme.neonGreen, fontSize: 32, fontWeight: FontWeight.w300)),
            SizedBox(height: 8),
            Text('Tambah Produk Baru', style: TextStyle(color: AppTheme.neonGreen, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../core/theme.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  // Variabel untuk menyimpan kategori yang dipilih
  String selectedCategory = 'Makanan'; 

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
          'Tambah Produk Baru',
          style: TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.bold, fontSize: 17),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. AREA UPLOAD FOTO
                  _buildSectionTitle('FOTO PRODUK'),
                  const SizedBox(height: 12),
                  Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppTheme.neonGreen.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      // Menggunakan border neon green yang tipis untuk memberi kesan area interaktif
                      border: Border.all(color: AppTheme.neonGreen.withOpacity(0.4)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.neonGreen.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add_a_photo_outlined, color: AppTheme.neonGreen, size: 28),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Upload Foto Produk',
                          style: TextStyle(color: AppTheme.neonGreen, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Format JPG/PNG, maks 5MB',
                          style: TextStyle(color: Colors.white38, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // 2. INPUT NAMA & HARGA
                  _buildSectionTitle('INFORMASI PRODUK'),
                  const SizedBox(height: 12),
                  _buildInputField(hint: 'Nama Produk, cth: Nasi Liwet Spesial'),
                  const SizedBox(height: 16),
                  _buildInputField(hint: 'Harga (Rp), cth: 15000', isNumber: true),
                  const SizedBox(height: 28),

                  // 3. PILIH KATEGORI (Chips interaktif)
                  _buildSectionTitle('KATEGORI'),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildCategoryChip('Makanan'),
                        _buildCategoryChip('Minuman'),
                        _buildCategoryChip('Jasa'),
                        _buildCategoryChip('Lainnya'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // 4. INPUT DESKRIPSI
                  _buildSectionTitle('DESKRIPSI PRODUK'),
                  const SizedBox(height: 12),
                  _buildInputField(
                    hint: 'Ceritakan detail produkmu agar tetangga tertarik...',
                    maxLines: 4,
                  ),
                ],
              ),
            ),
          ),
          
          // 5. TOMBOL SIMPAN (Sticky Bottom)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
            ),
            child: ElevatedButton(
              onPressed: () {
                // Nantinya logika simpan ke database diletakkan di sini
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: AppTheme.neonGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Simpan Produk', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // REUSABLE WIDGETS
  // ==========================================

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white38,
        fontSize: 10,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildInputField({required String hint, int maxLines = 1, bool isNumber = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.045),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.14)),
      ),
      child: TextField(
        maxLines: maxLines,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: AppTheme.textWhite, fontSize: 12),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label) {
    final isActive = selectedCategory == label; // Mengecek apakah kategori ini sedang dipilih
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = label; // Memperbarui UI saat diklik
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.neonGreen.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppTheme.neonGreen : Colors.white.withOpacity(0.14),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? AppTheme.neonGreen : Colors.white60,
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
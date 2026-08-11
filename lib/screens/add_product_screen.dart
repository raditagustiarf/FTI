import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // <-- BARU: Untuk format ketikan
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../providers/catalog_provider.dart';

// ==========================================
// MESIN AJAIB UNTUK FORMAT TITIK OTOMATIS
// ==========================================
class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;

    // Bersihkan karakter non-angka
    final numericString = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (numericString.isEmpty) return newValue;

    // Tambahkan titik setiap 3 angka
    String result = numericString;
    String formatted = '';
    int count = 0;
    for (int i = result.length - 1; i >= 0; i--) {
      if (count == 3) {
        formatted = '.$formatted';
        count = 0;
      }
      formatted = result[i] + formatted;
      count++;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class AddProductScreen extends StatefulWidget {
  final Product? product; 
  const AddProductScreen({super.key, this.product});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  String selectedCategory = 'Makanan'; 
  bool isEditMode = false;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      isEditMode = true;
      _nameController.text = widget.product!.title;
      
      // Ambil angka mentah, formatter akan bekerja saat user mengedit
      final cleanPrice = widget.product!.price.replaceAll(RegExp(r'[^0-9]'), '');
      _priceController.text = _formatInitialPrice(cleanPrice);
      
      if (['Makanan', 'Minuman', 'Jasa', 'Lainnya'].contains(widget.product!.category)) {
        selectedCategory = widget.product!.category;
      }
    }
  }

  // Helper untuk merapikan teks pertama kali masuk mode edit
  String _formatInitialPrice(String numberStr) {
    if (numberStr.isEmpty) return '';
    String formatted = '';
    int count = 0;
    for (int i = numberStr.length - 1; i >= 0; i--) {
      if (count == 3) {
        formatted = '.$formatted';
        count = 0;
      }
      formatted = numberStr[i] + formatted;
      count++;
    }
    return formatted;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBackground,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white70), onPressed: () => Navigator.pop(context)),
        title: Text(isEditMode ? 'Edit Produk' : 'Tambah Produk Baru', style: const TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.bold, fontSize: 17)),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('FOTO PRODUK'),
                  const SizedBox(height: 12),
                  Container(
                    height: 160, width: double.infinity,
                    decoration: BoxDecoration(color: AppTheme.neonGreen.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.neonGreen.withOpacity(0.4))),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppTheme.neonGreen.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.add_a_photo_outlined, color: AppTheme.neonGreen, size: 28)),
                        const SizedBox(height: 12),
                        const Text('Upload Foto Produk', style: TextStyle(color: AppTheme.neonGreen, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  _buildSectionTitle('INFORMASI PRODUK'),
                  const SizedBox(height: 12),
                  _buildInputField(controller: _nameController, hint: 'Nama Produk, cth: Nasi Liwet Spesial'),
                  const SizedBox(height: 16),
                  
                  // INPUT HARGA DENGAN FORMATTER
                  _buildInputField(
                    controller: _priceController, 
                    hint: 'Harga (Rp), cth: 15.000', 
                    isNumber: true
                  ),
                  
                  const SizedBox(height: 28),

                  _buildSectionTitle('KATEGORI'),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildCategoryChip('Makanan'), _buildCategoryChip('Minuman'), _buildCategoryChip('Jasa'), _buildCategoryChip('Lainnya'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1)))),
            child: ElevatedButton(
              onPressed: () async { 
                if (_nameController.text.isNotEmpty && _priceController.text.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(isEditMode ? 'Menyimpan perubahan...' : 'Menyimpan produk ke server...')),
                  );

                  final provider = Provider.of<CatalogProvider>(context, listen: false);

                  if (isEditMode) {
                    await provider.updateProduct(widget.product!.id, _nameController.text, _priceController.text, selectedCategory);
                  } else {
                    await provider.addProduct(_nameController.text, _priceController.text, selectedCategory);
                  }
                  
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: AppTheme.neonGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(isEditMode ? 'Simpan Perubahan' : 'Simpan Produk', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5));
  }

  Widget _buildInputField({required TextEditingController controller, required String hint, bool isNumber = false}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.045), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.14))),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        // PERBAIKAN DI SINI: Menyisipkan Formatter saat diketik
        inputFormatters: isNumber ? [CurrencyInputFormatter()] : [],
        style: const TextStyle(color: AppTheme.textWhite, fontSize: 13),
        decoration: InputDecoration(
          // Tambahan tulisan "Rp" kecil di sebelah kiri saat mengisi harga
          prefixIcon: isNumber ? const Padding(
            padding: EdgeInsets.only(left: 16, right: 8, top: 14),
            child: Text('Rp', style: TextStyle(color: AppTheme.neonGreen, fontWeight: FontWeight.bold, fontSize: 14)),
          ) : null,
          hintText: hint, 
          hintStyle: const TextStyle(color: Colors.white38, fontSize: 13), 
          border: InputBorder.none, 
          contentPadding: const EdgeInsets.all(16)
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label) {
    final isActive = selectedCategory == label; 
    return GestureDetector(
      onTap: () => setState(() => selectedCategory = label),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(color: isActive ? AppTheme.neonGreen.withOpacity(0.1) : Colors.transparent, borderRadius: BorderRadius.circular(20), border: Border.all(color: isActive ? AppTheme.neonGreen : Colors.white.withOpacity(0.14))),
        child: Text(label, style: TextStyle(color: isActive ? AppTheme.neonGreen : Colors.white60, fontSize: 12, fontWeight: isActive ? FontWeight.bold : FontWeight.w500)),
      ),
    );
  }
}
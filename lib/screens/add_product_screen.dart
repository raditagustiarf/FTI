import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/theme.dart';
import '../providers/catalog_provider.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    final numericString = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (numericString.isEmpty) return newValue;
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
    return TextEditingValue(text: formatted, selection: TextSelection.collapsed(offset: formatted.length));
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
  bool _isLoading = false;

  // Variabel Penampung Gambar
  Uint8List? _selectedImageBytes; // File gambar sementara dari Galeri
  String? _currentImageUrl; // URL gambar jika mode edit
  String? _imageExtension;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      isEditMode = true;
      _nameController.text = widget.product!.title;
      final cleanPrice = widget.product!.price.replaceAll(RegExp(r'[^0-9]'), '');
      _priceController.text = _formatInitialPrice(cleanPrice);
      _currentImageUrl = widget.product!.imageUrl; // Muat URL gambar lama
      
      if (['Makanan', 'Minuman', 'Jasa', 'Lainnya'].contains(widget.product!.category)) {
        selectedCategory = widget.product!.category;
      }
    }
  }

  String _formatInitialPrice(String numberStr) {
    if (numberStr.isEmpty) return '';
    String formatted = '';
    int count = 0;
    for (int i = numberStr.length - 1; i >= 0; i--) {
      if (count == 3) { formatted = '.$formatted'; count = 0; }
      formatted = numberStr[i] + formatted;
      count++;
    }
    return formatted;
  }

  // FUNGSI: Mengambil & Mengompres Gambar
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    // Kompresi: Kurangi resolusi dan kualitas jadi hemat kuota
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50, maxWidth: 800);
    
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _selectedImageBytes = bytes;
        _imageExtension = image.path.split('.').last;
        _currentImageUrl = null; // Hapus pratinjau URL lama
      });
    }
  }

  // FUNGSI: Upload ke Supabase & Simpan Data
  Future<void> _saveProduct() async {
    if (_nameController.text.isEmpty || _priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nama dan Harga wajib diisi!')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? finalImageUrl = _currentImageUrl; // Gunakan URL lama jika tidak ada gambar baru

      // Jika user memilih gambar baru dari galeri, upload dulu ke Storage!
      if (_selectedImageBytes != null) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.$_imageExtension';
        
        await Supabase.instance.client.storage.from('products').uploadBinary(
          fileName, 
          _selectedImageBytes!,
          fileOptions: const FileOptions(upsert: true),
        );

        finalImageUrl = Supabase.instance.client.storage.from('products').getPublicUrl(fileName);
      }

      final provider = Provider.of<CatalogProvider>(context, listen: false);
      if (isEditMode) {
        await provider.updateProduct(widget.product!.id, _nameController.text, _priceController.text, selectedCategory, imageUrl: finalImageUrl);
      } else {
        await provider.addProduct(_nameController.text, _priceController.text, selectedCategory, imageUrl: finalImageUrl);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Produk berhasil disimpan!'), backgroundColor: AppTheme.neonGreen));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
                  
                  // AREA KLIK GAMBAR
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 160, width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppTheme.neonGreen.withOpacity(0.05), 
                        borderRadius: BorderRadius.circular(16), 
                        border: Border.all(color: AppTheme.neonGreen.withOpacity(0.4)),
                        // Jika ada gambar dipilih, tampilkan
                        image: _selectedImageBytes != null 
                            ? DecorationImage(image: MemoryImage(_selectedImageBytes!), fit: BoxFit.cover)
                            : (_currentImageUrl != null 
                                ? DecorationImage(image: NetworkImage(_currentImageUrl!), fit: BoxFit.cover)
                                : null),
                      ),
                      child: (_selectedImageBytes == null && _currentImageUrl == null) 
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppTheme.neonGreen.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.add_a_photo_outlined, color: AppTheme.neonGreen, size: 28)),
                                const SizedBox(height: 12),
                                const Text('Upload Foto Produk', style: TextStyle(color: AppTheme.neonGreen, fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            )
                          // Jika sudah ada gambar, beri indikator kecil di pojok
                          : Align(
                              alignment: Alignment.bottomRight,
                              child: Container(
                                margin: const EdgeInsets.all(8),
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                child: const Icon(Icons.edit, color: Colors.white, size: 16),
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 28),
                  _buildSectionTitle('INFORMASI PRODUK'),
                  const SizedBox(height: 12),
                  _buildInputField(controller: _nameController, hint: 'Nama Produk, cth: Nasi Liwet Spesial'),
                  const SizedBox(height: 16),
                  _buildInputField(controller: _priceController, hint: 'Harga (Rp), cth: 15.000', isNumber: true),
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
              onPressed: _isLoading ? null : _saveProduct,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: AppTheme.neonGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                : Text(isEditMode ? 'Simpan Perubahan' : 'Simpan Produk', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
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
        inputFormatters: isNumber ? [CurrencyInputFormatter()] : [],
        style: const TextStyle(color: AppTheme.textWhite, fontSize: 13),
        decoration: InputDecoration(
          prefixIcon: isNumber ? const Padding(padding: EdgeInsets.only(left: 16, right: 8, top: 14), child: Text('Rp', style: TextStyle(color: AppTheme.neonGreen, fontWeight: FontWeight.bold, fontSize: 14))) : null,
          hintText: hint, hintStyle: const TextStyle(color: Colors.white38, fontSize: 13), border: InputBorder.none, contentPadding: const EdgeInsets.all(16)
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label) {
    final isActive = selectedCategory == label; 
    return GestureDetector(
      onTap: () => setState(() => selectedCategory = label),
      child: Container(
        margin: const EdgeInsets.only(right: 8), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(color: isActive ? AppTheme.neonGreen.withOpacity(0.1) : Colors.transparent, borderRadius: BorderRadius.circular(20), border: Border.all(color: isActive ? AppTheme.neonGreen : Colors.white.withOpacity(0.14))),
        child: Text(label, style: TextStyle(color: isActive ? AppTheme.neonGreen : Colors.white60, fontSize: 12, fontWeight: isActive ? FontWeight.bold : FontWeight.w500)),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/catalog_provider.dart';
import '../core/theme.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _supabase = Supabase.instance.client;
  
  // Controller untuk menangkap teks yang diketik
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  
  bool _isLoading = false;
  String _userInitials = '?';

  @override
  void initState() {
    super.initState();
    _loadCurrentProfile();
  }

  // FUNGSI 1: MENGAMBIL DATA DARI DATABASE (READ)
  Future<void> _loadCurrentProfile() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      try {
        final response = await _supabase
            .from('profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle();

        if (response != null && mounted) {
          setState(() {
            // Memasukkan data ke dalam kotak isian (TextField)
            final fullName = response['full_name'] ?? '';
            _nameController.text = fullName;
            
            // Catatan: Kolom phone & bio ini opsional (hanya di UI untuk sekarang,
            // atau bisa kamu tambahkan kolomnya di tabel Supabase nanti)
            _phoneController.text = response['phone'] ?? '';
            _bioController.text = response['bio'] ?? '';

            // Update inisial avatar
            if (fullName.isNotEmpty) {
              final parts = fullName.trim().split(' ');
              _userInitials = parts.length > 1 
                  ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
                  : fullName.substring(0, fullName.length >= 2 ? 2 : 1).toUpperCase();
            }
          });
        }
      } catch (e) {
        debugPrint('Error load profil: $e');
      }
    }
  }

  // FUNGSI 2: MENYIMPAN DATA KE DATABASE (UPDATE/UPSERT)
  Future<void> _saveProfile() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama Lengkap tidak boleh kosong!')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        // Menyimpan nama ke tabel profiles
        // (Jika tabelmu punya kolom 'phone' dan 'bio', bisa di-uncomment di bawah)
        await _supabase.from('profiles').upsert({
          'id': user.id,
          'full_name': newName,
          // 'phone': _phoneController.text,
          // 'bio': _bioController.text,
        });

        if (mounted) {
          // TAMBAHAN BARU: Suruh otak Katalog untuk Refresh!
          Provider.of<CatalogProvider>(context, listen: false).fetchProducts();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profil berhasil diperbarui! 🎉')),
          );
          Navigator.pop(context, true); 
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

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
          'Edit Profil',
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
                children: [
                  // 1. FOTO PROFIL
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 100, height: 100,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(colors: [Color(0xFFF1B18F), Color(0xFF945B44)]),
                        ),
                        child: Center(
                          child: Text(_userInitials, style: const TextStyle(color: Colors.black, fontSize: 32, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1919),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white70, size: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Ubah foto profil', style: TextStyle(color: AppTheme.textGray, fontSize: 11)),
                  const SizedBox(height: 32),

                  // 2. FORM INPUT
                  _buildInputField(label: 'Nama Lengkap', controller: _nameController),
                  const SizedBox(height: 16),
                  _buildInputField(label: 'Nomor Telepon', controller: _phoneController, hint: '+62...'),
                  const SizedBox(height: 16),
                  _buildInputField(
                    label: 'Bio / Deskripsi Toko', 
                    controller: _bioController,
                    hint: 'Masakan rumahan hangat...',
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          
          // 3. TOMBOL SIMPAN
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1)))),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveProfile,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: AppTheme.neonGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                : const Text('Simpan Perubahan', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET KOTAK INPUT (Diubah agar menggunakan TextEditingController)
  Widget _buildInputField({required String label, required TextEditingController controller, String? hint, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.045),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          child: TextField( // Diganti dari TextFormField menjadi TextField
            controller: controller, // <-- Controller membaca & menulis teks
            maxLines: maxLines,
            style: const TextStyle(color: AppTheme.textWhite, fontSize: 13, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white30),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }
}
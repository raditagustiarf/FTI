import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart'; 

import '../providers/catalog_provider.dart';
import '../core/theme.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _supabase = Supabase.instance.client;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  
  bool _isLoading = false;
  bool _isUploadingImage = false; 
  String _userInitials = '?';
  String? _avatarUrl; 

  @override
  void initState() {
    super.initState();
    _loadCurrentProfile();
  }

  Future<void> _loadCurrentProfile() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      try {
        final response = await _supabase.from('profiles').select().eq('id', user.id).maybeSingle();
        
        if (response != null && mounted) {
          setState(() {
            final fullName = response['full_name'] ?? '';
            _nameController.text = fullName;
            _phoneController.text = response['phone'] ?? '';
            _bioController.text = response['bio'] ?? '';
            _avatarUrl = response['avatar_url']; 
            
            if (fullName.isNotEmpty) {
              final parts = fullName.trim().split(' ');
              _userInitials = parts.length > 1 ? '${parts[0][0]}${parts[1][0]}'.toUpperCase() : fullName.substring(0, fullName.length >= 2 ? 2 : 1).toUpperCase();
            }
          });
        }
      } catch (e) {
        debugPrint('Error load profil: $e');
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50, maxWidth: 600);
      
      if (image == null) return; 

      setState(() => _isUploadingImage = true);
      
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final Uint8List imageBytes = await image.readAsBytes();
      final fileExt = image.path.split('.').last;
      final fileName = '${user.id}-${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      await _supabase.storage.from('avatars').uploadBinary(
        fileName, 
        imageBytes,
        fileOptions: const FileOptions(upsert: true), 
      );

      final imageUrlResponse = _supabase.storage.from('avatars').getPublicUrl(fileName);

      await _supabase.from('profiles').update({'avatar_url': imageUrlResponse}).eq('id', user.id);

      setState(() {
        _avatarUrl = imageUrlResponse;
        _isUploadingImage = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Foto profil berhasil diperbarui!'), backgroundColor: AppTheme.neonGreen));
        Provider.of<CatalogProvider>(context, listen: false).fetchProducts();
      }
    } catch (e) {
      setState(() => _isUploadingImage = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal upload: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _saveProfile() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nama Lengkap tidak boleh kosong!')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        await _supabase.from('profiles').update({
          'full_name': newName,
          'bio': _bioController.text,
          // Nomor HP tidak di-update agar selalu sama dengan data asli
        }).eq('id', user.id);
        
        if (mounted) {
          Provider.of<CatalogProvider>(context, listen: false).fetchProducts();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil berhasil diperbarui! ✨'), backgroundColor: AppTheme.neonGreen));
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
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
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white70), onPressed: () => Navigator.pop(context)),
        title: const Text('Edit Profil', style: TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.bold, fontSize: 17)),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _isUploadingImage ? null : _pickAndUploadImage,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 100, height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white12,
                            image: _avatarUrl != null 
                                ? DecorationImage(image: NetworkImage(_avatarUrl!), fit: BoxFit.cover)
                                : null,
                            gradient: _avatarUrl == null 
                                ? const LinearGradient(colors: [Color(0xFFF1B18F), Color(0xFF945B44)])
                                : null,
                          ),
                          child: _avatarUrl == null
                              ? Center(child: Text(_userInitials, style: const TextStyle(color: Colors.black, fontSize: 32, fontWeight: FontWeight.bold)))
                              : null,
                        ),
                        if (_isUploadingImage)
                          Container(
                            width: 100, height: 100,
                            decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black54),
                            child: const Center(child: CircularProgressIndicator(color: AppTheme.neonGreen)),
                          ),
                        Container(
                          width: 32, height: 32,
                          decoration: BoxDecoration(color: const Color(0xFF1A1919), shape: BoxShape.circle, border: Border.all(color: Colors.white24, width: 2)),
                          child: const Icon(Icons.camera_alt, color: Colors.white70, size: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Ubah foto profil (Tap foto)', style: TextStyle(color: AppTheme.textGray, fontSize: 11)),
                  const SizedBox(height: 32),
                  
                  _buildInputField(label: 'Nama Lengkap', controller: _nameController),
                  const SizedBox(height: 16),
                  
                  // ==========================================
                  // NOMOR HP SEKARANG DIKUNCI (READ-ONLY)
                  // ==========================================
                  _buildInputField(
                    label: 'Nomor Telepon (Tidak bisa diubah)', 
                    controller: _phoneController, 
                    hint: '+62...',
                    isReadOnly: true, // Kunci teks agar tidak bisa diedit
                  ),
                  const SizedBox(height: 16),
                  
                  _buildInputField(label: 'Bio / Deskripsi Toko', controller: _bioController, hint: 'Masakan rumahan hangat...', maxLines: 3),
                ],
              ),
            ),
          ),
          
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1)))),
            child: ElevatedButton(
              onPressed: _isLoading || _isUploadingImage ? null : _saveProfile,
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

  // Menambahkan parameter isReadOnly
  Widget _buildInputField({required String label, required TextEditingController controller, String? hint, int maxLines = 1, bool isReadOnly = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: isReadOnly ? Colors.white38 : Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isReadOnly ? Colors.black12 : Colors.white.withOpacity(0.045), // Latar belakang lebih gelap kalau terkunci
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(isReadOnly ? 0.05 : 0.15)),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            readOnly: isReadOnly, // Memblokir keyboard agar tidak muncul
            style: TextStyle(color: isReadOnly ? Colors.white38 : AppTheme.textWhite, fontSize: 13, fontWeight: FontWeight.w600), // Warna teks memudar jika terkunci
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
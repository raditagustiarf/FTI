import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 

String _formatRupiah(int number) {
  String result = number.toString();
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
  return 'Rp $formatted';
}

class Product {
  final String id;
  final String sellerId;
  final String sellerName; 
  final String title;
  final String price;
  final String category;
  final List<Color> gradientColors; 
  final double? latitude;  
  final double? longitude; 
  final bool isStoreVisible; // <-- BARU: Penyimpan status visibilitas

  Product({
    required this.id,
    required this.sellerId,
    required this.sellerName, 
    required this.title,
    required this.price,
    required this.category,
    required this.gradientColors,
    this.latitude,
    this.longitude,
    this.isStoreVisible = true, // Default toko buka
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] ?? 
                    json['profiles!fk_seller_profile'] ?? 
                    json['profiles!products_seller_id_fkey'];
    
    return Product(
      id: json['id'].toString(),
      sellerId: json['seller_id'].toString(),
      sellerName: profile != null ? profile['full_name'] ?? 'Penjual' : 'Penjual',
      latitude: profile != null ? profile['latitude']?.toDouble() : null,
      longitude: profile != null ? profile['longitude']?.toDouble() : null,
      // Tarik status dari database
      isStoreVisible: profile != null ? (profile['is_store_visible'] ?? true) : true,
      title: json['title'] ?? 'Tanpa Nama',
      price: _formatRupiah(json['price'] as int),
      category: json['category'] ?? 'Lainnya',
      gradientColors: const [Color(0xFF6D8D45), Color(0xFF20301D)], 
    );
  }
}

class CatalogProvider with ChangeNotifier {
  final _supabase = Supabase.instance.client;
  
  List<Product> _products = [];
  bool _isLoading = false;

  // PERBAIKAN: Hanya kirimkan produk yang status isStoreVisible-nya TRUE (Toko Buka) ke Peta & Daftar!
  List<Product> get products => _products.where((p) => p.isStoreVisible).toList();
  
  // Produk milik sendiri tetap terlihat semua meskipun toko sedang "ditutup"
  List<Product> get myProducts {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];
    return _products.where((p) => p.sellerId == user.id).toList();
  }

  bool get isLoading => _isLoading;

  CatalogProvider() {
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      // PERBAIKAN: Tambahkan pengambilan is_store_visible
      final response = await _supabase
          .from('products')
          .select('*, profiles!fk_seller_profile(full_name, latitude, longitude, is_store_visible)') 
          .order('created_at', ascending: false);
          
      _products = (response as List).map((data) => Product.fromJson(data)).toList();
    } catch (e) {
      try {
        final response = await _supabase
          .from('products')
          .select('*, profiles!products_seller_id_fkey(full_name, latitude, longitude, is_store_visible)') 
          .order('created_at', ascending: false);
          
        _products = (response as List).map((data) => Product.fromJson(data)).toList();
      } catch(e2) {
        debugPrint('Gagal mengambil data katalog: $e2');
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addProduct(String title, String price, String category) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return; 

      final numericPrice = price.replaceAll(RegExp(r'[^0-9]'), '');

      await _supabase.from('products').insert({
        'title': title,
        'price': int.parse(numericPrice),
        'category': category,
        'seller_id': user.id, 
      });

      await fetchProducts();
    } catch (e) {
      debugPrint('Error tambah produk: $e');
    }
  }

  Future<void> removeProduct(String id) async {
    try {
      await _supabase.from('products').delete().eq('id', id);
      await fetchProducts();
    } catch (e) {
      debugPrint('Error hapus produk: $e');
    }
  }

  Future<void> updateProduct(String id, String title, String price, String category) async {
    try {
      final numericPrice = price.replaceAll(RegExp(r'[^0-9]'), '');

      await _supabase.from('products').update({
        'title': title,
        'price': int.parse(numericPrice),
        'category': category,
      }).eq('id', id);

      await fetchProducts(); 
    } catch (e) {
      debugPrint('Error edit produk: $e');
    }
  }
}
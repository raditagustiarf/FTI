import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReviewProvider with ChangeNotifier {
  final _supabase = Supabase.instance.client;
  
  List<Map<String, dynamic>> _reviews = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get reviews => _reviews;
  bool get isLoading => _isLoading;

  // 1. Tarik semua ulasan untuk penjual tertentu
  Future<void> fetchReviews(String sellerId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _supabase
          .from('reviews')
          .select('*, buyer:profiles!reviews_buyer_id_fkey(full_name, avatar_url)')
          .eq('seller_id', sellerId)
          .order('created_at', ascending: false);
      
      _reviews = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Gagal menarik ulasan: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // 2. Kirim Ulasan Baru & Update Rata-rata Bintang Penjual
  Future<void> submitReview(String sellerId, int rating, String text) async {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null || myId == sellerId) return; // Tidak bisa review diri sendiri

    try {
      // Upsert: Masukkan baru, atau Timpa jika sudah pernah review
      await _supabase.from('reviews').upsert({
        'seller_id': sellerId,
        'buyer_id': myId,
        'rating': rating,
        'review_text': text,
      });

      // Hitung ulang rata-rata bintang
      await fetchReviews(sellerId);
      if (_reviews.isNotEmpty) {
        double totalRating = 0;
        for (var r in _reviews) {
          totalRating += (r['rating'] as num).toDouble();
        }
        double avgRating = totalRating / _reviews.length;

        // Simpan nilai rata-rata ke tabel profil penjual
        await _supabase.from('profiles').update({
          'rating': avgRating,
          'review_count': _reviews.length,
        }).eq('id', sellerId);
      }
    } catch (e) {
      debugPrint('Gagal mengirim ulasan: $e');
      rethrow;
    }
  }
}
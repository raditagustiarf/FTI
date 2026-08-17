import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReviewProvider with ChangeNotifier {
  final _supabase = Supabase.instance.client;
  
  List<Map<String, dynamic>> _reviews = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get reviews => _reviews;
  bool get isLoading => _isLoading;

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

  Future<void> submitReview(String sellerId, int rating, String text) async {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null || myId == sellerId) return;

    try {
      await _supabase.from('reviews').upsert({
        'seller_id': sellerId,
        'buyer_id': myId,
        'rating': rating,
        'review_text': text,
      });

      await fetchReviews(sellerId);
      if (_reviews.isNotEmpty) {
        double totalRating = 0;
        for (var r in _reviews) {
          totalRating += (r['rating'] as num).toDouble();
        }
        double avgRating = totalRating / _reviews.length;

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
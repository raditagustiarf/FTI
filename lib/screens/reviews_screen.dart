import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/theme.dart';
import '../providers/review_provider.dart';
import '../providers/catalog_provider.dart';

String getInitials(String name) {
  if (name.isEmpty) return '?';
  final parts = name.trim().split(' ');
  if (parts.length > 1) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
}

class ReviewsScreen extends StatefulWidget {
  final String sellerId;
  final String sellerName;
  final double currentRating;
  final int reviewCount;

  const ReviewsScreen({
    super.key, 
    required this.sellerId, 
    required this.sellerName,
    required this.currentRating,
    required this.reviewCount,
  });

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReviewProvider>(context, listen: false).fetchReviews(widget.sellerId);
    });
  }

  void _showWriteReviewModal() {
    int selectedRating = 5;
    final TextEditingController reviewController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.darkBackground,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tulis Ulasan', style: TextStyle(color: AppTheme.textWhite, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(index < selectedRating ? Icons.star : Icons.star_border, color: const Color(0xFFFFD700), size: 36),
                      onPressed: () => setModalState(() => selectedRating = index + 1),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
                  child: TextField(
                    controller: reviewController,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(hintText: 'Bagaimana pengalamanmu berbelanja di sini?', hintStyle: TextStyle(color: Colors.white38), border: InputBorder.none, contentPadding: EdgeInsets.all(16)),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    if (reviewController.text.trim().isEmpty) return;
                    Navigator.pop(context);
                    
                    try {
                      await Provider.of<ReviewProvider>(context, listen: false).submitReview(widget.sellerId, selectedRating, reviewController.text);
                      if (context.mounted) {
                        Provider.of<CatalogProvider>(context, listen: false).fetchProducts(); // Refresh katalog
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ulasan berhasil dikirim!'), backgroundColor: AppTheme.neonGreen));
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal mengirim ulasan'), backgroundColor: Colors.red));
                    }
                  },
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50), backgroundColor: AppTheme.neonGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text('Kirim Ulasan', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final myId = Supabase.instance.client.auth.currentUser?.id;
    final isMyStore = myId == widget.sellerId;

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBackground, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white70), onPressed: () => Navigator.pop(context)),
        title: Text('Ulasan ${widget.sellerName}', style: const TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.bold, fontSize: 17)),
      ),
      body: Consumer<ReviewProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) return const Center(child: CircularProgressIndicator(color: AppTheme.neonGreen));
          
          final reviews = provider.reviews;
          
          return Column(
            children: [
              Container(
                width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 28),
                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1)))),
                child: Column(
                  children: [
                    Text(widget.currentRating > 0 ? widget.currentRating.toStringAsFixed(1) : '0.0', style: const TextStyle(color: Color(0xFFFFD700), fontSize: 48, fontWeight: FontWeight.bold, letterSpacing: -2)),
                    const SizedBox(height: 8),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (index) => Icon(index < widget.currentRating.round() ? Icons.star : Icons.star_border, color: const Color(0xFFFFD700), size: 20))),
                    const SizedBox(height: 8),
                    Text('Berdasarkan ${reviews.length} ulasan', style: const TextStyle(color: AppTheme.textGray, fontSize: 11)),
                  ],
                ),
              ),
              Expanded(
                child: reviews.isEmpty
                    ? const Center(child: Text('Belum ada ulasan untuk toko ini.', style: TextStyle(color: Colors.white54)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: reviews.length,
                        itemBuilder: (context, index) {
                          final r = reviews[index];
                          final buyer = r['buyer'] ?? {};
                          final bName = buyer['full_name'] ?? 'Pembeli';
                          return _buildReviewCard(
                            initials: getInitials(bName), name: bName, avatarUrl: buyer['avatar_url'],
                            rating: r['rating'], review: r['review_text'] ?? '',
                          );
                        },
                      ),
              ),
              if (!isMyStore) // Tampilkan tombol Tulis Ulasan jika bukan toko kita sendiri
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1)))),
                  child: ElevatedButton(
                    onPressed: _showWriteReviewModal,
                    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50), backgroundColor: const Color(0xFF2A2A2A), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: const Text('Tulis Ulasan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          );
        }
      ),
    );
  }

  Widget _buildReviewCard({required String initials, required String name, String? avatarUrl, required int rating, required String review}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.1))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white12, image: avatarUrl != null ? DecorationImage(image: NetworkImage(avatarUrl), fit: BoxFit.cover) : null),
            child: avatarUrl == null ? Center(child: Text(initials, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: AppTheme.textWhite, fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(children: List.generate(5, (index) => Icon(index < rating ? Icons.star : Icons.star_border, color: const Color(0xFFFFD700), size: 12))),
                const SizedBox(height: 8),
                Text(review, style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
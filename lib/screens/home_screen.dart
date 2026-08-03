import 'package:flutter/material.dart';
import '../core/theme.dart';
import 'search_screen.dart';
import 'chat_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isMapView = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      // ANIMASI PERGANTIAN LAYAR (PETA <-> DAFTAR)
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        switchInCurve: Curves.easeOutCubic, 
        switchOutCurve: Curves.easeOutCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.05),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: isMapView ? _buildMapView() : _buildListView(),
      ),
    );
  }

  // ==========================================
  // LAYAR PETA
  // ==========================================
  Widget _buildMapView() {
    final size = MediaQuery.of(context).size;
    return Stack(
      key: const ValueKey('MapView'),
      children: [
        Container(
          width: size.width,
          height: size.height,
          color: const Color(0xFF19221E),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: size.width,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: AppTheme.neonGreen.withOpacity(0.05), blurRadius: 100, spreadRadius: 50),
                    ],
                  ),
                ),
              ),
              const Center(child: Text('Peta Interaktif', style: TextStyle(color: Colors.white24))),
            ],
          ),
        ),
        const Positioned(top: 250, left: 50, child: _PricePin(price: '15K')),
        const Positioned(top: 210, right: 60, child: _PricePin(price: '12K', isVerified: true)),
        const Positioned(top: 320, left: 200, child: _PricePin(price: '25K', isVerified: true)),
        SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSearchBar(floating: true),
              Padding(
                padding: const EdgeInsets.only(bottom: 90),
                child: _buildToggleSwitch(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // LAYAR DAFTAR
  // ==========================================
  Widget _buildListView() {
    return SafeArea(
      key: const ValueKey('ListView'),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 16),
            decoration: BoxDecoration(
              color: const Color(0xE5121111),
              border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1))),
            ),
            child: Column(
              children: [
                _buildSearchBar(floating: false),
                const SizedBox(height: 16),
                _buildToggleSwitch(),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCategoryChip('📍 Terdekat', true),
                      _buildCategoryChip('Makanan', false),
                      _buildCategoryChip('Minuman', false),
                      _buildCategoryChip('Jasa', false),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 100),
              children: [
                _buildProductCard(
                  title: 'Nasi Liwet Spesial', price: 'Rp 15.000', distance: '800 m',
                  sellerInitials: 'BR', sellerName: 'Bu Retno', rating: '4.9', bgGradient: const [Color(0xFFBB7225), Color(0xFF472111)],
                ),
                const SizedBox(height: 16),
                _buildProductCard(
                  title: 'Ayam Goreng Kampung', price: 'Rp 25.000', distance: '1.2 km',
                  sellerInitials: 'SR', sellerName: 'Siti Rohmah', rating: '5.0', bgGradient: const [Color(0xFFD59845), Color(0xFF4B2110)],
                ),
                const SizedBox(height: 16),
                _buildProductCard(
                  title: 'Es Teh Manis', price: 'Rp 5.000', distance: '600 m',
                  sellerInitials: 'WR', sellerName: 'Warung Rasa', rating: '4.8', bgGradient: const [Color(0xFF936340), Color(0xFF2B1911)],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // KOMPONEN UI
  // ==========================================
  Widget _buildSearchBar({required bool floating}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 500), 
            reverseTransitionDuration: const Duration(milliseconds: 400),
            pageBuilder: (context, animation, secondaryAnimation) => const SearchScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
                child: child,
              );
            },
          ),
        );
      },
      child: Hero(
        tag: 'search_bar_hero',
        child: Material(
          type: MaterialType.transparency,
          child: Container(
            margin: floating ? const EdgeInsets.symmetric(horizontal: 20, vertical: 10) : null,
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: floating ? const Color(0xB2111010) : Colors.white.withOpacity(0.045),
              borderRadius: BorderRadius.circular(floating ? 26 : 16),
              border: Border.all(color: Colors.white.withOpacity(0.14)),
              boxShadow: floating ? const [BoxShadow(color: Colors.black45, blurRadius: 30, offset: Offset(0, 10))] : null,
            ),
            child: Row(
              children: [
                Icon(Icons.location_on, color: floating ? AppTheme.textGray : Colors.white54, size: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    floating ? 'Jl. Batu Akik...' : 'Cari di sekitarmu...',
                    style: TextStyle(
                      color: floating ? AppTheme.textWhite : Colors.white54,
                      fontWeight: floating ? FontWeight.bold : FontWeight.normal,
                      fontSize: floating ? 14 : 12,
                    ),
                  ),
                ),
                if (floating) const Icon(Icons.keyboard_arrow_down, color: AppTheme.textGray),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleSwitch() {
    return Container(
      width: 180,
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xCC151414),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isMapView = true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                decoration: BoxDecoration(
                  color: isMapView ? AppTheme.neonGreen : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Text('Peta', style: TextStyle(color: isMapView ? Colors.black : Colors.white54, fontWeight: isMapView ? FontWeight.bold : FontWeight.w600, fontSize: 11)),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isMapView = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                decoration: BoxDecoration(
                  color: !isMapView ? AppTheme.neonGreen : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Text('Daftar', style: TextStyle(color: !isMapView ? Colors.black : Colors.white54, fontWeight: !isMapView ? FontWeight.bold : FontWeight.w600, fontSize: 11)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? AppTheme.neonGreen.withOpacity(0.06) : Colors.white.withOpacity(0.035),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isActive ? AppTheme.neonGreen : Colors.white.withOpacity(0.14)),
      ),
      child: Text(label, style: TextStyle(color: isActive ? AppTheme.neonGreen : Colors.white60, fontSize: 11, fontWeight: FontWeight.w500)),
    );
  }

  // FIXED: Penempatan GestureDetector sudah dikoreksi
  Widget _buildProductCard({
    required String title, required String price, required String distance,
    required String sellerInitials, required String sellerName, required String rating, required List<Color> bgGradient,
  }) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => const ProductDetailBottomSheet(),
        );
      },
      child: Container(
        decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.09))),
        child: Column(
          children: [
            Container(
              height: 108, width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: bgGradient),
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  margin: const EdgeInsets.all(8), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), borderRadius: BorderRadius.circular(6)),
                  child: const Text('Produk lokal', style: TextStyle(color: Colors.white70, fontSize: 9)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: AppTheme.textWhite, fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(price, style: const TextStyle(color: AppTheme.neonGreen, fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: AppTheme.textGray, size: 12),
                      const SizedBox(width: 4),
                      Text(distance, style: const TextStyle(color: AppTheme.textGray, fontSize: 10)),
                    ],
                  ),
                  const Divider(color: Colors.white12, height: 24),
                  Row(
                    children: [
                      CircleAvatar(radius: 12, backgroundColor: Colors.white.withOpacity(0.1), child: Text(sellerInitials, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold))),
                      const SizedBox(width: 8),
                      Text(sellerName, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                      const Spacer(),
                      const Icon(Icons.star, color: Color(0xFFFFD700), size: 12),
                      const SizedBox(width: 4),
                      Text(rating, style: const TextStyle(color: Color(0xFFFFD700), fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =========================================================
// WIDGET PIN HARGA DI PETA
// =========================================================
class _PricePin extends StatelessWidget {
  final String price; 
  final bool isVerified;
  const _PricePin({required this.price, this.isVerified = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true, 
          backgroundColor: Colors.transparent, 
          builder: (context) => const StoreBottomSheet(),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xD8151414),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isVerified ? const Color(0x72FFD700) : AppTheme.neonGreen.withOpacity(0.5)),
          boxShadow: [BoxShadow(color: isVerified ? const Color(0x38FFD700) : AppTheme.neonGreen.withOpacity(0.2), blurRadius: 15, spreadRadius: 2)],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(price, style: const TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.bold, fontSize: 12)),
            if (isVerified) ...[
              const SizedBox(width: 4),
              Container(padding: const EdgeInsets.all(2), decoration: const BoxDecoration(color: Color(0xFFFFD700), shape: BoxShape.circle), child: const Icon(Icons.check, size: 10, color: Colors.black)),
            ],
          ],
        ),
      ),
    );
  }
}

// =========================================================
// 1. BOTTOM SHEET: TOKO / KATALOG HARI INI
// =========================================================
class StoreBottomSheet extends StatelessWidget {
  const StoreBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75, 
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      decoration: const BoxDecoration(
        color: Color(0xFF151414),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(top: BorderSide(color: Colors.white12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44, height: 4,
              decoration: BoxDecoration(color: Colors.white30, borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [Color(0xFFF3BD9D), Color(0xFF8D503A)]),
                ),
                child: const Center(child: Text('SR', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Dapur Siti', style: TextStyle(color: AppTheme.textWhite, fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(width: 6),
                        Icon(Icons.verified, color: Color(0xFFFFD700), size: 14),
                      ],
                    ),
                    SizedBox(height: 2),
                    Text('0.3 km dari lokasimu', style: TextStyle(color: AppTheme.textGray, fontSize: 11)),
                  ],
                ),
              ),
              const Icon(Icons.star, color: AppTheme.neonGreen, size: 14),
              const SizedBox(width: 4),
              const Text('5.0', style: TextStyle(color: AppTheme.neonGreen, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 24),
          const Text('KATALOG HARI INI', style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.85, 
              children: [
                _buildGridItem(context, 'Nasi Liwet', 'Rp 15.000', const [Color(0xFFC27A27), Color(0xFF4D2411)]),
                _buildGridItem(context, 'Sayur Asem', 'Rp 12.000', const [Color(0xFF6D8D45), Color(0xFF20301D)]),
                _buildGridItem(context, 'Ayam Goreng', 'Rp 25.000', const [Color(0xFFD49745), Color(0xFF4D2110)]),
                _buildGridItem(context, 'Es Teh Manis', 'Rp 5.000', const [Color(0xFF89623D), Color(0xFF251912)]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, String title, String price, List<Color> gradient) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context); 
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => const ProductDetailBottomSheet(),
        );
      },
      child: Container(
        decoration: BoxDecoration(color: const Color(0xFF212121), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: gradient),
                ),
                child: Center(
                  child: Container(width: 40, height: 40, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.1), boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.2), blurRadius: 20)])),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: AppTheme.textWhite, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(price, style: const TextStyle(color: AppTheme.neonGreen, fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =========================================================
// 2. BOTTOM SHEET: DETAIL PRODUK
// =========================================================
class ProductDetailBottomSheet extends StatelessWidget {
  const ProductDetailBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.90, 
      decoration: const BoxDecoration(
        color: AppTheme.darkBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 250,
            width: double.infinity,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              gradient: LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [Color(0xFF663317), Color(0xFFD98C37)],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 20, left: 20,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white24)),
                      child: const Text('← Kembali', style: TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('MAKANAN RUMAHAN', style: TextStyle(color: AppTheme.neonGreen, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  const SizedBox(height: 8),
                  const Text('Ayam Goreng\nKampung', style: TextStyle(color: AppTheme.textWhite, fontSize: 28, fontWeight: FontWeight.bold, height: 1.2, letterSpacing: -1.0)),
                  const SizedBox(height: 12),
                  const Text('Rp 25.000', style: TextStyle(color: AppTheme.neonGreen, fontSize: 20, fontWeight: FontWeight.bold)),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(color: Colors.white12),
                  ),
                  const Text(
                    'Ayam kampung goreng dengan bumbu rempah pilihan, disajikan hangat lengkap dengan sambal dan lalapan segar.',
                    style: TextStyle(color: AppTheme.textGray, fontSize: 13, height: 1.6),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(16)),
                        child: const Center(child: Text('SR', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
                      ),
                      const SizedBox(width: 12),
                      const Text('Oleh ', style: TextStyle(color: Colors.white60, fontSize: 12)),
                      const Text('Siti Rohmah', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      const Icon(Icons.star, color: AppTheme.neonGreen, size: 14),
                      const SizedBox(width: 4),
                      const Text('5.0', style: TextStyle(color: AppTheme.neonGreen, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Bottom Action Bar (Sticky di bawah)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF151414),
              border: Border(top: BorderSide(color: Colors.white12)),
            ),
            child: Column(
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    // PERBAIKAN DI SINI: Menggunakan double.infinity untuk lebar, dan 50 untuk tinggi
                    minimumSize: const Size(double.infinity, 50),
                    side: BorderSide(color: AppTheme.neonGreen.withOpacity(0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('📍 Lihat Lokasi di Peta', style: TextStyle(color: AppTheme.neonGreen, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    // Menutup bottom sheet terlebih dahulu
                    Navigator.pop(context);
                    // Membuka halaman ChatDetailScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ChatDetailScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    // PERBAIKAN DI SINI: Menggunakan double.infinity untuk lebar, dan 50 untuk tinggi
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: AppTheme.neonGreen,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Chat Penjual', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart'; 
import 'package:latlong2/latlong.dart' hide Path; 
import 'package:geolocator/geolocator.dart'; // <-- Bantuan GPS untuk jarak
import '../core/theme.dart';
import '../providers/catalog_provider.dart';
import 'search_screen.dart';
import 'chat_detail_screen.dart';

String getInitials(String name) {
  if (name.isEmpty) return '?';
  final parts = name.trim().split(' ');
  if (parts.length > 1) {
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
  return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isMapView = true;
  String activeCategory = '📍 Terdekat'; 
  
  // Variabel untuk menyimpan lokasi GPS kita saat ini
  LatLng? _myLocation;

  @override
  void initState() {
    super.initState();
    _fetchMyLocation(); // Dapatkan lokasi kita saat aplikasi dibuka
  }

  // Fungsi mengambil koordinat GPS kita
  Future<void> _fetchMyLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      if (mounted) {
        setState(() {
          _myLocation = LatLng(position.latitude, position.longitude);
        });
      }
    } catch (e) {
      debugPrint('Gagal mengambil lokasi pembeli: $e');
    }
  }

  // Fungsi Ajaib: Menghitung & memformat jarak asli
  String _calculateDistance(double? lat, double? lng) {
    if (_myLocation == null || lat == null || lng == null) return '? km';
    
    // Hitung jarak dalam hitungan meter
    final double distanceInMeters = const Distance().distance(
      _myLocation!,
      LatLng(lat, lng),
    );

    // Format tampilan agar rapi
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toInt()} m'; // Tampilkan meter jika di bawah 1km
    } else {
      return '${(distanceInMeters / 1000).toStringAsFixed(1)} km'; // Tampilkan desimal km jika jauh
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = Provider.of<CatalogProvider>(context).products;

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        switchInCurve: Curves.easeOutCubic, 
        switchOutCurve: Curves.easeOutCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(begin: const Offset(0.0, 0.05), end: Offset.zero).animate(animation),
              child: child,
            ),
          );
        },
        child: isMapView ? _buildMapView(products) : _buildListView(products),
      ),
    );
  }

  Widget _buildMapView(List<Product> products) {
    const defaultCenter = LatLng(-2.1292, 106.1106);
    
    LatLng mapCenter = defaultCenter;
    for (var p in products) {
      if (p.latitude != null && p.longitude != null) {
        mapCenter = LatLng(p.latitude!, p.longitude!);
        break; 
      }
    }

    final List<String> dummyRatings = ['4.9', '5.0', '4.7', '4.8', '5.0'];

    return Stack(
      key: const ValueKey('MapView'),
      children: [
        FlutterMap(
          options: MapOptions(
            initialCenter: mapCenter,
            initialZoom: 15.5, 
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.tetanggamarket.app',
            ),
            MarkerLayer(
              markers: products
                  .where((p) => p.latitude != null && p.longitude != null)
                  .toList()
                  .asMap()
                  .entries
                  .map((entry) {
                
                final int index = entry.key;
                final Product product = entry.value;
                final coord = LatLng(product.latitude!, product.longitude!);
                // Hitung jarak asli untuk dikirim ke BottomSheet profil toko
                final realDistance = _calculateDistance(product.latitude, product.longitude);

                return Marker(
                  point: coord,
                  width: 140, 
                  height: 70, 
                  alignment: Alignment.bottomCenter, 
                  child: _StoreCategoryPin(
                    product: product,
                    allProducts: products,
                    isVerified: index % 2 == 1,
                    rating: dummyRatings[index % dummyRatings.length],
                    realDistance: realDistance, // <-- Kirim jarak ke pin
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSearchBar(floating: true),
              Padding(padding: const EdgeInsets.only(bottom: 90), child: _buildToggleSwitch()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildListView(List<Product> products) {
    return SafeArea(
      key: const ValueKey('ListView'),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 16),
            decoration: BoxDecoration(color: const Color(0xE5121111), border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1)))),
            child: Column(
              children: [
                _buildSearchBar(floating: false), const SizedBox(height: 16), _buildToggleSwitch(), const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCategoryChip('📍 Terdekat'), _buildCategoryChip('Makanan'), _buildCategoryChip('Minuman'), _buildCategoryChip('Jasa'), _buildCategoryChip('Lainnya'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: Builder(
              builder: (context) {
                // Filter kategori
                List<Product> filteredProducts = products.where((p) {
                  if (activeCategory == '📍 Terdekat') return true;
                  return p.category.toLowerCase() == activeCategory.toLowerCase();
                }).toList();

                // FITUR OTOMATIS: Urutkan produk dari yang paling dekat!
                if (activeCategory == '📍 Terdekat' && _myLocation != null) {
                  filteredProducts.sort((a, b) {
                    if (a.latitude == null || a.longitude == null) return 1; // Taruh bawah jika tidak ada lokasi
                    if (b.latitude == null || b.longitude == null) return -1;
                    
                    final distA = const Distance().distance(_myLocation!, LatLng(a.latitude!, a.longitude!));
                    final distB = const Distance().distance(_myLocation!, LatLng(b.latitude!, b.longitude!));
                    return distA.compareTo(distB);
                  });
                }

                if (filteredProducts.isEmpty) {
                  return const Center(child: Text('Belum ada produk di kategori ini', style: TextStyle(color: Colors.white54)));
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 100),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final prod = filteredProducts[index];
                    // Kirim jarak asli ke kartu produk
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildProductCard(
                        product: prod,
                        distance: _calculateDistance(prod.latitude, prod.longitude), // <-- Jarak Asli!
                        sellerInitials: getInitials(prod.sellerName),
                        sellerName: prod.sellerName, 
                        rating: '4.9',
                      ),
                    );
                  },
                );
              }
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar({required bool floating}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 500), reverseTransitionDuration: const Duration(milliseconds: 400),
            pageBuilder: (context, animation, secondaryAnimation) => const SearchScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: CurveTween(curve: Curves.easeInOut).animate(animation), child: child);
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
            height: 48, padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: floating ? const Color(0xB2111010) : Colors.white.withOpacity(0.045),
              borderRadius: BorderRadius.circular(floating ? 26 : 16),
              border: Border.all(color: Colors.white.withOpacity(0.14)),
              boxShadow: floating ? const [BoxShadow(color: Colors.black45, blurRadius: 30, offset: Offset(0, 10))] : null,
            ),
            child: Row(
              children: [
                Icon(Icons.location_on, color: floating ? AppTheme.textGray : Colors.white54, size: 18), const SizedBox(width: 12),
                Expanded(child: Text(floating ? 'Jl. Batu Akik...' : 'Cari di sekitarmu...', style: TextStyle(color: floating ? AppTheme.textWhite : Colors.white54, fontWeight: floating ? FontWeight.bold : FontWeight.normal, fontSize: floating ? 14 : 12))),
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
      width: 180, height: 44, padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: const Color(0xCC151414), borderRadius: BorderRadius.circular(22), border: Border.all(color: Colors.white.withOpacity(0.12))),
      child: Row(
        children: [
          Expanded(child: GestureDetector(onTap: () => setState(() => isMapView = true), child: AnimatedContainer(duration: const Duration(milliseconds: 250), curve: Curves.easeOut, decoration: BoxDecoration(color: isMapView ? AppTheme.neonGreen : Colors.transparent, borderRadius: BorderRadius.circular(20)), alignment: Alignment.center, child: Text('Peta', style: TextStyle(color: isMapView ? Colors.black : Colors.white54, fontWeight: isMapView ? FontWeight.bold : FontWeight.w600, fontSize: 11))))),
          Expanded(child: GestureDetector(onTap: () => setState(() => isMapView = false), child: AnimatedContainer(duration: const Duration(milliseconds: 250), curve: Curves.easeOut, decoration: BoxDecoration(color: !isMapView ? AppTheme.neonGreen : Colors.transparent, borderRadius: BorderRadius.circular(20)), alignment: Alignment.center, child: Text('Daftar', style: TextStyle(color: !isMapView ? Colors.black : Colors.white54, fontWeight: !isMapView ? FontWeight.bold : FontWeight.w600, fontSize: 11))))),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label) {
    final isActive = activeCategory == label; 
    return GestureDetector(
      onTap: () => setState(() => activeCategory = label),
      child: Container(
        margin: const EdgeInsets.only(right: 8), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(color: isActive ? AppTheme.neonGreen.withOpacity(0.06) : Colors.white.withOpacity(0.035), borderRadius: BorderRadius.circular(20), border: Border.all(color: isActive ? AppTheme.neonGreen : Colors.white.withOpacity(0.14))),
        child: Text(label, style: TextStyle(color: isActive ? AppTheme.neonGreen : Colors.white60, fontSize: 11, fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _buildProductCard({required Product product, required String distance, required String sellerInitials, required String sellerName, required String rating}) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => ProductDetailBottomSheet(product: product));
      },
      child: Container(
        decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.09))),
        child: Column(
          children: [
            Container(height: 108, width: double.infinity, decoration: BoxDecoration(borderRadius: const BorderRadius.vertical(top: Radius.circular(15)), gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: product.gradientColors)), child: Align(alignment: Alignment.bottomLeft, child: Container(margin: const EdgeInsets.all(8), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), borderRadius: BorderRadius.circular(6)), child: Text(product.category, style: const TextStyle(color: Colors.white70, fontSize: 9))))),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.title, style: const TextStyle(color: AppTheme.textWhite, fontSize: 13, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(product.price, style: const TextStyle(color: AppTheme.neonGreen, fontSize: 13, fontWeight: FontWeight.bold)), const SizedBox(height: 8),
                  // TAMPILAN JARAK ASLI
                  Row(children: [const Icon(Icons.location_on, color: AppTheme.textGray, size: 12), const SizedBox(width: 4), Text(distance, style: const TextStyle(color: AppTheme.textGray, fontSize: 10))]), const Divider(color: Colors.white12, height: 24),
                  Row(children: [CircleAvatar(radius: 12, backgroundColor: Colors.white.withOpacity(0.1), child: Text(sellerInitials, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold))), const SizedBox(width: 8), Text(sellerName, style: const TextStyle(color: Colors.white70, fontSize: 11)), const Spacer(), const Icon(Icons.star, color: Color(0xFFFFD700), size: 12), const SizedBox(width: 4), Text(rating, style: const TextStyle(color: Color(0xFFFFD700), fontSize: 11))]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoreCategoryPin extends StatelessWidget {
  final Product product;
  final List<Product> allProducts; 
  final bool isVerified;
  final String rating;
  final String realDistance; // <-- Tambahan variabel jarak asli
  
  const _StoreCategoryPin({required this.product, required this.allProducts, this.isVerified = false, required this.rating, required this.realDistance});

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'makanan': return Icons.restaurant;
      case 'minuman': return Icons.local_cafe;
      case 'jasa': return Icons.handyman;
      case 'lainnya': case 'benda': return Icons.shopping_bag;
      default: return Icons.storefront;
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = isVerified ? const Color(0x72FFD700) : AppTheme.neonGreen.withOpacity(0.5);
    final glowColor = isVerified ? const Color(0x38FFD700) : AppTheme.neonGreen.withOpacity(0.2);
    final bgColor = const Color(0xFF151414); 

    return GestureDetector(
      onTap: () {
        final sellerProducts = allProducts.where((p) => p.sellerId == product.sellerId).toList();
        showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => StoreBottomSheet(storeProduct: product, products: sellerProducts, distance: realDistance)); // Kirim ke BottomSheet
      },
      child: Column(
        mainAxisSize: MainAxisSize.min, 
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: borderColor, width: 1.5), boxShadow: [BoxShadow(color: glowColor, blurRadius: 15, spreadRadius: 2)]),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_getCategoryIcon(product.category), color: AppTheme.textWhite, size: 14), const SizedBox(width: 8), Container(width: 1, height: 12, color: Colors.white24), const SizedBox(width: 8),
                const Icon(Icons.star, color: Color(0xFFFFD700), size: 12), const SizedBox(width: 4), Text(rating, style: const TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.bold, fontSize: 11)),
              ],
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -1.5), 
            child: CustomPaint(size: const Size(14, 8), painter: _PinTailPainter(borderColor: borderColor, bgColor: bgColor)),
          ),
        ],
      ),
    );
  }
}

class _PinTailPainter extends CustomPainter {
  final Color borderColor;
  final Color bgColor;
  _PinTailPainter({required this.borderColor, required this.bgColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paintBg = Paint()..color = bgColor..style = PaintingStyle.fill;
    final paintBorder = Paint()..color = borderColor..strokeWidth = 1.5..strokeJoin = StrokeJoin.round..style = PaintingStyle.stroke;
    final path = Path()..moveTo(0, 0)..lineTo(size.width / 2, size.height)..lineTo(size.width, 0)..close(); 
    canvas.drawPath(path, paintBg);
    final pathBorder = Path()..moveTo(0, 0)..lineTo(size.width / 2, size.height)..lineTo(size.width, 0);
    canvas.drawPath(pathBorder, paintBorder);
  }
  @override bool shouldRepaint(covariant _PinTailPainter oldDelegate) => oldDelegate.borderColor != borderColor || oldDelegate.bgColor != bgColor;
}

class StoreBottomSheet extends StatelessWidget {
  final Product storeProduct; 
  final List<Product> products; 
  final String distance; // <-- Terima jarak asli

  const StoreBottomSheet({super.key, required this.storeProduct, required this.products, required this.distance});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75, padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      decoration: const BoxDecoration(color: Color(0xFF151414), borderRadius: BorderRadius.vertical(top: Radius.circular(32)), border: Border(top: BorderSide(color: Colors.white12))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 44, height: 4, decoration: BoxDecoration(color: Colors.white30, borderRadius: BorderRadius.circular(10)))), const SizedBox(height: 20),
          Row(
            children: [
              Container(width: 44, height: 44, decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [Color(0xFFF3BD9D), Color(0xFF8D503A)])), child: Center(child: Text(getInitials(storeProduct.sellerName), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)))), const SizedBox(width: 12),
              // TAMPILAN JARAK ASLI DI PROFIL TOKO
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Text(storeProduct.sellerName, style: const TextStyle(color: AppTheme.textWhite, fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(width: 6), const Icon(Icons.verified, color: Color(0xFFFFD700), size: 14)]), const SizedBox(height: 2), Text('$distance dari lokasimu', style: const TextStyle(color: AppTheme.textGray, fontSize: 11))])),
              const Icon(Icons.star, color: AppTheme.neonGreen, size: 14), const SizedBox(width: 4), const Text('5.0', style: TextStyle(color: AppTheme.neonGreen, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 24), const Text('KATALOG HARI INI', style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)), const SizedBox(height: 12),
          Expanded(
            child: GridView.builder(
              itemCount: products.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 0.85),
              itemBuilder: (context, index) { return _buildGridItem(context, products[index]); },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, Product product) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => ProductDetailBottomSheet(product: product));
      },
      child: Container(
        decoration: BoxDecoration(color: const Color(0xFF212121), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Container(width: double.infinity, decoration: BoxDecoration(borderRadius: const BorderRadius.vertical(top: Radius.circular(15)), gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: product.gradientColors)), child: Center(child: Container(width: 40, height: 40, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.1), boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.2), blurRadius: 20)]))))),
            Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(product.title, style: const TextStyle(color: AppTheme.textWhite, fontSize: 12, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis), const SizedBox(height: 4), Text(product.price, style: const TextStyle(color: AppTheme.neonGreen, fontSize: 11, fontWeight: FontWeight.bold))])),
          ],
        ),
      ),
    );
  }
}

class ProductDetailBottomSheet extends StatelessWidget {
  final Product product; 
  const ProductDetailBottomSheet({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.90, decoration: const BoxDecoration(color: AppTheme.darkBackground, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 250, width: double.infinity, decoration: BoxDecoration(borderRadius: const BorderRadius.vertical(top: Radius.circular(30)), gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: product.gradientColors)), child: Stack(children: [Positioned(top: 20, left: 20, child: GestureDetector(onTap: () => Navigator.pop(context), child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white24)), child: const Text('← Kembali', style: TextStyle(color: Colors.white, fontSize: 12)))))])),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.category.toUpperCase(), style: const TextStyle(color: AppTheme.neonGreen, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)), const SizedBox(height: 8),
                  Text(product.title, style: const TextStyle(color: AppTheme.textWhite, fontSize: 28, fontWeight: FontWeight.bold, height: 1.2, letterSpacing: -1.0)), const SizedBox(height: 12),
                  Text(product.price, style: const TextStyle(color: AppTheme.neonGreen, fontSize: 20, fontWeight: FontWeight.bold)), const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: Colors.white12)),
                  const Text('Dibuat segar setiap hari dengan bahan-bahan pilihan terbaik dari tetangga sekitar, disajikan khusus untuk Anda.', style: TextStyle(color: AppTheme.textGray, fontSize: 13, height: 1.6)), const SizedBox(height: 20),
                  Row(children: [Container(width: 32, height: 32, decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(16)), child: Center(child: Text(getInitials(product.sellerName), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)))), const SizedBox(width: 12), const Text('Oleh ', style: TextStyle(color: Colors.white60, fontSize: 12)), Text(product.sellerName, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)), const Spacer(), const Icon(Icons.star, color: AppTheme.neonGreen, size: 14), const SizedBox(width: 4), const Text('5.0', style: TextStyle(color: AppTheme.neonGreen, fontSize: 12))]),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20), decoration: const BoxDecoration(color: Color(0xFF151414), border: Border(top: BorderSide(color: Colors.white12))),
            child: Column(
              children: [
                OutlinedButton(onPressed: () => Navigator.pop(context), style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50), side: BorderSide(color: AppTheme.neonGreen.withOpacity(0.5)), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('📍 Lihat Lokasi di Peta', style: TextStyle(color: AppTheme.neonGreen, fontWeight: FontWeight.bold))), const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    final navigator = Navigator.of(context, rootNavigator: true);
                    navigator.pop();
                    navigator.push(MaterialPageRoute(builder: (context) => ChatDetailScreen(partnerId: product.sellerId, partnerName: product.sellerName, partnerInitials: getInitials(product.sellerName))));
                  },
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50), backgroundColor: AppTheme.neonGreen, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
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
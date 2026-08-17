import 'dart:convert'; 
import 'package:http/http.dart' as http; 
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:latlong2/latlong.dart' hide Path; 
import '../core/theme.dart';
import '../providers/catalog_provider.dart'; 
import 'pick_location_screen.dart'; 

class LocationSettingsScreen extends StatefulWidget {
  const LocationSettingsScreen({super.key});

  @override
  State<LocationSettingsScreen> createState() => _LocationSettingsScreenState();
}

class _LocationSettingsScreenState extends State<LocationSettingsScreen> {
  final _supabase = Supabase.instance.client;
  bool isLocationShared = true; 
  LatLng? _selectedLocation; 
  bool _isLoading = true; 
  String _addressName = ''; 

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation(); 
  }

  Future<void> _getAddressFromLatLng(double lat, double lng) async {
    setState(() => _addressName = 'Mencari nama jalan...');
    try {
      final url = 'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=18&addressdetails=1';
      final response = await http.get(Uri.parse(url), headers: {
        'Accept-Language': 'id-ID', 
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['address'] != null) {
          final address = data['address'];
          final road = address['road'] ?? address['pedestrian'] ?? address['path'] ?? '';
          final suburb = address['suburb'] ?? address['village'] ?? address['neighbourhood'] ?? '';
          final city = address['city'] ?? address['town'] ?? '';

          List<String> parts = [];
          if (road.isNotEmpty) parts.add(road);
          if (suburb.isNotEmpty) parts.add(suburb);
          if (city.isNotEmpty && parts.isEmpty) parts.add(city);

          setState(() {
            _addressName = parts.isNotEmpty ? parts.join(', ') : data['display_name'].split(',')[0];
          });
          return;
        }
      }
      setState(() => _addressName = 'Lokasi Terpilih (Nama jalan tidak tersedia)');
    } catch (e) {
      setState(() => _addressName = 'Lokasi Terpilih (Koneksi bermasalah)');
    }
  }

  Future<void> _loadCurrentLocation() async {
    try {
      final myId = _supabase.auth.currentUser?.id;
      if (myId != null) {
        final data = await _supabase.from('profiles').select('latitude, longitude, is_store_visible').eq('id', myId).single();

        if (data['is_store_visible'] != null) {
          isLocationShared = data['is_store_visible'];
        }

        if (data['latitude'] != null && data['longitude'] != null) {
          final lat = data['latitude'].toDouble();
          final lng = data['longitude'].toDouble();
          setState(() {
            _selectedLocation = LatLng(lat, lng);
          });
          await _getAddressFromLatLng(lat, lng);
        }
      }
    } catch (e) {
      debugPrint('Belum ada lokasi tersimpan: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
          'Pengaturan Lokasi',
          style: TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.bold, fontSize: 17),
        ),
        centerTitle: false,
      ),
      body: _isLoading 
      ? const Center(child: CircularProgressIndicator(color: AppTheme.neonGreen))
      : Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                        colors: [Color(0xFF242B20), Color(0xFF121212)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.12)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('VISIBILITAS TOKO', style: TextStyle(color: AppTheme.neonGreen, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Bagikan Lokasi Jualan', style: TextStyle(color: AppTheme.textWhite, fontSize: 15, fontWeight: FontWeight.bold)),
                                  SizedBox(height: 4),
                                  Text('Muncul di peta untuk tetangga sekitar.', style: TextStyle(color: AppTheme.textGray, fontSize: 11)),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () => setState(() => isLocationShared = !isLocationShared),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 50, height: 28,
                                decoration: BoxDecoration(
                                  color: isLocationShared ? AppTheme.neonGreen : Colors.white24,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: AnimatedAlign(
                                  duration: const Duration(milliseconds: 200),
                                  alignment: isLocationShared ? Alignment.centerRight : Alignment.centerLeft,
                                  child: Container(
                                    margin: const EdgeInsets.all(2),
                                    width: 24, height: 24,
                                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  const Text('TITIK & PATOKAN LOKASI', style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  const SizedBox(height: 12),
                  
                  GestureDetector(
                    onTap: () async {
                      final LatLng? result = await Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (context) => const PickLocationScreen())
                      );
                      if (result != null) {
                        setState(() => _selectedLocation = result);
                        await _getAddressFromLatLng(result.latitude, result.longitude);
                      }
                    },
                    child: Container(
                      height: 124, width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF19221E),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.12)),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(color: _selectedLocation != null ? AppTheme.neonGreen.withOpacity(0.2) : AppTheme.neonGreen, shape: BoxShape.circle, boxShadow: [BoxShadow(color: AppTheme.neonGreen.withOpacity(0.5), blurRadius: 25)]),
                            child: Icon(Icons.location_on, color: _selectedLocation != null ? AppTheme.neonGreen : Colors.black, size: 24),
                          ),
                          Positioned(
                            bottom: 12, left: 12, right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
                              child: Text(
                                _selectedLocation != null 
                                  ? '$_addressName\n(Tap untuk ubah)'
                                  : 'Buka Peta & Tentukan Titik →', 
                                style: TextStyle(color: _selectedLocation != null ? AppTheme.neonGreen : Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                                maxLines: 2, 
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  const Text('Catatan/Patokan Alamat (Opsional)', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.045),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.14)),
                    ),
                    child: const TextField(
                      maxLines: 3,
                      style: TextStyle(color: AppTheme.textWhite, fontSize: 12),
                      decoration: InputDecoration(
                        hintText: 'Contoh: Rumah pagar hitam, di sebelah pos satpam...',
                        hintStyle: TextStyle(color: Colors.white38, fontSize: 12),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                      ),
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
                try {
                  final myId = _supabase.auth.currentUser?.id;
                  if (myId != null) {
                    final updateData = <String, dynamic>{
                      'is_store_visible': isLocationShared,
                    };
                    
                    if (_selectedLocation != null) {
                      updateData['latitude'] = _selectedLocation!.latitude;
                      updateData['longitude'] = _selectedLocation!.longitude;
                    }

                    await _supabase.from('profiles').update(updateData).eq('id', myId);

                    if (context.mounted) {
                      Provider.of<CatalogProvider>(context, listen: false).fetchProducts();

                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(isLocationShared ? 'Tokomu kini terlihat di peta!' : 'Toko disembunyikan sementara.'), 
                        backgroundColor: isLocationShared ? AppTheme.neonGreen : Colors.orangeAccent,
                      ));
                      Navigator.pop(context);
                    }
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Gagal menyimpan pengaturan: $e'), 
                      backgroundColor: Colors.redAccent
                    ));
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: AppTheme.neonGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Simpan Pengaturan', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }
}
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:geolocator/geolocator.dart';
import '../core/theme.dart';

class PickLocationScreen extends StatefulWidget {
  const PickLocationScreen({super.key});

  @override
  State<PickLocationScreen> createState() => _PickLocationScreenState();
}

class _PickLocationScreenState extends State<PickLocationScreen> {
  final MapController _mapController = MapController();
  
  LatLng _currentCenter = const LatLng(-2.1292, 106.1106);
  bool _isGettingLocation = false;
  
  String _addressName = 'Mencari lokasi...'; 

  @override
  void initState() {
    super.initState();
    _getAddressFromLatLng(_currentCenter.latitude, _currentCenter.longitude);
  }

  Future<void> _getAddressFromLatLng(double lat, double lng) async {
    try {
      final url = 'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=18&addressdetails=1';
      final response = await http.get(Uri.parse(url), headers: {
        'Accept-Language': 'id-ID', 
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['address'] != null) {
          final address = data['address'];
          
          final road = address['road'] ?? 
                       address['residential'] ?? 
                       address['highway'] ?? 
                       address['street'] ?? 
                       address['pedestrian'] ?? 
                       address['path'] ?? 
                       address['footway'] ?? '';
                       
          final building = address['building'] ?? address['amenity'] ?? address['shop'] ?? '';
          final suburb = address['suburb'] ?? address['village'] ?? address['neighbourhood'] ?? address['hamlet'] ?? '';
          final city = address['city'] ?? address['town'] ?? address['municipality'] ?? '';

          List<String> parts = [];
          
          if (building.isNotEmpty) parts.add(building);
          if (road.isNotEmpty) parts.add(road);
          if (suburb.isNotEmpty) parts.add(suburb);
          if (city.isNotEmpty && parts.isEmpty) parts.add(city);

          if (mounted) {
            setState(() {
              if (parts.isNotEmpty) {
                _addressName = parts.join(', ');
              } else {
                _addressName = data['display_name'].split(',')[0];
              }
            });
          }
          return;
        }
      }
      if (mounted) setState(() => _addressName = 'Lokasi Terpilih (Jalan tak dikenal)');
    } catch (e) {
      if (mounted) setState(() => _addressName = 'Lokasi Terpilih (Offline)');
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isGettingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw 'GPS tidak aktif';

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) throw 'Izin GPS ditolak';
      }
      if (permission == LocationPermission.deniedForever) throw 'Izin GPS diblokir permanen';

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final myLocation = LatLng(position.latitude, position.longitude);

      _mapController.move(myLocation, 16.5);
      setState(() => _currentCenter = myLocation);
      
      _getAddressFromLatLng(myLocation.latitude, myLocation.longitude);

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isGettingLocation = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentCenter,
              initialZoom: 15.0,
              onPositionChanged: (position, hasGesture) {
                if (position.center != null) {
                  setState(() => _currentCenter = position.center!);
                }
              },
              onMapEvent: (event) {
                if (event is MapEventMoveEnd) {
                  _getAddressFromLatLng(_currentCenter.latitude, _currentCenter.longitude);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.lokit.app',
              ),
            ],
          ),

          IgnorePointer(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 48),
                child: Icon(Icons.location_on, color: AppTheme.neonGreen, size: 48, shadows: [
                  Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 5))
                ]),
              ),
            ),
          ),

          // 3. TOMBOL GPS
          Positioned(
            right: 20,
            bottom: 260, 
            child: FloatingActionButton(
              heroTag: 'btn_gps',
              backgroundColor: const Color(0xFF151414),
              onPressed: _getCurrentLocation,
              child: _isGettingLocation 
                ? const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(color: AppTheme.neonGreen, strokeWidth: 3))
                : const Icon(Icons.my_location, color: AppTheme.neonGreen),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white12)),
                      child: const Text('← Kembali', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(20)),
                    child: const Text('Geser Peta', style: TextStyle(color: AppTheme.textWhite, fontSize: 13, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: const Color(0xE5171616), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white12)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('LOKASI TERPILIH', style: TextStyle(color: AppTheme.neonGreen, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  const SizedBox(height: 8),
                  
                  
                  Text(
                    _addressName, 
                    style: const TextStyle(color: AppTheme.textWhite, fontSize: 16, fontWeight: FontWeight.bold, height: 1.4),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, _currentCenter),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: AppTheme.neonGreen,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Konfirmasi Titik Ini', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
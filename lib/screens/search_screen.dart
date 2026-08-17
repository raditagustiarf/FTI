import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = false;
  List<dynamic> _searchResults = [];
  Timer? _debounce;

  List<String> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _history = prefs.getStringList('search_history') ?? ['Pangkalpinang', 'Jalan Ahmad Yani'];
    });
  }

  Future<void> _saveToHistory(String locationName) async {
    final prefs = await SharedPreferences.getInstance();
    
    _history.remove(locationName);
    _history.insert(0, locationName);
    
    if (_history.length > 5) {
      _history = _history.sublist(0, 5);
    }
    
    await prefs.setStringList('search_history', _history);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });

    if (_debounce?.isActive ?? false) _debounce!.cancel();

    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchLocation(query);
    });
  }

  Future<void> _searchLocation(String query) async {
    setState(() => _isLoading = true);
    try {
      final encodedQuery = Uri.encodeComponent(query.trim());
      final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=$encodedQuery&format=json&addressdetails=1&limit=6&countrycodes=id');
      final response = await http.get(url, headers: {'Accept-Language': 'id-ID'});

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _searchResults = data;
          });
        }
      }
    } catch (e) {
      debugPrint('Error cari lokasi: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xEA0C0B0B),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.14)),
                      ),
                      child: const Icon(Icons.arrow_back, color: AppTheme.textWhite, size: 20),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Cari Area Peta',
                    style: TextStyle(
                      color: AppTheme.textWhite,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              Hero(
                tag: 'search_bar_hero',
                child: Material(
                  type: MaterialType.transparency,
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xD8171616),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.neonGreen.withOpacity(0.75)),
                      boxShadow: [
                        BoxShadow(color: AppTheme.neonGreen.withOpacity(0.1), blurRadius: 22),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      autofocus: true, 
                      style: const TextStyle(color: AppTheme.textWhite),
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'Ketik nama jalan, perumahan, kota...',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                        prefixIcon: const Icon(Icons.search, color: AppTheme.textGray),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                        suffixIcon: _searchQuery.isNotEmpty 
                          ? IconButton(
                              icon: const Icon(Icons.close, color: Colors.white54, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged('');
                              },
                            )
                          : null,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              Expanded(
                child: _searchQuery.isEmpty 
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('RIWAYAT LOKASI', style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                        const SizedBox(height: 12),
                        ..._history.map((item) => _buildHistoryItem(item)),
                      ],
                    )
                  : _isLoading 
                    ? const Center(child: CircularProgressIndicator(color: AppTheme.neonGreen))
                    : _searchResults.isEmpty 
                      ? const Center(child: Text('Jalan atau area tidak ditemukan.', style: TextStyle(color: Colors.white54, fontSize: 13)))
                      : ListView.builder(
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final result = _searchResults[index];
                            final address = result['address'] ?? {};
                            
                            String title = result['name'] ?? '';
                            if (title.isEmpty) {
                              title = address['road'] ?? address['pedestrian'] ?? address['suburb'] ?? address['village'] ?? 'Lokasi tidak diketahui';
                            }

                            List<String> subParts = [];
                            if (address['suburb'] != null && address['suburb'] != title) subParts.add(address['suburb']);
                            if (address['city'] != null && address['city'] != title) subParts.add(address['city']);
                            if (address['state'] != null) subParts.add(address['state']);
                            
                            String subtitle = subParts.join(', ');
                            if (subtitle.isEmpty) subtitle = result['display_name'] ?? ''; 

                            final lat = double.parse(result['lat']);
                            final lon = double.parse(result['lon']);
                            
                            return TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: Duration(milliseconds: 300 + (index * 80)), 
                              curve: Curves.easeOutQuart,
                              builder: (context, value, child) {
                                return Transform.translate(
                                  offset: Offset(0, 30 * (1 - value)), 
                                  child: Opacity(
                                    opacity: value,
                                    child: child,
                                  ),
                                );
                              },
                              child: _buildLocationResultCard(title, subtitle, lat, lon),
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryItem(String location) {
    return GestureDetector(
      onTap: () {
        _searchController.text = location;
        _onSearchChanged(location);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.035),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.07)),
        ),
        child: Row(
          children: [
            const Icon(Icons.history, color: AppTheme.textGray, size: 18),
            const SizedBox(width: 12),
            Text(location, style: TextStyle(color: Colors.white.withOpacity(0.82), fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationResultCard(String title, String subtitle, double lat, double lon) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); 
        _saveToHistory(title);
        Navigator.pop(context, LatLng(lat, lon));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.09)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.neonGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.location_on, color: AppTheme.neonGreen, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: AppTheme.textWhite, fontSize: 14, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: AppTheme.textGray, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
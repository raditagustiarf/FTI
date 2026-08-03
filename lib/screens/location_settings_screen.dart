import 'package:flutter/material.dart';
import '../core/theme.dart';
import 'pick_location_screen.dart'; 

class LocationSettingsScreen extends StatefulWidget {
  const LocationSettingsScreen({super.key});

  @override
  State<LocationSettingsScreen> createState() => _LocationSettingsScreenState();
}

class _LocationSettingsScreenState extends State<LocationSettingsScreen> {
  bool isLocationShared = true; 

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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. KARTU VISIBILITAS TOKO
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
                            // Custom Toggle Switch
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

                  // 2. DETAIL & PATOKAN LOKASI
                  const Text('DETAIL & PATOKAN LOKASI', style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  const SizedBox(height: 12),
                  
                  // Map Placeholder (Tentukan titik lokasi)
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const PickLocationScreen()));
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
                            width: 36, height: 36,
                            decoration: BoxDecoration(color: AppTheme.neonGreen, shape: BoxShape.circle, boxShadow: [BoxShadow(color: AppTheme.neonGreen.withOpacity(0.5), blurRadius: 25)]),
                            child: const Icon(Icons.location_on, color: Colors.black, size: 18),
                          ),
                          Positioned(
                            bottom: 12, left: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(8)),
                              child: const Text('Tentukan titik lokasi →', style: TextStyle(color: Colors.white70, fontSize: 9)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Input Patokan Alamat
                  const Text('Patokan Alamat', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.045),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.14)),
                    ),
                    // PERBAIKAN: const dihapus dari TextField ini
                    child: TextField(
                      maxLines: 3,
                      style: const TextStyle(color: AppTheme.textWhite, fontSize: 12),
                      decoration: const InputDecoration(
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
          
          // Tombol Simpan (Sticky Bawah)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1)))),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
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
import 'package:flutter/material.dart';
import '../core/theme.dart';
import 'home_screen.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  
  // Controller untuk efek transisi layar yang smooth
  late AnimationController _fadeController;

  final List<Widget> _screens = const [
    HomeScreen(),
    ChatScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Mengatur kecepatan efek transisi (250 milidetik)
    _fadeController = AnimationController(
      vsync: this, 
      duration: const Duration(milliseconds: 250),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  // Fungsi untuk menangani perpindahan tab dengan animasi
  void _onTabTapped(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
      // Mengulang animasi pudar (fade) setiap kali pindah tab
      _fadeController.reset();
      _fadeController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      extendBody: true, // Agar konten (seperti peta) bisa memanjang ke bawah navigasi
      
      // Menggabungkan FadeTransition dengan IndexedStack
      body: FadeTransition(
        opacity: _fadeController,
        child: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
      ),
      
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
        height: 60,
        decoration: BoxDecoration(
          color: const Color(0xD81B1A1A), // Warna transparan gelap
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(
              activeIcon: Icons.map,
              inactiveIcon: Icons.map_outlined,
              label: 'Map',
              index: 0,
            ),
            _buildNavItem(
              activeIcon: Icons.chat_bubble,
              inactiveIcon: Icons.chat_bubble_outline,
              label: 'Pesan',
              index: 1,
            ),
            _buildNavItem(
              activeIcon: Icons.person,
              inactiveIcon: Icons.person_outline,
              label: 'Profil',
              index: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData activeIcon,
    required IconData inactiveIcon,
    required String label,
    required int index,
  }) {
    final isActive = _currentIndex == index;
    
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      behavior: HitTestBehavior.opaque, // Area klik lebih luas
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animasi transisi ikon membesar & berubah warna
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
              child: Icon(
                isActive ? activeIcon : inactiveIcon,
                key: ValueKey<bool>(isActive),
                size: isActive ? 22 : 20,
                color: isActive ? AppTheme.neonGreen : Colors.white54,
              ),
            ),
            const SizedBox(height: 4),
            // Animasi halus pada perubahan warna teks
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: isActive ? AppTheme.neonGreen : Colors.white54,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                fontFamily: 'Inter',
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
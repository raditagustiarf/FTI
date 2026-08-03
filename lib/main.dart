import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'screens/main_navigation.dart'; // Import file baru kita

void main() {
  runApp(const NeighborhoodApp());
}

class NeighborhoodApp extends StatelessWidget {
  const NeighborhoodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tetangga Market',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainNavigation(), // Ganti menjadi MainNavigation
    );
  }
}
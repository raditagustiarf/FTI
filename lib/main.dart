import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 

import 'core/theme.dart';
import 'screens/splash_screen.dart';

// Mendaftarkan semua "Otak" (Provider) aplikasi
import 'providers/catalog_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/review_provider.dart';
import 'providers/notification_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://japuyrvuxchvatrbyfwa.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImphcHV5cnZ1eGNodmF0cmJ5ZndhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODU4OTEwMTksImV4cCI6MjEwMTQ2NzAxOX0.CnqXAr6BssDCd6uZKb_oO3ctHVtcDOoBpahuRgVdpnc',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CatalogProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()), // <-- Mesin Notifikasi
      ],
      child: const NeighborhoodApp(),
    ),
  );
}

class NeighborhoodApp extends StatelessWidget {
  const NeighborhoodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tetangga Market',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}
# LOKIT (Lokal & Kita) 🛒📍

LOKIT adalah aplikasi mobile *hyperlocal marketplace* yang dirancang untuk memberdayakan UMKM rumahan dengan menjunjung tinggi privasi data. Dikembangkan khusus untuk kompetisi **FTI FEST 2026 (Mobile App Development)** pada **Subtema 5: Inovasi Mobile untuk Perlindungan Data Komunitas dan Lingkungan**.

LOKIT memungkinkan penjual untuk mempromosikan barang/jasa di peta interaktif kepada tetangga sekitar, dilengkapi dengan fitur *Dynamic Location Privacy Switch* di mana penjual memiliki wewenang penuh untuk menyembunyikan titik koordinat rumahnya saat toko sedang tutup.

---

## 🛠️ Teknologi yang Digunakan
Sistem ini dibangun menggunakan arsitektur modern dan efisien:
*   **Frontend Mobile:** Flutter (Dart) - Cross-platform UI Toolkit.
*   **Backend & Database:** Supabase (PostgreSQL) - Backend-as-a-Service untuk autentikasi, database relasional, dan penyimpanan gambar (Storage).
*   **Real-time Engine:** Supabase Realtime (WebSockets) - Untuk fitur sinkronisasi *Live Chat* dan Notifikasi.
*   **Maps & Geocoding:** FlutterMap, Geolocator, dan OpenStreetMap (OSM) API - Untuk merender peta dan mendeteksi lokasi presisi pengguna.
*   **State Management:** Provider - Mengelola *state* katalog, *chat*, ulasan, dan notifikasi secara global.

---

## 📂 Struktur Project
Aplikasi ini menerapkan pemisahan logika (separation of concerns) untuk menjaga kerapian dan skalabilitas *source code*:

```text
lokit/
│
├── android/                   # File sistem konfigurasi Android (AndroidManifest.xml)
├── assets/                    # Aset statis aplikasi (logo.png)
├── lib/
│   ├── core/                  # Konfigurasi inti dan tema aplikasi (AppTheme)
│   ├── providers/             # State Management (Logika bisnis & koneksi ke Supabase)
│   │   ├── catalog_provider.dart
│   │   ├── chat_provider.dart
│   │   ├── notification_provider.dart
│   │   └── review_provider.dart
│   ├── screens/               # Kumpulan antarmuka/layar (UI)
│   │   ├── account_settings_screen.dart
│   │   ├── add_product_screen.dart
│   │   ├── chat_screen.dart
│   │   ├── chat_detail_screen.dart
│   │   ├── home_screen.dart
│   │   ├── location_settings_screen.dart
│   │   ├── login_screen.dart
│   │   ├── main_navigation.dart
│   │   ├── manage_catalog_screen.dart
│   │   ├── notifications_screen.dart
│   │   ├── pick_location_screen.dart
│   │   ├── profile_screen.dart
│   │   ├── register_screen.dart
│   │   ├── reviews_screen.dart
│   │   ├── search_screen.dart
│   │   └── splash_screen.dart
│   └── main.dart              # Titik masuk utama aplikasi (Entry point)
│
├── pubspec.yaml               # Daftar dependensi package Flutter
└── README.md                  # Dokumentasi proyek
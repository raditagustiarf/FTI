import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/theme.dart';
import '../providers/notification_provider.dart';
import 'chat_detail_screen.dart'; 
import 'reviews_screen.dart';     

String getInitials(String name) {
  if (name.isEmpty) return '?';
  final parts = name.trim().split(' ');
  if (parts.length > 1) {
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
  return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationProvider>(context, listen: false).markAllAsRead();
    });
  }

  String _formatTime(String isoTime) {
    final time = DateTime.parse(isoTime);
    final difference = DateTime.now().difference(time);
    
    if (difference.inMinutes < 60) return '${difference.inMinutes} menit lalu';
    if (difference.inHours < 24) return '${difference.inHours} jam lalu';
    return '${difference.inDays} hari lalu';
  }

  Future<void> _handleNotificationClick(Map<String, dynamic> notif) async {
    final type = notif['type'];
    final referenceId = notif['reference_id'];
    if (referenceId == null) return; 

    showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator(color: AppTheme.neonGreen)));

    try {
      if (type == 'chat') {
        final response = await _supabase.from('profiles').select('full_name').eq('id', referenceId).maybeSingle();
        final partnerName = response?['full_name'] ?? 'Pengguna';
        
        if (mounted) {
          Navigator.pop(context); 
          Navigator.push(context, MaterialPageRoute(builder: (context) => ChatDetailScreen(partnerId: referenceId, partnerName: partnerName, partnerInitials: getInitials(partnerName))));
        }
      } 
      else if (type == 'review') {
        final myId = _supabase.auth.currentUser!.id;
        final myProfile = await _supabase.from('profiles').select('full_name, rating, review_count').eq('id', myId).maybeSingle();
        
        if (mounted) {
          Navigator.pop(context); 
          Navigator.push(context, MaterialPageRoute(builder: (context) => ReviewsScreen(sellerId: myId, sellerName: myProfile?['full_name'] ?? 'Toko Saya', currentRating: (myProfile?['rating'] ?? 0.0).toDouble(), reviewCount: (myProfile?['review_count'] ?? 0).toInt())));
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); 
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal membuka: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBackground,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white70), onPressed: () => Navigator.pop(context)),
        title: const Text('Notifikasi', style: TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.bold, fontSize: 17)),
        centerTitle: false,
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          final notifs = provider.notifications;

          if (notifs.isEmpty) {
            return RefreshIndicator(
              color: AppTheme.neonGreen, backgroundColor: AppTheme.glassBackground,
              onRefresh: () async => await provider.fetchNotifications(),
              child: ListView(
                children: const [
                  SizedBox(height: 300),
                  Center(child: Text('Belum ada notifikasi.', style: TextStyle(color: Colors.white54))),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppTheme.neonGreen, backgroundColor: AppTheme.glassBackground,
            onRefresh: () async => await provider.fetchNotifications(),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              itemCount: notifs.length,
              itemBuilder: (context, index) {
                final n = notifs[index];
                final isChat = n['type'] == 'chat';
                final icon = isChat ? Icons.chat_bubble : Icons.star;
                final color = isChat ? AppTheme.neonGreen : const Color(0xFFFFD700);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Dismissible(
                    key: Key(n['id'].toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(16)),
                      alignment: Alignment.centerRight,
                      child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
                    ),
                    onDismissed: (direction) {
                      provider.deleteNotification(n['id']);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notifikasi dihapus'), duration: Duration(seconds: 1)));
                    },
                    child: GestureDetector(
                      onTap: () => _handleNotificationClick(n),
                      child: _buildNotificationItem(
                        icon: icon, iconColor: color, title: n['title'],
                        message: n['message'], time: _formatTime(n['created_at']), isUnread: n['is_read'] == false, 
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }
      ),
    );
  }

  Widget _buildNotificationItem({
    required IconData icon, required Color iconColor, required String title, 
    required String message, required String time, required bool isUnread,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnread ? Colors.white.withOpacity(0.08) : const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isUnread ? AppTheme.neonGreen.withOpacity(0.3) : Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: iconColor.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: TextStyle(color: AppTheme.textWhite, fontSize: 14, fontWeight: isUnread ? FontWeight.bold : FontWeight.w600)),
                    if (isUnread) Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppTheme.neonGreen, shape: BoxShape.circle)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(message, style: TextStyle(color: isUnread ? Colors.white70 : AppTheme.textGray, fontSize: 12, height: 1.4)),
                const SizedBox(height: 8),
                Text(time, style: const TextStyle(color: Colors.white38, fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
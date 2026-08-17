import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationProvider with ChangeNotifier {
  final _supabase = Supabase.instance.client;
  
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = false;
  RealtimeChannel? _notifSubscription;

  List<Map<String, dynamic>> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => n['is_read'] == false).length;

  NotificationProvider() {
    fetchNotifications();
    _setupRealtime();
  }

  void _setupRealtime() {
    _notifSubscription = _supabase
        .channel('public:notifications')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          callback: (payload) => fetchNotifications(), 
        )
        .subscribe();
  }

  Future<void> fetchNotifications() async {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', myId)
          .order('created_at', ascending: false);
          
      _notifications = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error tarik notifikasi: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> markAllAsRead() async {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null || unreadCount == 0) return;

    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', myId)
          .eq('is_read', false);
          
      await fetchNotifications(); 
    } catch (e) {
      debugPrint('Error update is_read: $e');
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      await _supabase.from('notifications').delete().eq('id', id);
      _notifications.removeWhere((n) => n['id'] == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error hapus notifikasi: $e');
    }
  }

  @override
  void dispose() {
    _supabase.removeChannel(_notifSubscription!);
    super.dispose();
  }
}
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Message {
  final String id;
  final String senderId;
  final String receiverId; // <-- PERBAIKAN: Menambahkan kolom penerima
  final String content;
  final DateTime createdAt;

  Message({required this.id, required this.senderId, required this.receiverId, required this.content, required this.createdAt});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'].toString(),
      senderId: json['sender_id'].toString(),
      receiverId: json['receiver_id'].toString(), // <-- PERBAIKAN: Merekam penerima
      content: json['content'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class ChatProvider with ChangeNotifier {
  final _supabase = Supabase.instance.client;
  List<Message> _messages = [];
  RealtimeChannel? _messageSubscription; 

  List<Message> get messages => _messages;

  void listenToMessages(String partnerId) {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) return;

    _fetchMessages(myId, partnerId); 

    _messageSubscription = _supabase
        .channel('public:messages')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          callback: (payload) {
             _fetchMessages(myId, partnerId); 
          },
        )
        .subscribe();
  }

  Future<void> _fetchMessages(String myId, String partnerId) async {
    try {
      debugPrint('Menarik pesan untuk: $myId dan $partnerId');
      
      // PERBAIKAN: Tarik semua pesan kita, lalu saring di aplikasi agar tidak ada error sintaks database
      final response = await _supabase
          .from('messages')
          .select()
          .or('sender_id.eq.$myId,receiver_id.eq.$myId')
          .order('created_at', ascending: true);
      
      final allMsgs = (response as List).map((e) => Message.fromJson(e)).toList();
      
      // Saring hanya pesan antara kita dan si Penjual
      _messages = allMsgs.where((m) => 
        (m.senderId == myId && m.receiverId == partnerId) || 
        (m.senderId == partnerId && m.receiverId == myId)
      ).toList();
      
      debugPrint('Berhasil menemukan ${_messages.length} pesan dengan partner ini.');
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetch pesan: $e');
    }
  }

  Future<void> sendMessage(String receiverId, String content) async {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null || content.trim().isEmpty) return;

    try {
      await _supabase.from('messages').insert({
        'sender_id': myId,
        'receiver_id': receiverId,
        'content': content.trim(),
      });
      
      debugPrint('Pesan terkirim ke DB, menarik ulang data...');
      await _fetchMessages(myId, receiverId);
      
    } catch (e) {
      debugPrint('Error kirim pesan: $e');
      rethrow;
    }
  }

  void disposeStream() {
    if (_messageSubscription != null) {
      _supabase.removeChannel(_messageSubscription!);
    }
  }
}
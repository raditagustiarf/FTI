import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/theme.dart';
import 'chat_detail_screen.dart';

String getInitials(String name) {
  if (name.isEmpty) return '?';
  final parts = name.trim().split(' ');
  if (parts.length > 1) {
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
  return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _chatRooms = [];
  bool _isLoading = true;
  RealtimeChannel? _inboxSubscription;

  // ==========================================
  // BARU: Penampung Kata Kunci Pencarian
  // ==========================================
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchChatRooms();
    _setupRealtimeInbox();
  }

  void _setupRealtimeInbox() {
    _inboxSubscription = _supabase
        .channel('public:messages_inbox')
        .onPostgresChanges(
          event: PostgresChangeEvent.all, 
          schema: 'public',
          table: 'messages',
          callback: (payload) {
             _fetchChatRooms(); 
           },
        )
        .subscribe();
  }

  @override
  void dispose() {
    if (_inboxSubscription != null) {
      _supabase.removeChannel(_inboxSubscription!);
    }
    super.dispose();
  }

  Future<void> _fetchChatRooms() async {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) return;

    try {
      final response = await _supabase
          .from('messages')
          .select('sender_id, receiver_id, content, created_at, is_read, sender:profiles!messages_sender_id_fkey(full_name), receiver:profiles!messages_receiver_id_fkey(full_name)')
          .or('sender_id.eq.$myId,receiver_id.eq.$myId')
          .order('created_at', ascending: false);

      final Map<String, Map<String, dynamic>> uniqueRooms = {};

      for (var msg in response as List) {
        final isMeSender = msg['sender_id'] == myId;
        final partnerId = isMeSender ? msg['receiver_id'] : msg['sender_id'];
        
        String partnerName = 'Pengguna';
        if (isMeSender && msg['receiver'] != null) {
          partnerName = msg['receiver']['full_name'] ?? 'Pengguna';
        } else if (!isMeSender && msg['sender'] != null) {
          partnerName = msg['sender']['full_name'] ?? 'Pengguna';
        }

        if (!uniqueRooms.containsKey(partnerId)) {
          uniqueRooms[partnerId] = {
            'partnerId': partnerId,
            'partnerName': partnerName,
            'lastMessage': msg['content'],
            'time': _formatTime(DateTime.parse(msg['created_at'])),
            'unreadCount': 0, 
          };
        }

        if (!isMeSender && msg['is_read'] == false) {
          uniqueRooms[partnerId]!['unreadCount'] = (uniqueRooms[partnerId]!['unreadCount'] as int) + 1;
        }
      }

      if (mounted) {
        setState(() {
          _chatRooms = uniqueRooms.values.toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetch chat rooms: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteChat(String partnerId) async {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) return;
    
    try {
      await _supabase.from('messages').delete().match({
        'sender_id': myId,
        'receiver_id': partnerId
      });
      
      await _supabase.from('messages').delete().match({
        'sender_id': partnerId,
        'receiver_id': myId
      });

      _fetchChatRooms(); 
      
    } catch (e) {
      debugPrint('Error delete chat: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus di server: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inDays == 0 && now.day == time.day) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1 || (difference.inDays == 0 && now.day != time.day)) {
      return 'Kemarin';
    } else {
      return '${difference.inDays} hr lalu';
    }
  }

  @override
  Widget build(BuildContext context) {
    // ==========================================
    // BARU: Logika Penyaring Chat (Filter/Search)
    // ==========================================
    final filteredRooms = _chatRooms.where((room) {
      final query = _searchQuery.toLowerCase();
      final nameMatch = room['partnerName'].toString().toLowerCase().contains(query);
      final msgMatch = room['lastMessage'].toString().toLowerCase().contains(query);
      return nameMatch || msgMatch;
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBackground,
        elevation: 0,
        title: const Text(
          'Pesan', 
          style: TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.bold, fontSize: 24, letterSpacing: -1.0)
        ),
        centerTitle: false,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppTheme.neonGreen))
        : RefreshIndicator(
            color: AppTheme.neonGreen,
            backgroundColor: AppTheme.glassBackground,
            onRefresh: _fetchChatRooms,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              children: [
                // ==========================================
                // BARU: Kolom Pencarian Yang Berfungsi (TextField)
                // ==========================================
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.white38, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          style: const TextStyle(color: AppTheme.textWhite, fontSize: 13),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value; // Update kata kunci saat diketik
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Cari pesan atau nama tetangga...', 
                            hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            // Munculkan tombol silang (X) jika ada teks
                            suffixIcon: _searchQuery.isNotEmpty 
                              ? GestureDetector(
                                  onTap: () {
                                    FocusScope.of(context).unfocus();
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                  child: const Icon(Icons.close, color: Colors.white38, size: 16),
                                )
                              : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                if (_chatRooms.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Center(
                      child: Text(
                        'Belum ada riwayat pesan.\nMulai chat penjual lewat Katalog!', 
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white54, height: 1.5)
                      ),
                    ),
                  )
                else if (filteredRooms.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Center(
                      child: Text(
                        'Pencarian tidak ditemukan.', 
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white54, height: 1.5)
                      ),
                    ),
                  )
                else
                  ...filteredRooms.map((room) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Dismissible(
                        key: Key(room['partnerId']),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(25)),
                          child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
                        ),
                        confirmDismiss: (direction) async {
                          return await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: AppTheme.glassBackground,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.white12)),
                                title: const Text("Hapus Obrolan?", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                                content: Text("Semua pesan dengan ${room['partnerName']} akan dihapus permanen.", style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5)),
                                actions: [
                                  TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text("Batal", style: TextStyle(color: Colors.white54))),
                                  ElevatedButton(
                                    onPressed: () => Navigator.of(context).pop(true), 
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                                    child: const Text("Hapus", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        onDismissed: (direction) {
                          setState(() {
                            _chatRooms.removeWhere((r) => r['partnerId'] == room['partnerId']);
                          });
                          _deleteChat(room['partnerId']);
                        },
                        child: _buildChatItem(
                          context: context,
                          partnerId: room['partnerId'], 
                          name: room['partnerName'],
                          message: room['lastMessage'],
                          time: room['time'],
                          initials: getInitials(room['partnerName']),
                          unreadCount: room['unreadCount'], 
                          isOnline: false, 
                        ),
                      ),
                    );
                  }),
              ],
            ),
          ),
    );
  }

  Widget _buildChatItem({
    required BuildContext context, required String partnerId, required String name, required String message,
    required String time, required String initials, required int unreadCount, required bool isOnline,
  }) {
    final hasUnread = unreadCount > 0;
    
    return GestureDetector(
      onTap: () async {
        final myId = _supabase.auth.currentUser?.id;
        
        if (hasUnread) {
          setState(() {
            final index = _chatRooms.indexWhere((r) => r['partnerId'] == partnerId);
            if (index != -1) {
              _chatRooms[index]['unreadCount'] = 0; 
            }
          });
          if (myId != null) {
            try {
              await _supabase.from('messages').update({'is_read': true}).eq('sender_id', partnerId).eq('receiver_id', myId);
            } catch (e) {
              debugPrint('Gagal menandai pesan telah dibaca: $e');
            }
          }
        }

        if (context.mounted) {
          await Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => ChatDetailScreen(partnerId: partnerId, partnerName: name, partnerInitials: initials))
          );
          _fetchChatRooms(); 
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 52, height: 52,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFE7B48E), Color(0xFF925B44)]),
                ),
                child: Center(child: Text(initials, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16))),
              ),
              if (isOnline)
                Positioned(
                  right: 0, bottom: 0,
                  child: Container(
                    width: 14, height: 14,
                    decoration: BoxDecoration(color: AppTheme.neonGreen, shape: BoxShape.circle, border: Border.all(color: AppTheme.darkBackground, width: 2)),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(name, style: TextStyle(color: AppTheme.textWhite, fontSize: 15, fontWeight: hasUnread ? FontWeight.bold : FontWeight.w600)),
                    Text(time, style: TextStyle(color: hasUnread ? AppTheme.neonGreen : Colors.white38, fontSize: 11, fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        message, 
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: hasUnread ? Colors.white : AppTheme.textGray, fontSize: 13)
                      ),
                    ),
                    if (hasUnread)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(color: AppTheme.neonGreen, borderRadius: BorderRadius.circular(10)),
                        child: Text(unreadCount > 99 ? '99+' : unreadCount.toString(), style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
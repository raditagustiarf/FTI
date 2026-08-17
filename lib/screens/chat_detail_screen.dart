import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/theme.dart';
import '../providers/chat_provider.dart';

class ChatDetailScreen extends StatefulWidget {
  final String partnerId;
  final String partnerName;
  final String partnerInitials;

  const ChatDetailScreen({
    super.key, 
    required this.partnerId, 
    required this.partnerName,
    required this.partnerInitials,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  late ChatProvider _chatProvider; 

  @override
  void initState() {
    super.initState();
    
    _chatProvider = Provider.of<ChatProvider>(context, listen: false);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chatProvider.listenToMessages(widget.partnerId);
    });
  }

  @override
  void dispose() {
    _chatProvider.disposeStream();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatData = Provider.of<ChatProvider>(context);
    
    final myUserId = Supabase.instance.client.auth.currentUser?.id;
    
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),

            // AREA PESAN
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(20),
                itemCount: chatData.messages.length,
                itemBuilder: (context, index) {
                  final msg = chatData.messages[index];
                  final isMe = msg.senderId == myUserId;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _ChatBubble(message: msg.content, isMe: isMe),
                  );
                },
              ),
            ),

            _buildMessageInput(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xBF151414), 
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.arrow_back, color: Colors.white60, size: 22),
            ),
          ),
          Container(
            width: 36, height: 36,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [Color(0xFFE7B48E), Color(0xFF925B44)]),
            ),
            child: Center(child: Text(widget.partnerInitials, style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.partnerName, style: const TextStyle(color: AppTheme.textWhite, fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                const Text('● Online', style: TextStyle(color: AppTheme.neonGreen, fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.darkBackground, border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1)))),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.14)),
              ),
              child: TextField(
                controller: _messageController,
                style: const TextStyle(color: AppTheme.textWhite, fontSize: 13),
                decoration: const InputDecoration(
                  hintText: 'Tulis pesan...', hintStyle: TextStyle(color: Colors.white38, fontSize: 13), border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onSubmitted: (_) => _sendMessage(context),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _sendMessage(context),
            child: Container(
              height: 44, width: 44,
              decoration: BoxDecoration(color: AppTheme.neonGreen, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.send, color: Colors.black, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(BuildContext context) async {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      _messageController.clear(); 
      try {
        await _chatProvider.sendMessage(widget.partnerId, text);
        _scrollToBottom(); 
      } catch (e) {
        _messageController.text = text;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal mengirim pesan: $e'), backgroundColor: Colors.redAccent),
          );
        }
      }
    }
  }
}

class _ChatBubble extends StatelessWidget {
  final String message;
  final bool isMe;

  const _ChatBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(left: isMe ? 60 : 0, right: isMe ? 0 : 60),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isMe ? AppTheme.neonGreen : const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
            bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2)),
          ]
        ),
        child: Text(
          message, 
          style: TextStyle(
            color: isMe ? Colors.black : Colors.white, 
            fontSize: 13, 
            height: 1.4,
            fontWeight: isMe ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
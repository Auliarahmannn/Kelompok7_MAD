import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:campgear/services/chat_service.dart';
import 'package:campgear/services/auth_service.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();

  // ID customer yang sedang login. Kita anggap 'admin' adalah ID tetap.
  String? _customerUserId;

  bool _isLoading = true; // Untuk loading ID user

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  // Ambil ID user yang sedang login
  Future<void> _loadCurrentUser() async {
    final userId = await AuthService.getUserId();
    setState(() {
      _customerUserId = userId?.toString();
      _isLoading = false;
    });
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty && _customerUserId != null) {
      _chatService.sendMessage(
        customerUserId: _customerUserId!,
        text: _messageController.text,
        senderId: _customerUserId!, // Pengirim adalah customer
      );
      _messageController.clear();
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF597E52),
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            ClipOval(
              child: Image.asset(
                'assets/images/logo.png',
                width: 46, 
                height: 46,
                fit: BoxFit.contain, 
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Admin Support',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          _buildMessageInput(),
        ],
      ),
    );
  }

  // Widget untuk menampilkan daftar pesan
  Widget _buildMessageList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_customerUserId == null) {
      return const Center(
        child: Text("Gagal memuat ID user. Silakan login ulang."),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _chatService.getMessagesStream(customerUserId: _customerUserId!),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final messages = snapshot.data?.docs ?? [];

        if (messages.isEmpty) {
          return const Center(
            child: Text("Mulai percakapan Anda dengan Admin!"),
          );
        }

        return ListView.builder(
          reverse: true, // Agar chat mulai dari bawah
          itemCount: messages.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final doc = messages[index];
            final data = doc.data() as Map<String, dynamic>;

            // Tentukan apakah pengirim adalah customer (user ini) atau admin
            final bool isMe = data['senderId'] == _customerUserId;

            return _buildMessageBubble(data['text'], isMe);
          },
        );
      },
    );
  }

  // Widget untuk satu gelembung chat
  Widget _buildMessageBubble(String text, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF5D7F5F) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(color: isMe ? Colors.white : Colors.black87),
        ),
      ),
    );
  }

  // Widget untuk input teks
  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: 'Ketik pesan...',
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send, color: Colors.green),
              onPressed: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}

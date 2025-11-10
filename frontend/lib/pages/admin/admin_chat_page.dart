import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:campgear/services/chat_service.dart'; 

class AdminChatPage extends StatefulWidget {
  // Halaman ini Menerima ID & Nama Customer yang akan di-chat
  final String customerUserId;
  final String customerName;

  const AdminChatPage({
    super.key,
    required this.customerUserId,
    required this.customerName,
  });

  @override
  State<AdminChatPage> createState() => _AdminChatPageState();
}

class _AdminChatPageState extends State<AdminChatPage> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();

  // ID Admin kita buat statis "admin"
  final String _adminId = 'admin';

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      _chatService.sendMessage(
        // 1. Tentukan chat room (berdasarkan ID customer)
        customerUserId: widget.customerUserId,
        
        // 2. Isi pesan
        text: _messageController.text,
        
        // 3. Pengirimnya adalah ADMIN
        senderId: _adminId, 
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
  automaticallyImplyLeading: true,
  title: Row(
    children: [
      // Avatar dengan style seperti di profil
      Stack(
        alignment: Alignment.center,
        children: [
          const CircleAvatar(
            radius: 18, // lingkaran luar putih
            backgroundColor: Colors.white,
          ),
          CircleAvatar(
            radius: 17, // lingkaran dalam hijau
            backgroundColor: const Color(0xFF5D7F5F),
            child: Text(
              widget.customerName.isNotEmpty
                  ? widget.customerName[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(width: 10),
      // Nama customer
      Text(
        widget.customerName,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  ),
  iconTheme: const IconThemeData(color: Colors.white),
),

      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  // Widget untuk menampilkan daftar pesan
  Widget _buildMessageList() {
    return StreamBuilder<QuerySnapshot>(
      // Ambil stream pesan untuk customer ID yang spesifik
      stream: _chatService.getMessagesStream(customerUserId: widget.customerUserId),
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
            child: Text("Belum ada percakapan."),
          );
        }

        return ListView.builder(
          reverse: true, // Chat mulai dari bawah
          itemCount: messages.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final doc = messages[index];
            final data = doc.data() as Map<String, dynamic>;
            
            // Logika 'isMe' dibalik: "isMe" == true jika pengirimnya adalah Admin
            final bool isMe = data['senderId'] == _adminId;

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
              color: Colors.black.withOpacity(0.05),
              blurRadius: 3,
              offset: const Offset(0, 1),
            )
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isMe ? Colors.white : Colors.black87,
          ),
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
            color: Colors.grey.withOpacity(0.2),
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
                  hintText: 'Ketik balasan...',
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
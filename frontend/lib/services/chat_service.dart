import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Struktur Data:
  // /chats (collection)
  //   / {customer_user_id} (document)
  //      / messages (collection)
  //         / {message_id} (document)
  //            - text
  //            - senderId
  //            - timestamp

  /// Mengirim pesan
  Future<void> sendMessage({
    required String customerUserId, // ID user customer
    required String text,
    required String senderId, // Bisa 'admin' atau customerUserId
  }) async {
    if (text.trim().isEmpty) return;

    final messageData = {
      'text': text,
      'senderId': senderId,
      'timestamp': FieldValue.serverTimestamp(), // Otomatis
    };

    // Dapatkan referensi ke koleksi pesan
    final chatRoomRef = _firestore
        .collection('chats')
        .doc(customerUserId)
        .collection('messages');

    // Tambahkan pesan baru
    await chatRoomRef.add(messageData);
  }

  /// Mendapatkan stream/aliran pesan (real-time)
  Stream<QuerySnapshot> getMessagesStream({required String customerUserId}) {
    return _firestore
        .collection('chats')
        .doc(customerUserId)
        .collection('messages')
        .orderBy('timestamp', descending: true) // Pesan terbaru di bawah
        .snapshots();
  }
}
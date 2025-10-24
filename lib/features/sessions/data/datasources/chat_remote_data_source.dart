import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eservelink/features/sessions/data/models/chat_message_model.dart';
import 'package:eservelink/features/sessions/domain/entities/chat_message_entity.dart';

abstract class ChatRemoteDataSource {
  Future<void> sendMessage({
    required String sessionId,
    required String senderId,
    required String senderName,
    required MessageType senderType,
    required String message,
  });

  Future<List<ChatMessageModel>> getChatMessages(String sessionId);
  Stream<List<ChatMessageModel>> streamChatMessages(String sessionId);
  Future<void> markMessageAsRead(String messageId);
  Future<int> getUnreadCount(String sessionId, String userId);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final FirebaseFirestore firestore;

  ChatRemoteDataSourceImpl({required this.firestore});

  @override
  Future<void> sendMessage({
    required String sessionId,
    required String senderId,
    required String senderName,
    required MessageType senderType,
    required String message,
  }) async {
    try {
      await firestore.collection('chat_messages').add({
        'sessionId': sessionId,
        'senderId': senderId,
        'senderName': senderName,
        'senderType': _messageTypeToString(senderType),
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  @override
  Future<List<ChatMessageModel>> getChatMessages(String sessionId) async {
    try {
      final querySnapshot =
          await firestore
              .collection('chat_messages')
              .where('sessionId', isEqualTo: sessionId)
              .orderBy('timestamp', descending: false)
              .get();

      return querySnapshot.docs
          .map((doc) => ChatMessageModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get chat messages: $e');
    }
  }

  @override
  Stream<List<ChatMessageModel>> streamChatMessages(String sessionId) {
    return firestore
        .collection('chat_messages')
        .where('sessionId', isEqualTo: sessionId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => ChatMessageModel.fromFirestore(doc))
                  .toList(),
        );
  }

  @override
  Future<void> markMessageAsRead(String messageId) async {
    try {
      await firestore.collection('chat_messages').doc(messageId).update({
        'isRead': true,
      });
    } catch (e) {
      throw Exception('Failed to mark message as read: $e');
    }
  }

  @override
  Future<int> getUnreadCount(String sessionId, String userId) async {
    try {
      final querySnapshot =
          await firestore
              .collection('chat_messages')
              .where('sessionId', isEqualTo: sessionId)
              .where('isRead', isEqualTo: false)
              .where('senderId', isNotEqualTo: userId)
              .get();

      return querySnapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to get unread count: $e');
    }
  }

  String _messageTypeToString(MessageType type) {
    switch (type) {
      case MessageType.customer:
        return 'customer';
      case MessageType.waiter:
        return 'waiter';
      case MessageType.system:
        return 'system';
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/features/chat/data/models/message_model.dart';

abstract class ChatRemoteDataSource {
  Future<MessageModel> sendMessage({
    required String sessionId,
    required String senderId,
    required String senderName,
    required String senderRole,
    required String text,
  });

  Stream<List<MessageModel>> streamMessages({required String sessionId});

  Future<void> markMessagesAsRead({
    required String sessionId,
    required String userId,
  });

  Future<void> sendTypingIndicator({
    required String sessionId,
    required String userId,
    required bool isTyping,
  });

  Stream<Map<String, bool>> streamTypingIndicators({required String sessionId});

  Future<int> getUnreadCount({
    required String sessionId,
    required String userId,
  });
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final FirebaseFirestore firestore;

  ChatRemoteDataSourceImpl({required this.firestore});

  @override
  Future<MessageModel> sendMessage({
    required String sessionId,
    required String senderId,
    required String senderName,
    required String senderRole,
    required String text,
  }) async {
    try {
      // Create message document
      final messageRef =
          firestore
              .collection('sessions')
              .doc(sessionId)
              .collection('messages')
              .doc();

      final messageData = {
        'sessionId': sessionId,
        'senderId': senderId,
        'senderName': senderName,
        'senderRole': senderRole,
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      };

      await messageRef.set(messageData);

      // Get the created message with server timestamp
      final doc = await messageRef.get();
      final message = MessageModel.fromFirestore(doc);

      return message;
    } catch (e) {
      throw ServerFailure('Failed to send message: $e');
    }
  }

  @override
  Stream<List<MessageModel>> streamMessages({required String sessionId}) {
    return firestore
        .collection('sessions')
        .doc(sessionId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => MessageModel.fromFirestore(doc))
              .toList();
        });
  }

  @override
  Future<void> markMessagesAsRead({
    required String sessionId,
    required String userId,
  }) async {
    try {
      // Get all unread messages NOT sent by this user
      final unreadMessages =
          await firestore
              .collection('sessions')
              .doc(sessionId)
              .collection('messages')
              .where('senderId', isNotEqualTo: userId)
              .where('isRead', isEqualTo: false)
              .get();

      // Batch update
      final batch = firestore.batch();
      for (var doc in unreadMessages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
    } catch (e) {
      throw ServerFailure('Failed to mark messages as read: $e');
    }
  }

  @override
  Future<void> sendTypingIndicator({
    required String sessionId,
    required String userId,
    required bool isTyping,
  }) async {
    try {
      // Store typing status in session's typing_indicators subcollection
      await firestore
          .collection('sessions')
          .doc(sessionId)
          .collection('typing_indicators')
          .doc(userId)
          .set({
            'isTyping': isTyping,
            'timestamp': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      throw ServerFailure('Failed to send typing indicator: $e');
    }
  }

  @override
  Stream<Map<String, bool>> streamTypingIndicators({
    required String sessionId,
  }) {
    return firestore
        .collection('sessions')
        .doc(sessionId)
        .collection('typing_indicators')
        .snapshots()
        .map((snapshot) {
          final Map<String, bool> indicators = {};
          for (var doc in snapshot.docs) {
            final data = doc.data();
            indicators[doc.id] = data['isTyping'] as bool? ?? false;
          }
          return indicators;
        });
  }

  @override
  Future<int> getUnreadCount({
    required String sessionId,
    required String userId,
  }) async {
    try {
      final unreadMessages =
          await firestore
              .collection('sessions')
              .doc(sessionId)
              .collection('messages')
              .where('senderId', isNotEqualTo: userId)
              .where('isRead', isEqualTo: false)
              .get();

      return unreadMessages.docs.length;
    } catch (e) {
      return 0;
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eservelink/features/sessions/domain/entities/chat_message_entity.dart';

class ChatMessageModel extends ChatMessageEntity {
  const ChatMessageModel({
    required super.id,
    required super.sessionId,
    required super.senderId,
    required super.senderName,
    required super.senderType,
    required super.message,
    required super.timestamp,
    required super.isRead,
  });

  // Convert from Firestore
  factory ChatMessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ChatMessageModel(
      id: doc.id,
      sessionId: data['sessionId'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      senderType: _messageTypeFromString(data['senderType'] ?? 'customer'),
      message: data['message'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      isRead: data['isRead'] ?? false,
    );
  }

  // Convert to Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'sessionId': sessionId,
      'senderId': senderId,
      'senderName': senderName,
      'senderType': _messageTypeToString(senderType),
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
    };
  }

  // Convert from entity
  factory ChatMessageModel.fromEntity(ChatMessageEntity entity) {
    return ChatMessageModel(
      id: entity.id,
      sessionId: entity.sessionId,
      senderId: entity.senderId,
      senderName: entity.senderName,
      senderType: entity.senderType,
      message: entity.message,
      timestamp: entity.timestamp,
      isRead: entity.isRead,
    );
  }

  static MessageType _messageTypeFromString(String type) {
    switch (type) {
      case 'customer':
        return MessageType.customer;
      case 'waiter':
        return MessageType.waiter;
      case 'system':
        return MessageType.system;
      default:
        return MessageType.customer;
    }
  }

  static String _messageTypeToString(MessageType type) {
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

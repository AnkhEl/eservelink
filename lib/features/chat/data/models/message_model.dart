import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eservelink/features/chat/domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    required super.sessionId,
    required super.senderId,
    required super.senderName,
    required super.senderRole,
    required super.text,
    required super.timestamp,
    super.isRead,
    super.imageUrl,
  });

  /// Create from Firestore DocumentSnapshot
  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return MessageModel(
      id: doc.id,
      sessionId: data['sessionId'] as String,
      senderId: data['senderId'] as String,
      senderName: data['senderName'] as String,
      senderRole: data['senderRole'] as String,
      text: data['text'] as String,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      isRead: data['isRead'] as bool? ?? false,
      imageUrl: data['imageUrl'] as String?,
    );
  }

  /// Create from Map
  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'] as String,
      sessionId: map['sessionId'] as String,
      senderId: map['senderId'] as String,
      senderName: map['senderName'] as String,
      senderRole: map['senderRole'] as String,
      text: map['text'] as String,
      timestamp:
          map['timestamp'] is Timestamp
              ? (map['timestamp'] as Timestamp).toDate()
              : DateTime.parse(map['timestamp'] as String),
      isRead: map['isRead'] as bool? ?? false,
      imageUrl: map['imageUrl'] as String?,
    );
  }

  /// Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'sessionId': sessionId,
      'senderId': senderId,
      'senderName': senderName,
      'senderRole': senderRole,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': isRead,
      'imageUrl': imageUrl,
    };
  }

  /// Convert from Entity
  factory MessageModel.fromEntity(MessageEntity entity) {
    return MessageModel(
      id: entity.id,
      sessionId: entity.sessionId,
      senderId: entity.senderId,
      senderName: entity.senderName,
      senderRole: entity.senderRole,
      text: entity.text,
      timestamp: entity.timestamp,
      isRead: entity.isRead,
      imageUrl: entity.imageUrl,
    );
  }

  /// Convert to Entity
  MessageEntity toEntity() {
    return MessageEntity(
      id: id,
      sessionId: sessionId,
      senderId: senderId,
      senderName: senderName,
      senderRole: senderRole,
      text: text,
      timestamp: timestamp,
      isRead: isRead,
      imageUrl: imageUrl,
    );
  }
}

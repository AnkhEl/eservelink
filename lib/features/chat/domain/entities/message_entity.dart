import 'package:equatable/equatable.dart';

class MessageEntity extends Equatable {
  final String id;
  final String sessionId;
  final String senderId;
  final String senderName;
  final String senderRole; // 'customer' or 'company_user'
  final String text;
  final DateTime timestamp;
  final bool isRead;
  final String? imageUrl; // Optional for future image support

  const MessageEntity({
    required this.id,
    required this.sessionId,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.text,
    required this.timestamp,
    this.isRead = false,
    this.imageUrl,
  });

  bool get isSentByCustomer => senderRole == 'customer';
  bool get isSentByWaiter => senderRole == 'company_user';

  @override
  List<Object?> get props => [
    id,
    sessionId,
    senderId,
    senderName,
    senderRole,
    text,
    timestamp,
    isRead,
    imageUrl,
  ];

  MessageEntity copyWith({
    String? id,
    String? sessionId,
    String? senderId,
    String? senderName,
    String? senderRole,
    String? text,
    DateTime? timestamp,
    bool? isRead,
    String? imageUrl,
  }) {
    return MessageEntity(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderRole: senderRole ?? this.senderRole,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

import 'package:equatable/equatable.dart';

class ChatMessageEntity extends Equatable {
  final String id;
  final String sessionId;
  final String senderId;
  final String senderName;
  final MessageType senderType;
  final String message;
  final DateTime timestamp;
  final bool isRead;

  const ChatMessageEntity({
    required this.id,
    required this.sessionId,
    required this.senderId,
    required this.senderName,
    required this.senderType,
    required this.message,
    required this.timestamp,
    required this.isRead,
  });

  @override
  List<Object?> get props => [
    id,
    sessionId,
    senderId,
    senderName,
    senderType,
    message,
    timestamp,
    isRead,
  ];
}

enum MessageType { customer, waiter, system }

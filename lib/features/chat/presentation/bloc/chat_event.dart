import 'package:equatable/equatable.dart';
import 'package:eservelink/features/chat/domain/entities/message_entity.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

/// Start listening to messages for a session
class StartListeningToMessagesEvent extends ChatEvent {
  final String sessionId;
  final String currentUserId;

  const StartListeningToMessagesEvent({
    required this.sessionId,
    required this.currentUserId,
  });

  @override
  List<Object?> get props => [sessionId, currentUserId];
}

/// Stop listening to messages
class StopListeningToMessagesEvent extends ChatEvent {}

/// Internal event when messages are updated from stream
class MessagesUpdatedEvent extends ChatEvent {
  final List<MessageEntity> messages;

  const MessagesUpdatedEvent(this.messages);

  @override
  List<Object?> get props => [messages];
}

/// Send a message
class SendMessageEvent extends ChatEvent {
  final String sessionId;
  final String senderId;
  final String senderName;
  final String senderRole;
  final String text;

  const SendMessageEvent({
    required this.sessionId,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.text,
  });

  @override
  List<Object?> get props => [
    sessionId,
    senderId,
    senderName,
    senderRole,
    text,
  ];
}

/// Mark messages as read
class MarkMessagesAsReadEvent extends ChatEvent {
  final String sessionId;
  final String userId;

  const MarkMessagesAsReadEvent({
    required this.sessionId,
    required this.userId,
  });

  @override
  List<Object?> get props => [sessionId, userId];
}

/// Send typing indicator
class SendTypingIndicatorEvent extends ChatEvent {
  final String sessionId;
  final String userId;
  final bool isTyping;

  const SendTypingIndicatorEvent({
    required this.sessionId,
    required this.userId,
    required this.isTyping,
  });

  @override
  List<Object?> get props => [sessionId, userId, isTyping];
}

/// Internal event when typing indicators are updated
class TypingIndicatorsUpdatedEvent extends ChatEvent {
  final Map<String, bool> indicators;

  const TypingIndicatorsUpdatedEvent(this.indicators);

  @override
  List<Object?> get props => [indicators];
}

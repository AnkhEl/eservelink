import 'package:equatable/equatable.dart';
import 'package:eservelink/features/chat/domain/entities/message_entity.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ChatInitial extends ChatState {}

/// Loading state
class ChatLoading extends ChatState {}

/// Messages loaded successfully
class ChatMessagesLoaded extends ChatState {
  final List<MessageEntity> messages;
  final Map<String, bool> typingIndicators;
  final String currentUserId;

  const ChatMessagesLoaded({
    required this.messages,
    this.typingIndicators = const {},
    required this.currentUserId,
  });

  @override
  List<Object?> get props => [messages, typingIndicators, currentUserId];

  /// Check if other user is typing
  bool isOtherUserTyping() {
    return typingIndicators.entries
        .where((entry) => entry.key != currentUserId)
        .any((entry) => entry.value);
  }

  /// Get unread message count
  int get unreadCount {
    return messages
        .where((msg) => msg.senderId != currentUserId && !msg.isRead)
        .length;
  }

  ChatMessagesLoaded copyWith({
    List<MessageEntity>? messages,
    Map<String, bool>? typingIndicators,
    String? currentUserId,
  }) {
    return ChatMessagesLoaded(
      messages: messages ?? this.messages,
      typingIndicators: typingIndicators ?? this.typingIndicators,
      currentUserId: currentUserId ?? this.currentUserId,
    );
  }
}

/// Message sent successfully
class ChatMessageSent extends ChatState {
  final MessageEntity message;

  const ChatMessageSent(this.message);

  @override
  List<Object?> get props => [message];
}

/// Error state
class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object?> get props => [message];
}

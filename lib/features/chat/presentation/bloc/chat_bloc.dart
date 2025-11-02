// lib/features/chat/presentation/bloc/chat_bloc.dart

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eservelink/features/chat/domain/entities/message_entity.dart';
import 'package:eservelink/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:eservelink/features/chat/domain/usecases/stream_messages_usecase.dart';
import 'package:eservelink/features/chat/domain/usecases/mark_messages_read_usecase.dart';
import 'package:eservelink/features/chat/domain/usecases/send_typing_indicator_usecase.dart';
import 'package:eservelink/features/chat/domain/repositories/chat_repository.dart';
import 'package:eservelink/features/chat/presentation/bloc/chat_event.dart';
import 'package:eservelink/features/chat/presentation/bloc/chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final StreamMessagesUseCase streamMessages;
  final SendMessageUseCase sendMessage;
  final MarkMessagesReadUseCase markMessagesRead;
  final SendTypingIndicatorUseCase sendTypingIndicator;
  final ChatRepository repository;

  // Stream subscriptions
  StreamSubscription? _messagesSubscription;
  StreamSubscription? _typingIndicatorsSubscription;

  // Cache current data
  List<MessageEntity> _currentMessages = [];
  Map<String, bool> _currentTypingIndicators = {};
  String _currentUserId = '';

  ChatBloc({
    required this.streamMessages,
    required this.sendMessage,
    required this.markMessagesRead,
    required this.sendTypingIndicator,
    required this.repository,
  }) : super(ChatInitial()) {
    on<StartListeningToMessagesEvent>(_onStartListening);
    on<StopListeningToMessagesEvent>(_onStopListening);
    on<MessagesUpdatedEvent>(_onMessagesUpdated);
    on<SendMessageEvent>(_onSendMessage);
    on<MarkMessagesAsReadEvent>(_onMarkMessagesRead);
    on<SendTypingIndicatorEvent>(_onSendTypingIndicator);
    on<TypingIndicatorsUpdatedEvent>(_onTypingIndicatorsUpdated);
  }

  Future<void> _onStartListening(
    StartListeningToMessagesEvent event,
    Emitter<ChatState> emit,
  ) async {
    _currentUserId = event.currentUserId;

    // Cancel existing subscriptions
    await _messagesSubscription?.cancel();
    await _typingIndicatorsSubscription?.cancel();

    // Start listening to messages
    _messagesSubscription = streamMessages(event.sessionId).listen(
      (result) {
        result.fold(
          (failure) {
            add(MessagesUpdatedEvent([]));
          },
          (messages) {
            _currentMessages = messages;
            add(MessagesUpdatedEvent(messages));
          },
        );
      },
      onError: (error) {
        ///TODO implement proper error handling
      },
    );

    // Start listening to typing indicators
    _typingIndicatorsSubscription = repository
        .streamTypingIndicators(sessionId: event.sessionId)
        .listen(
          (result) {
            result.fold(
              (failure) {
                ///TODO implement proper error handling
              },
              (indicators) {
                _currentTypingIndicators = indicators;
                add(TypingIndicatorsUpdatedEvent(indicators));
              },
            );
          },
          onError: (error) {
            ///TODO implement proper error handling
          },
        );
  }

  void _onStopListening(
    StopListeningToMessagesEvent event,
    Emitter<ChatState> emit,
  ) {
    _messagesSubscription?.cancel();
    _typingIndicatorsSubscription?.cancel();
    _messagesSubscription = null;
    _typingIndicatorsSubscription = null;
  }

  void _onMessagesUpdated(MessagesUpdatedEvent event, Emitter<ChatState> emit) {
    emit(
      ChatMessagesLoaded(
        messages: event.messages,
        typingIndicators: _currentTypingIndicators,
        currentUserId: _currentUserId,
      ),
    );
  }

  void _onTypingIndicatorsUpdated(
    TypingIndicatorsUpdatedEvent event,
    Emitter<ChatState> emit,
  ) {
    emit(
      ChatMessagesLoaded(
        messages: _currentMessages,
        typingIndicators: event.indicators,
        currentUserId: _currentUserId,
      ),
    );
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    final result = await sendMessage(
      SendMessageParams(
        sessionId: event.sessionId,
        senderId: event.senderId,
        senderName: event.senderName,
        senderRole: event.senderRole,
        text: event.text,
      ),
    );

    result.fold(
      (failure) {
        emit(ChatError(failure.message));
        // Return to loaded state
        emit(
          ChatMessagesLoaded(
            messages: _currentMessages,
            typingIndicators: _currentTypingIndicators,
            currentUserId: _currentUserId,
          ),
        );
      },
      (message) {
        // Don't emit any state - the stream will automatically update
        // This prevents the "Something went wrong" screen
      },
    );
  }

  Future<void> _onMarkMessagesRead(
    MarkMessagesAsReadEvent event,
    Emitter<ChatState> emit,
  ) async {
    await markMessagesRead(
      MarkMessagesReadParams(sessionId: event.sessionId, userId: event.userId),
    );
  }

  Future<void> _onSendTypingIndicator(
    SendTypingIndicatorEvent event,
    Emitter<ChatState> emit,
  ) async {
    await sendTypingIndicator(
      TypingIndicatorParams(
        sessionId: event.sessionId,
        userId: event.userId,
        isTyping: event.isTyping,
      ),
    );
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    _typingIndicatorsSubscription?.cancel();
    return super.close();
  }
}

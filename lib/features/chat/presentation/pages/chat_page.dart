import 'package:eservelink/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:eservelink/features/auth/presentation/bloc/auth_state.dart';
import 'package:eservelink/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:eservelink/features/chat/presentation/bloc/chat_event.dart';
import 'package:eservelink/features/chat/presentation/bloc/chat_state.dart';
import 'package:eservelink/features/chat/presentation/widgets/chat_input.dart';
import 'package:eservelink/features/chat/presentation/widgets/message_bubble.dart';
import 'package:eservelink/features/chat/presentation/widgets/typing_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatPage extends StatefulWidget {
  final String sessionId;
  final String otherUserName;
  final String tableNumber;

  const ChatPage({
    super.key,
    required this.sessionId,
    required this.otherUserName,
    required this.tableNumber,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController _scrollController = ScrollController();

  bool _didInitDependencies = false;
  ChatBloc? _chatBloc;
  AuthBloc? _authBloc;

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _chatBloc?.add(StopListeningToMessagesEvent());
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInitDependencies) {
      _chatBloc = context.read<ChatBloc>();
      _authBloc = context.read<AuthBloc>();
      _didInitDependencies = true;
      _startListening();
    }
  }

  void _startListening() {
    final authState = _authBloc?.state;
    if (authState is AuthSuccess) {
      _chatBloc?.add(
        StartListeningToMessagesEvent(
          sessionId: widget.sessionId,
          currentUserId: authState.user.uid,
        ),
      );

      // Mark messages as read
      _chatBloc?.add(
        MarkMessagesAsReadEvent(
          sessionId: widget.sessionId,
          userId: authState.user.uid,
        ),
      );
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void _handleSendMessage(String text) {
    final authState = _authBloc?.state;
    if (authState is AuthSuccess) {
      _chatBloc?.add(
        SendMessageEvent(
          sessionId: widget.sessionId,
          senderId: authState.user.uid,
          senderName: authState.user.displayName ?? 'User',
          senderRole: authState.user.role,
          text: text,
        ),
      );
    }
  }

  void _handleTypingChanged(bool isTyping) {
    final authState = _authBloc?.state;
    if (authState is AuthSuccess) {
      _chatBloc?.add(
        SendTypingIndicatorEvent(
          sessionId: widget.sessionId,
          userId: authState.user.uid,
          isTyping: isTyping,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.otherUserName),
            Text(widget.tableNumber, style: const TextStyle(fontSize: 12)),
          ],
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: BlocConsumer<ChatBloc, ChatState>(
              listener: (context, state) {
                if (state is ChatMessagesLoaded) {
                  _scrollToBottom();

                  // Mark messages as read when new messages arrive
                  final authState = _authBloc?.state;
                  if (authState is AuthSuccess) {
                    _chatBloc?.add(
                      MarkMessagesAsReadEvent(
                        sessionId: widget.sessionId,
                        userId: authState.user.uid,
                      ),
                    );
                  }
                } else if (state is ChatMessageSent) {
                  _scrollToBottom();
                } else if (state is ChatError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is ChatLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.deepPurple),
                  );
                }

                if (state is ChatMessagesLoaded) {
                  final messages = state.messages;
                  final isOtherUserTyping = state.isOtherUserTyping();

                  if (messages.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No messages yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start the conversation!',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: messages.length + (isOtherUserTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Show typing indicator as last item
                      if (isOtherUserTyping && index == messages.length) {
                        return TypingIndicator(userName: widget.otherUserName);
                      }

                      final message = messages[index];
                      final isMe = message.senderId == state.currentUserId;

                      return MessageBubble(message: message, isMe: isMe);
                    },
                  );
                }

                return const Center(child: Text('Something went wrong'));
              },
            ),
          ),

          // Chat input
          ChatInput(
            onSendMessage: _handleSendMessage,
            onTypingChanged: _handleTypingChanged,
          ),
        ],
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';

class ChatInput extends StatefulWidget {
  final Function(String) onSendMessage;
  final Function(bool) onTypingChanged;

  const ChatInput({
    super.key,
    required this.onSendMessage,
    required this.onTypingChanged,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _typingTimer;
  bool _isTyping = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }

  void _handleTextChanged(String text) {
    // Cancel previous timer
    _typingTimer?.cancel();

    if (text.isNotEmpty) {
      // User is typing
      if (!_isTyping) {
        _isTyping = true;
        widget.onTypingChanged(true);
      }

      // Set timer to stop typing indicator after 2 seconds of inactivity
      _typingTimer = Timer(const Duration(seconds: 2), () {
        if (_isTyping) {
          _isTyping = false;
          widget.onTypingChanged(false);
        }
      });
    } else {
      // Text is empty, stop typing
      if (_isTyping) {
        _isTyping = false;
        widget.onTypingChanged(false);
      }
    }
  }

  void _handleSendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    // Send message
    widget.onSendMessage(text);

    // Clear input
    _controller.clear();

    // Stop typing indicator
    if (_isTyping) {
      _isTyping = false;
      widget.onTypingChanged(false);
    }

    // Cancel timer
    _typingTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 4,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Text input
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                  onChanged: _handleTextChanged,
                  onSubmitted: (_) => _handleSendMessage(),
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Send button
            Material(
              color: Colors.deepPurple,
              borderRadius: BorderRadius.circular(24),
              child: InkWell(
                onTap: _handleSendMessage,
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  child: const Icon(Icons.send, color: Colors.white, size: 22),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

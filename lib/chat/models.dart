import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';

// Message Model
class Message {
  final String content;
  final bool isUserMessage;

  Message(this.content, this.isUserMessage);
}

// ChatController for managing messages
class ChatController extends ChangeNotifier {
  final List<Message> _messages = [];
  List<Message> get messages => _messages;

  void addMessage(Message message) {
    _messages.add(message);
    notifyListeners();
  }

  Future<void> simulateAssistantResponse() async {
    final random = Random();
    final words = List.generate(
        random.nextInt(10) + 5,
        (_) => String.fromCharCodes(List.generate(
            random.nextInt(4) + 2, (_) => random.nextInt(26) + 97))).join(" ");
    addMessage(Message(words, false));
  }
}

// User Message Bubble
class UserMessageBubble extends StatelessWidget {
  final String text;

  const UserMessageBubble(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

// Assistant Message Bubble
class AssistantMessageBubble extends StatelessWidget {
  final String text;

  const AssistantMessageBubble(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                text,
                style: const TextStyle(fontSize: 16.0, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Chat View
class ChatView extends StatelessWidget {
  final ChatController controller;

  const ChatView(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 900),
        child: ChangeNotifierProvider.value(
          value: controller,
          child: Consumer<ChatController>(
            builder: (context, controller, child) {
              return ListView.builder(
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final message = controller.messages[index];
                  return message.isUserMessage
                      ? UserMessageBubble(message.content)
                      : AssistantMessageBubble(message.content);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class Chat extends StatelessWidget {
  final ChatController _controller = ChatController();
  final TextEditingController _textController = TextEditingController();

  Chat({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat Widget')),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            children: [
              Expanded(child: ChatView(_controller)),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Type a message...',
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () {
                        final text = _textController.text;
                        if (text.isNotEmpty) {
                          _controller.addMessage(Message(text, true));
                          _textController.clear();
                          _controller.simulateAssistantResponse();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

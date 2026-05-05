import 'package:piaggio_driver/constants/app_theme.dart';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:piaggio_driver/constants/app_dimensions.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

class ChatMessage {
  final String text;
  final bool isSentByUser;
  ChatMessage({required this.text, required this.isSentByUser});
}

class PusherChatPage extends StatefulWidget {
  const PusherChatPage({super.key});

  @override
  State<PusherChatPage> createState() => _PusherChatPageState();
}

class _PusherChatPageState extends State<PusherChatPage> {
  final PusherChannelsFlutter _pusher = PusherChannelsFlutter.getInstance();
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initPusher();
  }

  Future<void> _initPusher() async {
    await _pusher.init(
      apiKey: "a34cc71b9ff9fafec6a8",
      cluster: "mt1",
      onConnectionStateChange: (current, previous) {
        log("Connection: $current (was $previous)");
      },
      onError: (msg, code, err) {
        log("Error: $msg ($code) $err");
      },
    );
    await _pusher.connect();
    await _pusher.subscribe(
      channelName: 'name_channell',
      onEvent: (event) {
        if (event.eventName == 'name_eventt' && event.data != null) {
          String payload = event.data!;
          String messageText;
          try {
            final dynamic decoded = jsonDecode(payload);
            // افترض أن JSON يحتوي على مفتاح 'message'
            if (decoded is Map && decoded.containsKey('message')) {
              messageText = decoded['message'].toString();
            } else {
              // إذا كان payload نص فقط
              messageText = payload;
            }
          } catch (_) {
            messageText = payload;
          }
          if (mounted) {
            setState(() {
              _messages
                  .add(ChatMessage(text: messageText, isSentByUser: false));
            });
          }
        }
      },
    );
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(ChatMessage(text: text, isSentByUser: true));
    });
    _controller.clear();
  }

  @override
  void dispose() {
    _pusher.disconnect();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Pusher Chat',
            style: TextStyle(color: AppThemes.primaryNavy, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.chevron_left_rounded, color: AppThemes.primaryNavy, size: 30),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    final alignment = msg.isSentByUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft;
                    final color = msg.isSentByUser ? Colors.blue : Colors.grey;
                    return Align(
                      alignment: alignment,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          msg.text,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                child: Row(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.send_sharp, color: Colors.white),
                        onPressed: _sendMessage,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'أكتب رسالة',
                          filled: true,
                          fillColor: Colors.grey[200],
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
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

import 'dart:convert';
import 'dart:developer';
import 'package:biadgo/widgets/message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:biadgo/logic/controller/chat_controller.dart';
import 'package:biadgo/logic/controller/create_chat_messages_controller.dart';
import '../constants/apiUrl.dart';

class ChatMessage {
  final String text;
  final bool isSentByUser;
  final DateTime timestamp;
  ChatMessage({
    required this.text,
    required this.isSentByUser,
    required this.timestamp,
  });
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _pusher = PusherChannelsFlutter.getInstance();
  final msgCtrl = Get.put(CreateChatMessagesController());
  final convCtrl = Get.find<ChatController>();
  final List<ChatMessage> _messages = [];
  final _host = baseUrl;

  @override
  void initState() {
    super.initState();
    ever<int?>(convCtrl.conversationId, (id) {
      if (id != null) _subscribeToChannel(id);
    });
    _setupPusher();
  }

  Future<void> _setupPusher() async {
    final token = GetStorage().read<String>('token');
    await _pusher.init(
      apiKey: 'ea13bc3f077292006895',
      cluster: 'eu',
      useTLS: true,
      onAuthorizer: (channel, socketId, _) async {
        final res = await http.post(
          Uri.parse('$_host/api/broadcasting/auth'),
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
            'X-Requested-With': 'XMLHttpRequest',
          },
          body: 'socket_id=$socketId&channel_name=$channel',
        );
        log('AUTH ${res.statusCode}: ${res.body}');
        return res.statusCode == 200
            ? jsonDecode(res.body) as Map<String, dynamic>
            : <String, dynamic>{};
      },
      onConnectionStateChange: (prev, cur) async {
        log('Pusher: $prev → $cur');
        if (cur == 'DISCONNECTED') {
          await Future.delayed(const Duration(seconds: 2));
          await _pusher.connect();
        }
      },
      onError: (msg, code, err) {
        log('Pusher Error: $msg ($code) $err');
      },
    );
    await _pusher.connect();
  }

  bool _isSending = false;

  Future<void> _subscribeToChannel(int id) async {
    final channelName = 'private-chat.$id';
    await _pusher.subscribe(
      channelName: channelName,
      onEvent: (e) async {
        if (e.eventName == 'App\\Events\\NewMessageSent' && e.data != null) {
          try {
            if (_isSending) {
              _isSending = false;
              return;
            }
            final jsonData = jsonDecode(e.data!);
            final messageData = jsonData['message'] as Map<String, dynamic>;
            final senderId = messageData['sender_id'] as int;
            final currentId = GetStorage().read<int>('user_id') ?? -1;
            if (senderId == currentId) return;
            if (mounted) {
              setState(() {
                _messages.insert(
                  0,
                  ChatMessage(
                    text: messageData['message'] as String,
                    isSentByUser: false,
                    timestamp: DateTime.parse(messageData['created_at']),
                  ),
                );
              });
            }
          } catch (err) {
            log('❌ Error parsing message: $err');
          }
        }
      },
    );
  }

  Future<void> _sendMessage() async {
    final text = msgCtrl.messageController.text.trim();
    if (text.isEmpty) return;
    final now = DateTime.now();
    _isSending = true;
    if (mounted) {
      setState(() {
        _messages.insert(
          0,
          ChatMessage(
            text: text,
            isSentByUser: true,
            timestamp: now,
          ),
        );
      });
    }

    try {
      await msgCtrl.createChatMessage();
      msgCtrl.messageController.clear();
    } catch (e) {
      // في حالة فشل الإرسال، نزيل الرسالة المحلية
      if (mounted) {
        setState(() {
          _messages.removeAt(0);
        });
      }
      Get.snackbar('Error', 'Failed to send message');
    } finally {
      _isSending = false;
    }
  }

  @override
  void dispose() {
    _pusher.disconnect();
    msgCtrl.messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المحادثة'),
        backgroundColor: Get.theme.primaryColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(8),
              itemCount: _messages.length,
              itemBuilder: (_, i) {
                final m = _messages[i];
                return MessageBubble(
                  message: m.text,
                  isMe: m.isSentByUser,
                  time: DateFormat('hh:mm a').format(m.timestamp),
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: msgCtrl.messageController,
              decoration: InputDecoration(
                hintText: 'اكتب رسالتك...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Get.theme.primaryColor,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}

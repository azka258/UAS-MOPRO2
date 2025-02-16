import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../services/chat_service.dart';
import '../../models/chat.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'chat_detail_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final String currentUserId = Supabase.instance.client.auth.currentUser!.id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Chats",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green, Colors.lightGreen],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 10,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFF5F5F5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: StreamBuilder<List<Chat>>(
  stream: _chatService.getChatsForUser(currentUserId),
  builder: (context, snapshot) {
    if (!snapshot.hasData) {
      return _buildLoadingList();
    }
    final chats = snapshot.data!;
    final uniqueChats = _getUniqueChats(chats, currentUserId);

    return ListView.builder(
      itemCount: uniqueChats.length,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      itemBuilder: (context, index) {
        final chat = uniqueChats[index];
        final isMe = chat.senderId == currentUserId;
        final receiverId = isMe ? chat.receiverId : chat.senderId;
        return FutureBuilder<Map<String, String>>(
          future: _chatService.getUserProfile(receiverId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return _buildLoadingTile();
            }
            final receiverName = snapshot.data!['nama']!;
            final profilePictureUrl = snapshot.data!['profile_picture_url'] ?? '';

            return _buildChatTile(chat, receiverName, receiverId, profilePictureUrl);
          },
        );
      },
    );
  },
)
      ),
    );
  }

  Widget _buildLoadingList() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) => _buildLoadingTile(),
    );
  }

  Widget _buildLoadingTile() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListTile(
        leading: const CircleAvatar(backgroundColor: Colors.grey, radius: 25),
        title: Container(height: 10, color: Colors.grey),
        subtitle: Container(height: 8, width: 50, color: Colors.grey),
      ),
    );
  }

  Widget _buildChatTile(Chat chat, String receiverName, String receiverId, String profilePictureUrl) {
  return Card(
    elevation: 2,
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      leading: CircleAvatar(
        backgroundImage: profilePictureUrl.isNotEmpty
            ? NetworkImage(profilePictureUrl)
            : null,
        backgroundColor: Colors.green.shade400,
        child: profilePictureUrl.isEmpty
            ? Text(receiverName[0], style: TextStyle(color: Colors.white))
            : null,
        radius: 25,
      ),
      title: Text(
        receiverName,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      subtitle: Text(
        chat.message,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Colors.grey[700], fontSize: 14),
      ),
      trailing: Text(
        timeago.format(chat.createdAt, locale: 'en_short'),
        style: TextStyle(color: Colors.grey[500], fontSize: 12),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailScreen(
              receiverId: receiverId,
              receiverName: receiverName,
            ),
          ),
        );
      },
    ),
  );
}

  List<Chat> _getUniqueChats(List<Chat> chats, String currentUserId) {
    final uniqueChats = <String, Chat>{};
    for (final chat in chats) {
      final otherUserId = chat.senderId == currentUserId ? chat.receiverId : chat.senderId;
      if (!uniqueChats.containsKey(otherUserId)) {
        uniqueChats[otherUserId] = chat;
      }
    }
    return uniqueChats.values.toList();
  }
}

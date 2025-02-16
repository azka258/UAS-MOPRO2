import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chat.dart';

class ChatService {
  final SupabaseClient _supabase = Supabase.instance.client;
String nama = Supabase.instance.client.auth.currentUser?.email ?? 'Unknown';

  Stream<List<Chat>> getChatsForUser(String userId) {
    return _supabase
        .from('chats')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => data
            .where((json) => json['sender_id'] == userId || json['receiver_id'] == userId)
            .map((json) => Chat.fromJson(json))
            .toList());
  }

  // Mengambil chat antara dua pengguna (sender dan receiver)
  Stream<List<Chat>> getChats(String senderId, String receiverId) {
    return _supabase
        .from('chats')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: true)
        .map((data) => data
            .where((json) =>
                (json['sender_id'] == senderId && json['receiver_id'] == receiverId) ||
                (json['sender_id'] == receiverId && json['receiver_id'] == senderId))
            .map((json) => Chat.fromJson(json))
            .toList());
  }

  // Mengirim pesan
  Future<void> sendMessage(String senderId, String receiverId, String nama, String message, {String? imageUrl}) async {
    await _supabase.from('chats').insert({
      'sender_id': senderId,
      'receiver_id': receiverId,
      'nama': nama,
      'message': message,
      'image_url': imageUrl,
      'created_at': DateTime.now().toIso8601String(),
    });
    print("Pesan terkirim dari $senderId ke $receiverId: $message");
  }
  // Di dalam ChatService
Future<String> getUserName(String userId) async {
  final response = await _supabase
      .from('users') 
      .select('nama, profile_picture_url')
      .eq('id', userId)
      .single();

  return response['nama'] ?? 'Unknown';
  }
  Future<Map<String, String>> getUserProfile(String userId) async {
  final response = await _supabase
      .from('users') 
      .select('nama, profile_picture_url')
      .eq('id', userId)
      .single();

  return {
    'nama': response['nama'] ?? 'Unknown',
    'profile_picture_url': response['profile_picture_url'] ?? '',
  };
}
}
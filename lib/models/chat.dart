class Chat {
  final String id;
  final String senderId;
  final String receiverId;
  final String message;
  final String? imageUrl;
  final DateTime createdAt;

  Chat({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    this.imageUrl,
    required this.createdAt,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'],
      senderId: json['sender_id'],
      receiverId: json['receiver_id'],
      message: json['message'],
      imageUrl: json['image_url'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

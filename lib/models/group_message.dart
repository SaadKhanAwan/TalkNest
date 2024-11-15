import 'package:cloud_firestore/cloud_firestore.dart';

class GroupMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final String? imageUrl;
  final String messageType;
  final bool readStatus;
  final Timestamp timestamp;

  GroupMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    this.imageUrl,
    required this.messageType,
    required this.readStatus,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sender_id': senderId,
      'sender_name': senderName,
      'text': text,
      'image_url': imageUrl,
      'message_type': messageType,
      'read_status': readStatus,
      'timestamp': timestamp,
    };
  }

  static GroupMessage fromMap(Map<String, dynamic> map) {
    return GroupMessage(
      id: map['id'],
      senderId: map['sender_id'],
      senderName: map['sender_name'],
      text: map['text'],
      imageUrl: map['image_url'],
      messageType: map['message_type'],
      readStatus: map['read_status'],
      timestamp: map['timestamp'],
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String messageId;
  final String? imageUrl;
  final String messageText;
  final bool readStatus;
  final String receiverId;
  final String senderId;
  final String senderName;
  final String messageType;

  final Timestamp timestamp;

  Message({
    required this.messageId,
    this.imageUrl,
    required this.messageText,
    required this.messageType,
    required this.readStatus,
    required this.receiverId,
    required this.senderId,
    required this.senderName,
    required this.timestamp,
  });

  // Converts Message instance to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'message_id': messageId,
      'message_type': messageType,
      'image_url': imageUrl,
      'message': messageText,
      'read_status': readStatus,
      'receiver_id': receiverId,
      'sender_id': senderId,
      'sender_name': senderName,
      'timestamp': timestamp,
    };
  }

  // Creates a Message instance from a map (e.g., from Firestore)
  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      messageId: map['message_id'],
      messageType: map['message_type'],
      imageUrl: map['image_url'],
      messageText: map['message'],
      readStatus: map['read_status'],
      receiverId: map['receiver_id'],
      senderId: map['sender_id'],
      senderName: map['sender_name'],
      timestamp: map['timestamp'],
    );
  }
}

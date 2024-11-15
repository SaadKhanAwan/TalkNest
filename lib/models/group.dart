import 'package:cloud_firestore/cloud_firestore.dart';

class Group {
  String id;
  String name;
  String? lastMessage;
  String? groupPic;
  String info;
  String createdBy;
  Timestamp createdAt;
  List<String> members;

  Group({
    required this.id,
    required this.name,
    this.lastMessage,
    this.groupPic,
    required this.info,
    required this.createdBy,
    required this.createdAt,
    required this.members,
  });

  // Convert Group object to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'lastMessage': lastMessage,
      'groupPic': groupPic,
      'info': info,
      'createdBy': createdBy,
      'createdAt': createdAt,
      'members': members,
    };
  }

  // Create Group object from Firestore document
  factory Group.fromMap(Map<String, dynamic> map) {
    return Group(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      lastMessage: map['lastMessage'],
      groupPic: map['groupPic'],
      info: map['info'] ?? '',
      createdBy: map['createdBy'] ?? '',
      createdAt: map['createdAt'] ?? Timestamp.now(),
      members: List<String>.from(map['members'] ?? []),
    );
  }
}

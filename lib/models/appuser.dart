import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String name;
  final String profileImage;
  final String email;
  final String about;
  final DateTime createdAt;
  final DateTime lastOnline;
  final bool status;

  AppUser({
    required this.id,
    required this.name,
    required this.profileImage,
    required this.email,
    required this.about,
    required this.createdAt,
    required this.lastOnline,
    required this.status,
  });

  factory AppUser.fromJson(Map<String, dynamic> data) {
    return AppUser(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      profileImage: data['profile_image'] ?? '',
      email: data['email'] ?? '',
      about: data['about'] ?? '',
      createdAt: (data['created_At'] as Timestamp).toDate(),
      lastOnline: (data['last_online'] as Timestamp).toDate(),
      status: data['status'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'profile_image': profileImage,
      'email': email,
      'about': about,
      'created_At': createdAt,
      'last_online': lastOnline,
      'status': status,
    };
  }
}

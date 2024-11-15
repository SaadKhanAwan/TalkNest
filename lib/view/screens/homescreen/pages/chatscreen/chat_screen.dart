import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:talknest/config/images.dart';
import 'package:talknest/models/appuser.dart';
import 'package:talknest/utils/routes/route_name.dart';
import 'package:talknest/view/widgets/usercard.dart';
import 'package:talknest/viewmodel/services/firebaseservices/firebase_apis.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: FirebaseApi().getChatHistoryStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No recent chats available"));
        } else {
          final chatHistory = snapshot.data!;
          return ListView.builder(
            itemCount: chatHistory.length,
            itemBuilder: (context, index) {
              final AppUser? user = chatHistory[index]['user'];
              final String lastMessage =
                  chatHistory[index]['lastMessage'] ?? 'No message';
              final Timestamp? lastMessageTimestamp =
                  chatHistory[index]['lastMessageTimestamp'];

              if (user == null) {
                return const SizedBox(); // Skip rendering if user data is null
              }

              // Check if the timestamp is null
              final messageTime = lastMessageTimestamp?.toDate();
              final formattedTime = messageTime != null
                  ? "${messageTime.hour}:${messageTime.minute.toString().padLeft(2, '0')}"
                  : "N/A";

              return Usercard(
                name: user.name,
                subtitle: lastMessage,
                time: formattedTime,
                imagePath: user.profileImage.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: user.profileImage,
                        placeholder: (context, url) => const CircleAvatar(
                          backgroundImage: AssetImage(MyImages.boyPic),
                        ),
                        errorWidget: (context, url, error) =>
                            const CircleAvatar(
                          backgroundImage: AssetImage(MyImages.boyPic),
                        ),
                        imageBuilder: (context, imageProvider) => CircleAvatar(
                          radius: 30,
                          backgroundImage: imageProvider,
                        ),
                      )
                    : Image.asset(MyImages.boyPic),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    RouteNames.userChatScreen,
                    arguments: user,
                  );
                },
              );
            },
          );
        }
      },
    );
  }
}

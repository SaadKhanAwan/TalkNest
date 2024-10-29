import 'package:flutter/material.dart';
import 'package:talknest/config/images.dart';
import 'package:talknest/utils/routes/export_file.dart';
import 'package:talknest/view/widgets/usercard.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return Usercard(
            name: "Saad",
            subtitle: "Bad ma bat karte ha",
            time: "12:00",
            imagePath: Image.asset(MyImages.boyPic),
            onTap: () {
              Navigator.pushNamed(context, RouteNames.userChatScreen);
            });
      },
    );
  }
}

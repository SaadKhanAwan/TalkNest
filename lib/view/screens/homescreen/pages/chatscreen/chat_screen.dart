import 'package:flutter/material.dart';
import 'package:talknest/config/images.dart';
import 'package:talknest/responsiveness/sizes.dart';
import 'package:talknest/utils/routes/export_file.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            Navigator.pushNamed(context, RouteNames.userChatScreen);
          },
          child: Container(
            margin: EdgeInsets.symmetric(
                horizontal: ResponsiveSizes.width(context, .02), vertical: 5),
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                borderRadius: BorderRadius.circular(15)),
            padding: EdgeInsets.symmetric(
                horizontal: ResponsiveSizes.width(context, .01), vertical: 5),
            child: ListTile(
              leading: Image.asset(MyImages.boyPic),
              title: Text("Saad", style: Theme.of(context).textTheme.bodyLarge),
              subtitle: Text("Bad ma bat karte ha",
                  style: Theme.of(context).textTheme.labelMedium),
              trailing:
                  Text("12:00", style: Theme.of(context).textTheme.labelMedium),
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:talknest/config/images.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Icon(Icons.arrow_back_ios)),
            const SizedBox(
              width: 10,
            ),
            Text(
              "Profile",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 10),
              margin: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    MyImages.boyPic,
                    height: 80,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    "Saad@gmail.com",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  Text(
                    "Saad Awan",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      buildRowContainer(
                          color: const Color(0xff039C00),
                          context: context,
                          icon: Icons.phone,
                          text: "Call"),
                      buildRowContainer(
                          color: const Color(0xff0057FF),
                          context: context,
                          icon: Icons.chat,
                          text: "Chat"),
                      buildRowContainer(
                          color: const Color(0xffF93C00),
                          context: context,
                          icon: Icons.delete,
                          text: "Delete"),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  buildRowContainer({icon, context, text, color}) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
          color: const Color(0xff191B28),
          borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
          ),
          const SizedBox(
            width: 5,
          ),
          Text(
            text,
            style:
                Theme.of(context).textTheme.bodySmall!.copyWith(color: color),
          )
        ],
      ),
    );
  }
}

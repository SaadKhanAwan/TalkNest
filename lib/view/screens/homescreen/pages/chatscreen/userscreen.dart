import 'package:flutter/material.dart';
import 'package:talknest/config/images.dart';
import 'package:talknest/models/appuser.dart';
import 'package:talknest/responsiveness/sizes.dart';
import 'package:talknest/utils/routes/export_file.dart';
import 'package:talknest/viewmodel/services/firebaseservices/firebase_apis.dart';

class UserChatScreen extends StatefulWidget {
  final AppUser user;
  const UserChatScreen({super.key, required this.user});

  @override
  State<UserChatScreen> createState() => _UserChatScreenState();
}

class _UserChatScreenState extends State<UserChatScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> messages = [
    {'text': 'Hey there!', 'isMe': true, 'time': '10:00 AM'},
    {'text': 'Hello!', 'isMe': false, 'time': '10:01 AM'},
    {'text': 'How are you?', 'isMe': true, 'time': '10:02 AM'},
    {
      'text':
          'I am fine, thanks. What about you?Where are you now a days you are jsut invisible.Still you work with khan or not.',
      'isMe': false,
      'time': '10:03 AM'
    },
    {'text': 'I\'m doing well!', 'isMe': true, 'time': '10:04 AM'},
    {'text': 'That\'s great to hear!', 'isMe': false, 'time': '10:05 AM'},
    {'text': 'Do you have any plans today?', 'isMe': true, 'time': '10:06 AM'},
    {
      'text': 'Yes, I\'m meeting some friends.',
      'isMe': false,
      'time': '10:07 AM'
    },
    {'text': 'Nice! Enjoy your day!', 'isMe': true, 'time': '10:08 AM'},
    {'text': 'Thank you! You too!', 'isMe': false, 'time': '10:09 AM'},
  ];

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
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, RouteNames.userprofileScreen);
                  },
                  child: Image.asset(
                    MyImages.boyPic,
                    height: 40,
                  ),
                )),
            Text(
              "Saad",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
        actions: [
          const Icon(
            Icons.phone,
            size: 25,
          ),
          ResponsiveSizes.horizentalSizebox(context, .03),
          const Icon(
            Icons.video_call,
            size: 25,
          ),
          ResponsiveSizes.horizentalSizebox(context, .035)
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true, // Show recent messages at the bottom
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[messages.length - 1 - index];
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Column(
                    crossAxisAlignment: message['isMe']
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      // Message Container
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(15),
                            topRight: const Radius.circular(15),
                            bottomRight: message['isMe']
                                ? const Radius.circular(0)
                                : const Radius.circular(15),
                            bottomLeft: message['isMe']
                                ? const Radius.circular(15)
                                : const Radius.circular(0),
                          ),
                          color: const Color(0xff34374B),
                        ),
                        child: Text(
                          message['text'],
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            fontFamily: "Poppins",
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      // Time and ticks outside the container
                      message['isMe']
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  message['time'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontFamily: "Poppins",
                                    fontSize: 10,
                                    color: Color(0xff34374B),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                const Icon(Icons.done_all_rounded,
                                    size: 16, color: Color(0xff34374B)),
                              ],
                            )
                          : Text(
                              message['time'],
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                fontFamily: "Poppins",
                                color: Color(0xff34374B),
                              ),
                            ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xff34374B),
                borderRadius: BorderRadius.circular(30), // Rounded corners
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.mic),
                    onPressed: () {
                      // Handle mic functionality
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: "Type a message...",
                        border: InputBorder
                            .none, // Remove the default TextField border
                        contentPadding: EdgeInsets.symmetric(horizontal: 15),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.photo),
                    onPressed: () {
                      // Handle gallery image functionality
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      if (_controller.text.isNotEmpty) {
                        FirebaseApi().sendMessage(
                            messageText: _controller.text,
                            targetUserId: widget.user.id);
                      }
                    },
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

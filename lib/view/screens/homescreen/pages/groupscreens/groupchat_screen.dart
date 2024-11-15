import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:talknest/config/images.dart';
import 'package:talknest/helper/dateformate.dart/dateformate.dart';
import 'package:talknest/models/group_message.dart';
import 'package:talknest/models/group.dart';
import 'package:talknest/view/screens/homescreen/pages/groupscreens/group_info.dart';
import 'package:talknest/viewmodel/controller/groups/group_controller.dart';

class GroupChatScreen extends StatefulWidget {
  final Group group;
  const GroupChatScreen({super.key, required this.group});

  @override
  _GroupChatScreenState createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GroupProvider(),
      builder: (context, child) {
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
                  child: const Icon(Icons.arrow_back_ios),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => GroupManagementScreen(
                                  group: widget.group,
                                  isAdmin: widget.group.createdBy ==
                                      FirebaseAuth.instance.currentUser!.uid)));
                    },
                    child: widget.group.groupPic!.isNotEmpty
                        ? CircleAvatar(
                            radius: 20,
                            backgroundImage: CachedNetworkImageProvider(
                                widget.group.groupPic!),
                          )
                        : CircleAvatar(
                            radius: 20, child: Image.asset(MyImages.boyPic)),
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                Text(widget.group.name)
              ],
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: Consumer<GroupProvider>(
                  builder: (context, groupProvider, child) {
                    return StreamBuilder<List<GroupMessage>>(
                      stream:
                          groupProvider.getGroupMessagesStream(widget.group.id),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        final messages = snapshot.data!;
                        return ListView.builder(
                          reverse: true,
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];
                            final isMe = message.senderId ==
                                FirebaseAuth.instance.currentUser!.uid;
                            final isImageMessage = message.imageUrl != null;

                            return Align(
                              alignment: isMe
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                child: Column(
                                  crossAxisAlignment: isMe
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                          topLeft: const Radius.circular(15),
                                          topRight: const Radius.circular(15),
                                          bottomRight: isMe
                                              ? const Radius.circular(0)
                                              : const Radius.circular(15),
                                          bottomLeft: isMe
                                              ? const Radius.circular(15)
                                              : const Radius.circular(0),
                                        ),
                                        color: isMe
                                            ? const Color(0xff34374B)
                                            : Colors.grey[300],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (isImageMessage)
                                            CachedNetworkImage(
                                              imageUrl: message.imageUrl!,
                                              height: 150,
                                              width: 150,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) =>
                                                  const CircularProgressIndicator(),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      const Icon(Icons.error),
                                            ),
                                          if (message.text.isNotEmpty)
                                            Text(
                                              message.text,
                                              style: TextStyle(
                                                color: isMe
                                                    ? Colors.white
                                                    : Colors.black87,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400,
                                                fontFamily: "Poppins",
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      Dateformate.formatToHourMinute(
                                          (message.timestamp as Timestamp)
                                              .toDate()
                                              .toLocal()),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w400,
                                        fontFamily: "Poppins",
                                        color:
                                            isMe ? Colors.white : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              // Display selected image preview below the TextField
              Consumer<GroupProvider>(
                builder: (context, groupProvider, child) {
                  if (groupProvider.selectedMediaFile != null) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 4.0),
                      child: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Image.file(
                            groupProvider.selectedMediaFile!,
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () {
                              groupProvider.clearSelectedMedia();
                            },
                          ),
                        ],
                      ),
                    );
                  } else {
                    return const SizedBox
                        .shrink(); // Hide if no image is selected
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xff34374B),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: "Type a message...",
                            hintStyle: TextStyle(color: Colors.white54),
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 15),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.photo, color: Colors.white),
                        onPressed: () async {
                          await context.read<GroupProvider>().pickMedia();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: () async {
                          final groupProvider = context.read<GroupProvider>();
                          final messageText = _messageController.text.trim();

                          // Clear the text field immediately
                          _messageController.clear();

                          // Send the message if there's text or an image
                          if (messageText.isNotEmpty ||
                              groupProvider.uploadedImageUrl != null) {
                            await groupProvider.sendGroupMessage(
                              groupId: widget.group.id,
                              messageText: messageText,
                              imageUrl: groupProvider.uploadedImageUrl,
                            );

                            groupProvider.clearSelectedMedia();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

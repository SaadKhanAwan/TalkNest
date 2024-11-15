import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:talknest/call/audio_call.dart';
import 'package:talknest/config/images.dart';
import 'package:talknest/helper/dateformate.dart/dateformate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:talknest/responsiveness/sizes.dart';
import 'package:talknest/utils/routes/export_file.dart';
import 'package:talknest/viewmodel/controller/chatcontroller/chat_controller.dart';
import 'package:audio_waveforms/audio_waveforms.dart' as waveforms;

class UserChatScreen extends StatefulWidget {
  final AppUser user;
  const UserChatScreen({super.key, required this.user});

  @override
  State<UserChatScreen> createState() => _UserChatScreenState();
}

class _UserChatScreenState extends State<UserChatScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatProvider(userID: widget.user.id),
      builder: (context, child) {
        final chatProvider = context.read<ChatProvider>();
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
                      Navigator.pushNamed(
                          arguments: widget.user,
                          context,
                          RouteNames.userprofileScreen);
                    },
                    child: widget.user.profileImage.isNotEmpty
                        ? CircleAvatar(
                            radius: 20,
                            backgroundImage: CachedNetworkImageProvider(
                                widget.user.profileImage),
                          )
                        : CircleAvatar(
                            radius: 20, child: Image.asset(MyImages.boyPic)),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.user.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    StreamBuilder<AppUser?>(
                      stream: chatProvider.getUserData(userId: widget.user.id),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        if (snapshot.hasData) {
                          AppUser? user = snapshot.data;
                          if (user != null) {
                            return Text(
                              user.status == true
                                  ? 'Online'
                                  : 'Last seen at: ${Dateformate.formatToHourMinute(user.lastOnline)}',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            );
                          }
                        }
                        return const Text('User data not available',
                            style: TextStyle(fontSize: 12, color: Colors.grey));
                      },
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ZegoCallPage(
                        callID: widget.user.id,
                        userName: widget.user.name,
                        image: widget.user.profileImage,
                      ),
                    ),
                  );
                },
                child: const Icon(
                  Icons.phone,
                  size: 25,
                ),
              ),
              ResponsiveSizes.horizentalSizebox(context, .03),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: Consumer<ChatProvider>(
                  builder: (context, chatProvider, child) {
                    return StreamBuilder<QuerySnapshot>(
                      stream: chatProvider.messageStream,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        final messages = snapshot.data!.docs;

                        return ListView.builder(
                          reverse: true,
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message =
                                messages[index].data() as Map<String, dynamic>;

                            bool isMe = message['sender_id'] ==
                                FirebaseAuth.instance.currentUser!.uid;
                            bool isVoiceMessage =
                                message['message_type'] == 'audio';
                            bool isImageMessage =
                                message.containsKey('image_url') &&
                                    message['image_url'] != null;
                            bool hasText = message.containsKey('message') &&
                                message['message'].isNotEmpty;
                            String messageId = messages[index].id;

                            return Padding(
                              padding: EdgeInsets.only(
                                left: isMe ? 60.0 : 10.0,
                                right: isMe ? 10.0 : 60.0,
                                top: 5.0,
                                bottom: 5.0,
                              ),
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
                                      color: const Color(0xff34374B),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (isImageMessage)
                                          CachedNetworkImage(
                                            imageUrl: message['image_url'],
                                            height: 150,
                                            width: 150,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                const CircularProgressIndicator(),
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Icon(Icons.error),
                                          ),
                                        if (isVoiceMessage)
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: Icon(
                                                  chatProvider.currentlyPlayingId ==
                                                          messageId
                                                      ? Icons.pause
                                                      : Icons.play_arrow,
                                                  color: Colors.white,
                                                ),
                                                onPressed: () {
                                                  chatProvider.playAudio(
                                                      message['audio_url'],
                                                      messageId);
                                                },
                                              ),
                                              SizedBox(width: 10.0),
                                              Expanded(
                                                child: chatProvider
                                                            .currentlyPlayingId ==
                                                        messageId
                                                    ? waveforms.AudioWaveforms(
                                                        recorderController:
                                                            chatProvider
                                                                .recorderController,
                                                        waveStyle:
                                                            const waveforms
                                                                .WaveStyle(
                                                          waveColor:
                                                              Colors.blueAccent,
                                                          showMiddleLine: false,
                                                        ),
                                                        size:
                                                            const Size(150, 50),
                                                      )
                                                    : Container(
                                                        height: 50,
                                                        width: 150,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.grey,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            'Voice note',
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .white
                                                                  .withOpacity(
                                                                      0.6),
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                              )
                                            ],
                                          ),
                                        if (hasText)
                                          Text(
                                            message['message'],
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                              fontFamily: "Poppins",
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    mainAxisAlignment: isMe
                                        ? MainAxisAlignment.end
                                        : MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        message['timestamp'] != null
                                            ? Dateformate.formatToHourMinute(
                                                (message['timestamp']
                                                        as Timestamp)
                                                    .toDate()
                                                    .toLocal())
                                            : '',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: "Poppins",
                                          color: Color(0xff34374B),
                                        ),
                                      ),
                                      if (isMe) const SizedBox(width: 5),
                                      if (isMe)
                                        Icon(
                                          Icons.done_all_rounded,
                                          size: 16,
                                          color: message['read_status'] == true
                                              ? Colors.blue
                                              : const Color(0xff34374B),
                                        ),
                                    ],
                                  ),
                                ],
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
              Consumer<ChatProvider>(
                builder: (context, chatProvider, child) {
                  if (chatProvider.selectedMediaFile != null) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 4.0),
                      child: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Image.file(
                            chatProvider.selectedMediaFile!,
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () {
                              chatProvider.clearSelectedMedia();
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
                      Padding(
                        padding: const EdgeInsets.only(left: 5.0),
                        child: GestureDetector(
                          onLongPress: () async {
                            context.read<ChatProvider>().startRecording();
                          },
                          onLongPressUp: () async {
                            await context
                                .read<ChatProvider>()
                                .stopRecording(widget.user.id);
                          },
                          onVerticalDragEnd: (details) {
                            if (details.primaryVelocity! < 0) {
                              context.read<ChatProvider>().cancelRecording();
                            }
                          },
                          child: Consumer<ChatProvider>(
                            builder: (context, chatProvider, child) {
                              return Icon(
                                chatProvider.isRecording
                                    ? Icons.close
                                    : Icons.mic,
                                color: Colors.red,
                              );
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: Consumer<ChatProvider>(
                          builder: (context, chatProvider, child) {
                            return chatProvider.isRecording
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        height: 40.0,
                                        width: double.infinity,
                                        child: waveforms.AudioWaveforms(
                                          recorderController:
                                              chatProvider.recorderController,
                                          waveStyle: const waveforms.WaveStyle(
                                            waveColor: Colors.blueAccent,
                                            showMiddleLine: false,
                                          ),
                                          size: const Size(50, 60),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        chatProvider.recordingDuration,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  )
                                : TextField(
                                    controller: chatProvider.controller,
                                    decoration: const InputDecoration(
                                      hintText: "Type a message...",
                                      border: InputBorder.none,
                                      contentPadding:
                                          EdgeInsets.symmetric(horizontal: 15),
                                    ),
                                  );
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.photo),
                        onPressed: () async {
                          await chatProvider.pickMedia();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () async {
                          await chatProvider.sendMessage(widget.user.id);
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

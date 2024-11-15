import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:talknest/call/audio_call.dart';
import 'package:talknest/config/images.dart';
import 'package:talknest/helper/dateformate.dart/dateformate.dart';
import 'package:talknest/utils/routes/export_file.dart';
import 'package:talknest/viewmodel/services/firebaseservices/firebase_apis.dart';

class Callscreen extends StatefulWidget {
  const Callscreen({super.key});

  @override
  State<Callscreen> createState() => _CallscreenState();
}

class _CallscreenState extends State<Callscreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      body: StreamBuilder(
        stream: _firestore
            .collection('calls')
            .where('callerId',
                isEqualTo: userId) // Filter for user-specific calls
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No call history found.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final call = snapshot.data!.docs[index];
              final callId = call['callId'];
              final receiverName = call['receiverName'];
              final duration = call['duration'];
              final timestamp = (call['timestamp'] as Timestamp).toDate();
              final status = call['status'];
              final profileImage = call['profileImage'];
              return FutureBuilder<String?>(
                future: FirebaseApi().getUserProfileImage(call['receiverId']),
                builder: (context, snapshot) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    margin: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      leading: profileImage != null
                          ? CircleAvatar(
                              radius: 20,
                              backgroundImage:
                                  CachedNetworkImageProvider(profileImage),
                            )
                          : CircleAvatar(
                              radius: 20, child: Image.asset(MyImages.boyPic)),
                      title: Text(receiverName),
                      subtitle: Text(
                        'Duration: ${duration}s | Status: $status\nTime: ${Dateformate.formatToHourMinute(timestamp)}',
                        style: TextStyle(fontSize: 12),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.call),
                        onPressed: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ZegoCallPage(
                                callID: callId,
                                userName: receiverName,
                                image: profileImage,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

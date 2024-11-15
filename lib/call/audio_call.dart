import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:talknest/viewmodel/services/firebaseservices/firebase_apis.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class ZegoCallPage extends StatefulWidget {
  final String callID;
  final String userName;
  final String image;

  const ZegoCallPage({
    Key? key,
    required this.callID,
    required this.image,
    required this.userName,
  }) : super(key: key);

  @override
  State<ZegoCallPage> createState() => _ZegoCallPageState();
}

class _ZegoCallPageState extends State<ZegoCallPage> {
  late String generatedCallId;

  Future<void> _initiateCall() async {
    final currentUser = FirebaseAuth.instance.currentUser!;
    generatedCallId = 'unique_call_id_${DateTime.now().millisecondsSinceEpoch}';
    await FirebaseApi().initiateCall(
      profileImage: widget.image,
      callerId: currentUser.uid,
      callerName: currentUser.displayName ?? 'Unknown',
      receiverId: widget.callID,
      receiverName: widget.userName,
      callId: generatedCallId,
    );
  }

  Future<void> _endCall(BuildContext context) async {
    await FirebaseApi().endCall(generatedCallId);
    Navigator.pop(context);
  }

  void _checkPermissions() async {
    var micPermission = await Permission.microphone.status;

    if (!micPermission.isGranted) {
      micPermission = await Permission.microphone.request();
    }

    if (!micPermission.isGranted) {
      print('Microphone permission not granted!');
      return;
    }

    print('Microphone permission granted!');
  }

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    _initiateCall();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            ZegoUIKitPrebuiltCall(
              appID: 1331380203,
              appSign:
                  "810bcb27312675e8092bb34e0c7724f9a756916248e573e4f3181b87f317bc79",
              userID: FirebaseAuth.instance.currentUser!.uid,
              userName: widget.userName,
              callID: widget.callID,
              config: ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall(),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              child: ElevatedButton(
                onPressed: () => _endCall(context),
                child: Text("End Call"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

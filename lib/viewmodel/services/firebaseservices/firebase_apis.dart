import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';
import 'package:talknest/call/audio_call.dart';
import 'package:talknest/helper/baseviewmodel/firebase_exceptions.dart';
import 'package:talknest/models/appuser.dart';
import 'package:talknest/models/group.dart';
import 'package:talknest/models/group_message.dart';
import 'package:talknest/models/message.dart';
import 'package:talknest/utils/routes/export_file.dart';
import 'package:uuid/uuid.dart';

class FirebaseApi {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final AppFirebaseExceptions _appFirebaseExceptions = AppFirebaseExceptions();
  static const uuid = Uuid();

  ///***************** Authentication  work  *****************///
  Future registerWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      log("User registered: ${userCredential.user?.email}");
      return "successfully";
    } on FirebaseAuthException catch (e) {
      _appFirebaseExceptions.handleFirebaseAuthException(e);
      log("Error: ${e.message}");
      return e.message;
    } catch (e) {
      log("Error: $e");
      return null;
    }
  }

  Future<String> signInWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      log("User signed in: ${userCredential.user?.email}");
      return "successfully";
    } on FirebaseAuthException catch (e) {
      _appFirebaseExceptions.handleFirebaseAuthException(e);
      return e.message ?? "An unknown error occurred.";
    } catch (e) {
      log("Error: $e");
      return "An unexpected error occurred.";
    }
  }

  Future signOut() async {
    try {
      await _auth.signOut();
      log("User signed out");
      return "successfully";
    } catch (e) {
      log("error in catch: $e");
      return "fail";
    }
  }

  Future checkLoginStatus() async {
    User? user = _auth.currentUser;
    if (user != null) {
      return true;
    } else {
      return false;
    }
  }

  ///*****************firestore work *****************///

  /// user functions/////////

  Future createUser({required String email, required String name}) async {
    try {
      AppUser appUser = AppUser(
        id: _auth.currentUser!.uid,
        name: name,
        profileImage: '',
        email: email,
        about: 'Hi, I am new to Talknest.',
        createdAt: DateTime.now(),
        lastOnline: DateTime.now(),
        status: false,
      );
      await _firestore
          .collection('appuser')
          .doc(_auth.currentUser!.uid)
          .set(appUser.toJson());
      return "successfully";
    } on FirebaseAuthException catch (e) {
      _appFirebaseExceptions.handleFirebaseAuthException(e);
      log("Error: ${e.message}");
      return e.message;
    } catch (e) {
      log("Error: $e");
      return null;
    }
  }

  /// Fetch user data from Firestore
  Future<AppUser?> getUserData() async {
    try {
      String uid = _auth.currentUser!.uid;
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('appuser').doc(uid).get();
      if (snapshot.exists) {
        AppUser appUser = AppUser.fromJson(snapshot.data()!);
        return appUser;
      } else {
        log("User data not found for UID: $uid");
        return null;
      }
    } on FirebaseAuthException catch (e) {
      _appFirebaseExceptions.handleFirebaseAuthException(e);
      log("Error: ${e.message}");
      return null;
    } catch (e) {
      log("Error: $e");
      return null;
    }
  }

  Stream<AppUser?> getUserStatus({required String userId}) {
    try {
      return _firestore
          .collection('appuser')
          .doc(userId)
          .snapshots()
          .map((snapshot) {
        if (snapshot.exists && snapshot.data() != null) {
          return AppUser.fromJson(snapshot.data()!);
        } else {
          return null; // Handle cases where data doesn't exist
        }
      });
    } catch (e) {
      log("Error in catch: $e");
      return Stream.value(
          null); // Return a stream with null in case of an error
    }
  }

  /// Fetch user data from Firestore
  Future<List<AppUser>?> getAllUser() async {
    try {
      String currentUserId = _auth.currentUser!.uid;

      QuerySnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('appuser').get();

      List<AppUser> users = snapshot.docs
          .map((doc) => AppUser.fromJson(doc.data()))
          .where((user) => user.id != currentUserId)
          .toList();

      return users;
    } on FirebaseAuthException catch (e) {
      _appFirebaseExceptions.handleFirebaseAuthException(e);
      log("Error: ${e.message}");
      return null;
    } catch (e) {
      log("Error: $e");
      return null;
    }
  }

  Future updateImage({image}) async {
    await _firestore
        .collection("appuser")
        .doc(_auth.currentUser!.uid)
        .update({"profile_image": image});
  }

  Future updateProfile({about, name}) async {
    await _firestore
        .collection("appuser")
        .doc(_auth.currentUser!.uid)
        .update({"about": about, "name": name});
  }

// Function to generate room ID
  String generateRoomId(String targetUserId) {
    final currentUserId = _auth.currentUser!.uid;
    return currentUserId.hashCode > targetUserId.hashCode
        ? currentUserId + targetUserId
        : targetUserId + currentUserId;
  }

  Stream<QuerySnapshot> initializeMessages(String targetUserId) {
    final roomId = generateRoomId(targetUserId);
    return _firestore
        .collection('chats')
        .doc(roomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> sendMessage({
    required String targetUserId,
    required String messageText,
    String? imageUrl,
  }) async {
    try {
      final roomId = generateRoomId(targetUserId);
      final messageId = uuid.v4();
      final senderId = _auth.currentUser!.uid;
      final senderName = (await getUserData())?.name ?? "Unknown";

      // Determine the message type
      String messageType = imageUrl != null ? 'image' : 'text';

      // Create the message data
      final message = Message(
        readStatus: false,
        senderName: senderName,
        messageId: messageId,
        messageText: messageText,
        imageUrl: imageUrl,
        receiverId: targetUserId,
        senderId: senderId,
        timestamp: Timestamp.now(),
        messageType: messageType,
      );

      // Send the message to Firestore
      await _firestore
          .collection('chats')
          .doc(roomId)
          .collection('messages')
          .doc(messageId)
          .set(message.toMap());

      // Update the chat room with the latest message
      await _firestore.collection('chats').doc(roomId).set({
        'lastMessage': messageText.isEmpty ? 'Image' : messageText,
        'timestamp': Timestamp.now(),
        'users': [senderId, targetUserId],
        'lastSenderName': senderName,
        'lastMessageType': messageType,
      }, SetOptions(merge: true));

      log("Message sent to $targetUserId");
    } catch (e) {
      log('Error in sendMessage: $e');
    }
  }

  Future<void> sendAudioMessage({
    required String targetUserId,
    required String audioFilePath,
    required String duration,
  }) async {
    try {
      log("debug");
      final roomId = generateRoomId(targetUserId);
      final messageId = uuid.v4();
      final senderId = _auth.currentUser!.uid;
      final senderName = (await getUserData())?.name ?? "Unknown";

      // Upload audio file to Firebase Storage
      String fileName = basename(audioFilePath);
      Reference ref = _storage
          .ref()
          .child('audio_messages/${_auth.currentUser!.uid}/$fileName');
      UploadTask uploadTask = ref.putFile(File(audioFilePath));
      TaskSnapshot taskSnapshot = await uploadTask;
      String audioUrl = await taskSnapshot.ref.getDownloadURL();

      // Create and store the audio message
      final message = Message(
        readStatus: false,
        senderName: senderName,
        messageId: messageId,
        messageType: "audio",
        messageText: "",
        imageUrl: null,
        receiverId: targetUserId,
        senderId: senderId,
        timestamp: Timestamp.now(),
      );
      await _firestore
          .collection('chats')
          .doc(roomId)
          .collection('messages')
          .doc(messageId)
          .set({
        ...message.toMap(),
        'audio_url': audioUrl,
        'duration': duration,
        'message_type': 'audio',
      });

      // Update chat room with the latest message details
      await _firestore.collection('chats').doc(roomId).set({
        'lastMessage': "Audio Message",
        'timestamp': Timestamp.now(),
        'users': [senderId, targetUserId],
        'lastSenderName': senderName,
        'lastMessageType': 'audio',
      }, SetOptions(merge: true));

      log("Audio message sent to $targetUserId");
    } catch (e) {
      log('Error in sendAudioMessage: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> getChatHistoryStream() async* {
    String currentUserId = _auth.currentUser!.uid;
    try {
      await for (QuerySnapshot chatRoomsSnapshot in _firestore
          .collection('chats')
          .where('users', arrayContains: currentUserId)
          .snapshots()) {
        List<Map<String, dynamic>> chatHistory = [];

        for (var doc in chatRoomsSnapshot.docs) {
          final roomId = doc.id;

          // Stream the last message in this chat room
          QuerySnapshot messageSnapshot = await _firestore
              .collection('chats')
              .doc(roomId)
              .collection('messages')
              .orderBy('timestamp', descending: true)
              .limit(1)
              .get();

          if (messageSnapshot.docs.isNotEmpty) {
            final messageData =
                messageSnapshot.docs.first.data() as Map<String, dynamic>;

            final targetUserId = messageData['receiver_id'] == currentUserId
                ? messageData['sender_id']
                : messageData['receiver_id'];

            // Fetch the target user's details
            DocumentSnapshot userSnapshot =
                await _firestore.collection('appuser').doc(targetUserId).get();

            if (userSnapshot.exists) {
              final userData = userSnapshot.data() as Map<String, dynamic>;
              chatHistory.add({
                "user": AppUser.fromJson(userData),
                "lastMessage": messageData['message'],
                "lastMessageTimestamp": messageData['timestamp'],
              });
            }
          }
        }
        yield chatHistory;
      }
    } catch (e) {
      log("Error fetching chat history: $e");
      yield [];
    }
  }

  void markMessagesAsRead(String receiverId) async {
    final roomId = generateRoomId(receiverId);

    final messagesRef = FirebaseFirestore.instance
        .collection('chats')
        .doc(roomId)
        .collection('messages');

    // Query all unread messages for the current user
    QuerySnapshot querySnapshot = await messagesRef
        .where('receiver_id', isEqualTo: _auth.currentUser!.uid)
        .where('read_status', isEqualTo: false)
        .get();

    // Use a batch to update all documents in a single request
    WriteBatch batch = FirebaseFirestore.instance.batch();
    for (var doc in querySnapshot.docs) {
      batch.update(messagesRef.doc(doc.id), {'read_status': true});
    }

    // Commit the batch
    await batch.commit();
  }

  Future<AppUser?> fetchCurrentUser() async {
    try {
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('appuser')
          .doc(currentUserId)
          .get();
      if (snapshot.exists) {
        return AppUser.fromJson(
            snapshot.data()!); // Convert document data to AppUser
      } else {
        log("User not found for ID: $currentUserId");
        return null;
      }
    } catch (e) {
      log("Error fetching current user: $e");
      return null;
    }
  }

  Future<void> createGroup({
    required String name,
    required List<AppUser> members,
    String? groupPic,
    String? info,
  }) async {
    try {
      // Fetch the creator (current user) from Firestore
      AppUser? creator = await fetchCurrentUser();
      if (creator == null)
        throw Exception("Failed to fetch the creator's details");

      // Generate a new group ID
      String groupId = FirebaseFirestore.instance.collection('groups').doc().id;

      // Ensure the creator is the first member in the list
      List<AppUser> updatedMembers = [
        creator,
        ...members.where((user) => user.id != creator.id)
      ];

      // Prepare member IDs from the updated members list
      List<String> memberIds = updatedMembers.map((user) => user.id).toList();

      // Create a Group instance with default lastMessage and createdAt fields
      Group newGroup = Group(
        id: groupId,
        name: name,
        lastMessage: '',
        groupPic: groupPic ?? '',
        info: info ?? '',
        createdBy: creator.id, // The creator's ID as the group creator
        createdAt: Timestamp.now(),
        members: memberIds,
      );

      // Add the group to Firestore
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .set(newGroup.toMap());

      log("Group created successfully with ID: $groupId");
    } catch (e) {
      log('Error creating group: $e');
      throw Exception('Failed to create group');
    }
  }

  Stream<List<Group>> getUserGroups() {
    String userId = _auth.currentUser!.uid;

    // Query groups where the current user is either a member or the creator
    return _firestore
        .collection('groups')
        .where('members', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Group.fromMap(doc.data())).toList();
    });
  }

  Future<void> sendGroupMessage({
    required String groupId,
    required String messageText,
    String? imageUrl,
  }) async {
    final messageId = uuid.v4();
    final senderId = _auth.currentUser!.uid;
    final senderName = (await getUserData())?.name ?? "Unknown";
    final messageType = imageUrl != null ? 'image' : 'text';

    final groupMessage = GroupMessage(
      id: messageId,
      senderId: senderId,
      senderName: senderName,
      text: messageText,
      imageUrl: imageUrl,
      messageType: messageType,
      readStatus: false,
      timestamp: Timestamp.now(),
    );

    await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .doc(messageId)
        .set(groupMessage.toMap());

    await _firestore.collection('groups').doc(groupId).update({
      'lastMessage': messageText.isEmpty ? 'Image' : messageText,
      'timestamp': Timestamp.now(),
      'lastSenderName': senderName,
      'lastMessageType': messageType,
    });
  }

  Stream<List<GroupMessage>> getGroupMessagesStream(String groupId) {
    return _firestore
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map(
              (doc) => GroupMessage.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  Future<List<AppUser>> getAllUsers() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('appuser').get();
      return snapshot.docs
          .map((doc) => AppUser.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      log("Error fetching users: $e");
      return [];
    }
  }

  /// Fetches group details by ID
  Future<Group?> getGroupById(String groupId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('groups').doc(groupId).get();
      if (doc.exists) {
        return Group.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      log("Error fetching group by ID: $e");
      return null;
    }
  }

  /// Adds a user to a group by updating the group's member list
  Future<void> addUserToGroup(String groupId, String userId) async {
    try {
      await _firestore.collection('groups').doc(groupId).update({
        'members': FieldValue.arrayUnion([userId]),
      });
      log("User $userId added to group $groupId");
    } catch (e) {
      log("Error adding user to group: $e");
    }
  }

  /// Removes a user from a group by updating the group's member list
  Future<void> removeUserFromGroup(String groupId, String userId) async {
    try {
      await _firestore.collection('groups').doc(groupId).update({
        'members': FieldValue.arrayRemove([userId]),
      });
      log("User $userId removed from group $groupId");
    } catch (e) {
      log("Error removing user from group: $e");
    }
  }

  /// Updates group details, including name, description, and image
  Future<void> updateGroupDetails(
      String groupId, String name, String description, String? imageUrl) async {
    try {
      final data = {
        'name': name,
        'info': description,
      };
      if (imageUrl != null) data['groupPic'] = imageUrl;

      await _firestore.collection('groups').doc(groupId).update(data);
      log("Group $groupId details updated successfully");
    } catch (e) {
      log("Error updating group details: $e");
    }
  }

  Future<AppUser?> getUserById(String userId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc =
          await _firestore.collection('appuser').doc(userId).get();
      if (doc.exists) {
        return AppUser.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      log("Error fetching user by ID: $e");
      return null;
    }
  }

  Future<void> initiateCall(
      {required String callerId,
      required String callerName,
      required String receiverId,
      required String receiverName,
      required String callId,
      required String profileImage}) async {
    try {
      await _firestore.collection('calls').doc(callId).set({
        'callerId': callerId,
        'callerName': callerName,
        'receiverId': receiverId,
        'receiverName': receiverName,
        'callId': callId,
        'status': 'ongoing',
        'profileImage': profileImage,
        'timestamp': DateTime.now(),
        'duration': 0, // Initial duration set to 0
      });
    } catch (e) {
      log('Error initiating call: $e');
    }
  }

  Future<void> endCall(String callId) async {
    try {
      final callDoc = await _firestore.collection('calls').doc(callId).get();
      if (!callDoc.exists) {
        log("Call document not found in Firestore");
        return;
      }

      final startTime = callDoc['timestamp'].toDate();
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime).inSeconds;

      await _firestore.collection('calls').doc(callId).update({
        'status': 'completed',
        'duration': duration,
      });
    } catch (e) {
      log('Error ending call: $e');
    }
  }

  Future<String?> getUserProfileImage(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('appuser').doc(userId).get();
      return userDoc['profileImage'] as String?;
    } catch (e) {
      log('Error fetching profile image: $e');
      return null;
    }
  }

  void listenForIncomingCalls(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    _firestore
        .collection('calls')
        .where('receiverId', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
      for (var docChange in snapshot.docChanges) {
        if (docChange.type == DocumentChangeType.added) {
          final callData = docChange.doc.data()!;
          showIncomingCallSnackbar(
              context, callData['callId'], callData['callerName'], "");
        }
      }
    });
  }

  void showIncomingCallSnackbar(BuildContext context, String callId,
      String callerName, String callerImage) {
    final scaffold = ScaffoldMessenger.of(context);

    scaffold.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(top: 10, left: 10, right: 10),
        backgroundColor: Colors.black,
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Incoming call from $callerName',
                style: TextStyle(color: Colors.white, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                scaffold.hideCurrentSnackBar();

                // Navigate to ZegoCallPage when the call is answered
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ZegoCallPage(
                      callID: callId,
                      userName: callerName,
                      image: callerImage,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Button background color
              ),
              child: const Text(
                'Answer',
                style: TextStyle(color: Colors.white), // Button text color
              ),
            ),
          ],
        ),
        duration: Duration(seconds: 30), // Keep the snackbar for 30 seconds
      ),
    );
  }

  ///***************** Storage  work  *****************///

// Function to upload an image to Firebase without video handling
  Future<String?> uploadImageToFirebase({
    required File imageFile,
    required String folderName,
  }) async {
    try {
      String fileName = basename(imageFile.path);
      // Create a reference for the image in the specified folder in the storage bucket
      Reference ref = _storage
          .ref()
          .child('users/${_auth.currentUser!.uid}/$folderName/$fileName');
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      log('Error uploading image: $e');
      return null;
    }
  }

  Future<String?> uploadImage(File imageFile) async {
    try {
      String fileName = basename(imageFile.path);
      Reference ref = _storage
          .ref()
          .child('chat_media/${_auth.currentUser!.uid}/images/$fileName');
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot taskSnapshot = await uploadTask;
      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      log('Error uploading image: $e');
      return null;
    }
  }
}

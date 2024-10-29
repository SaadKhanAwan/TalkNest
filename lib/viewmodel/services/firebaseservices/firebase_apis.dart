import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';
import 'package:talknest/helper/baseviewmodel/firebase_exceptions.dart';
import 'package:talknest/models/appuser.dart';
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
        status: 'active',
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

  /// Fetch user data from Firestore
  Future<List<AppUser>?> getAllUser() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('appuser').get();
      List<AppUser> users = snapshot.docs.map((doc) {
        return AppUser.fromJson(doc.data());
      }).toList();
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

  ///***************** Storage  work  *****************///

  Future<String?> uploadImageToFirebase(
      {required File imageFile, required String folderName}) async {
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

// Function to generate room ID
  String generateRoomId(String targetUserId) {
    final currentUserId = _auth.currentUser!.uid;
    return currentUserId.hashCode > targetUserId.hashCode
        ? currentUserId + targetUserId
        : targetUserId + currentUserId;
  }

// Function to send a message
  Future<void> sendMessage(
      {required String targetUserId, required String messageText}) async {
    final roomId = generateRoomId(targetUserId);
    final messageId = uuid.v4();
    final messageData = {
      'senderId': _auth.currentUser!.uid,
      'message': messageText,
      'timestamp': FieldValue.serverTimestamp(),
    };
    await _firestore
        .collection('chats')
        .doc(roomId)
        .collection('messages')
        .doc(messageId)
        .set(messageData);
  }
}

import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';

class FirebaseApi {
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
      if (e.code == 'invalid-email') {
        return "The email address is badly formatted.";
      } else if (e.code == 'email-already-in-use') {
        return "The email address is already in use.";
      } else if (e.code == 'weak-password') {
        return "The password provided is too weak.";
      }
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
      if (e.code == 'invalid-email') {
        return "The email address is badly formatted.";
      } else if (e.code == 'user-not-found') {
        return "No user found for that email.";
      } else if (e.code == 'wrong-password') {
        return "Wrong password provided.";
      }
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
}

import 'package:firebase_auth/firebase_auth.dart';

class AppFirebaseExceptions {
  String handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return "The email address is badly formatted.";
      case 'email-already-in-use':
        return "The email address is already in use.";
      case 'weak-password':
        return "The password provided is too weak.";
      case 'user-not-found':
        return "No user found for that email.";
      case 'wrong-password':
        return "Wrong password provided.";
      default:
        return e.message ?? "An unknown error occurred.";
    }
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppLifecycleHandler extends StatefulWidget {
  final Widget child;

  const AppLifecycleHandler({super.key, required this.child});

  @override
  State<AppLifecycleHandler> createState() => _AppLifecycleHandlerState();
}

class _AppLifecycleHandlerState extends State<AppLifecycleHandler>
    with WidgetsBindingObserver {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setUserOnlineStatus(true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App is in the foreground
      _setUserOnlineStatus(true);
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      // App is in the background or inactive
      _setUserOnlineStatus(false);
    } else if (state == AppLifecycleState.detached) {
      // App is terminated
      _setLastSeen();
    }
  }

  void _setUserOnlineStatus(bool isOnline) {
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      _firestore.collection('appuser').doc(userId).update({
        'status': isOnline,
        'last_online': FieldValue.serverTimestamp(),
      });
    }
  }

  void _setLastSeen() {
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      _firestore.collection('appuser').doc(userId).update({
        'status': false,
        'last_online': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

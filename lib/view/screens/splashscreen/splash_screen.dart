import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:talknest/config/images.dart';
import 'package:talknest/utils/routes/export_file.dart';
import 'package:talknest/viewmodel/services/firebaseservices/firebase_apis.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 2));

    await FirebaseApi().checkLoginStatus().then((value) {
      if (value == true) {
        Navigator.pushReplacementNamed(context, RouteNames.homeScreen);
      } else {
        Navigator.pushReplacementNamed(context, RouteNames.welcome);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SvgPicture.asset(MyImages.appicon),
      ),
    );
  }
}

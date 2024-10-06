import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:talknest/helper/baseviewmodel/baseviewmodel.dart';
import 'package:talknest/utils/dilogues.dart';
import 'package:talknest/utils/routes/route_name.dart';
import 'package:talknest/viewmodel/services/firebaseservices/firebase_apis.dart';

class AuthController extends BaseViewModel {
  final FirebaseApi _services = FirebaseApi();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool isLogin = true;

  toggleLogin() {
    isLogin = true;
    notifyListeners();
  }

  toggleSignUp() {
    isLogin = false;
    notifyListeners();
  }

  Future<void> signInWithEmailAndPassword(
      {required BuildContext context}) async {
    setstate(ViewState.loading);
    final result = await _services
        .signInWithEmailAndPassword(
      email: emailController.text,
      password: passwordController.text,
    )
        .then((value) {
      if (value == "successfully") {
        Dilogues.showSnackbar(context, message: "Login successfully.");
        Navigator.pushReplacementNamed(context, RouteNames.homeScreen);
        emailController.clear();
        passwordController.clear();
        setstate(ViewState.success);
      } else {
        Dilogues.showSnackbar(context, message: value);
        setstate(ViewState.fail);
      }
    });

    log("Result: $result");
  }

  Future<void> signUpWithEmailAndPassword(
      {required BuildContext context}) async {
    setstate(ViewState.loading);

    final result = await _services
        .registerWithEmailAndPassword(
      email: emailController.text,
      password: passwordController.text,
    )
        .then((value) {
      if (value == "successfully") {
        emailController.clear();
        passwordController.clear();
        setstate(ViewState.success);

        Dilogues.showSnackbar(context, message: "SingUp successfully.");
      } else {
        Dilogues.showSnackbar(context, message: value);
        setstate(ViewState.fail);
      }
    });
    log("Result: $result");
  }

 
}

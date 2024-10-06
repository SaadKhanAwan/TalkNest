import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:talknest/config/colors.dart';
import 'package:talknest/config/images.dart';
import 'package:talknest/helper/baseviewmodel/baseviewmodel.dart';
import 'package:talknest/responsiveness/sizes.dart';
import 'package:talknest/view/widgets/button.dart';
import 'package:talknest/view/widgets/textfield.dart';
import 'package:talknest/viewmodel/controller/auth/auth_controller.dart';

class Authscreen extends StatefulWidget {
  const Authscreen({super.key});

  @override
  State<Authscreen> createState() => _AuthscreenState();
}

class _AuthscreenState extends State<Authscreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthController(),
      builder: (context, child) {
        return Scaffold(
          body: Form(
            key: context.read<AuthController>().formKey,
            child: SafeArea(
                child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                  vertical: 30.0,
                  horizontal: ResponsiveSizes.width(context, .05)),
              child: Center(
                child: Column(
                  children: [
                    SvgPicture.asset(
                      MyImages.appicon,
                    ),
                    Text("Talk Nest",
                        style: Theme.of(context)
                            .textTheme
                            .headlineLarge
                            ?.copyWith(color: const Color(0xffFF9900))),
                    SizedBox(height: ResponsiveSizes.height(context, .08)),
                    Consumer<AuthController>(
                        builder: (context, provider, child) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 25),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color:
                                Theme.of(context).colorScheme.primaryContainer),
                        child: Column(
                          crossAxisAlignment: provider.isLogin
                              ? CrossAxisAlignment.start
                              : CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                InkWell(
                                  onTap: () {
                                    provider.toggleLogin();
                                  },
                                  child: Text(
                                    "Login",
                                    style: provider.isLogin
                                        ? Theme.of(context)
                                            .textTheme
                                            .headlineSmall
                                        : Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ),
                                InkWell(
                                    onTap: () {
                                      provider.toggleSignUp();
                                    },
                                    child: Text(
                                      "Signup",
                                      style: provider.isLogin == false
                                          ? Theme.of(context)
                                              .textTheme
                                              .headlineSmall
                                          : Theme.of(context)
                                              .textTheme
                                              .bodyLarge,
                                    ))
                              ],
                            ),
                            AnimatedContainer(
                              duration: const Duration(seconds: 1),
                              margin: const EdgeInsets.only(top: 8),
                              color: dhalforangeColor,
                              width: 140,
                              height: 3,
                            ),
                            provider.isLogin
                                ? buildLoginView()
                                : buildSignupView()
                          ],
                        ),
                      );
                    })
                  ],
                ),
              ),
            )),
          ),
        );
      },
    );
  }

  Widget buildLoginView() {
    return Consumer<AuthController>(builder: (context, provider, child) {
      return Column(
        children: [
          ResponsiveSizes.verticalSizebox(context, .03),
          CustomTextField(
            validator: (value) {
              if (value!.isEmpty) {
                return "Please enter email";
              }
              String emailPattern = r'^[^@]+@[^@]+\.[^@]+';
              RegExp regex = RegExp(emailPattern);
              if (!regex.hasMatch(value)) {
                return "Please enter a valid email address";
              }
              return null;
            },
            controller: provider.emailController,
            hintText: "Email",
            prefixIcon: Icons.alternate_email_outlined,
          ),
          ResponsiveSizes.verticalSizebox(context, .03),
          CustomTextField(
            validator: (value) {
              if (value!.isEmpty) {
                return "Please enter password";
              }

              return null;
            },
            controller: provider.passwordController,
            hintText: "Password",
            prefixIcon: Icons.password_outlined,
          ),
          ResponsiveSizes.verticalSizebox(context, .05),
          provider.state == ViewState.loading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                )
              : CustomButton(
                  label: "Login",
                  onPressed: () async {
                    if (provider.isLogin == true) {
                      if (provider.formKey.currentState!.validate()) {
                        await provider.signInWithEmailAndPassword(
                            context: context);
                      }
                    }
                  })
        ],
      );
    });
  }

  Widget buildSignupView() {
    return Consumer<AuthController>(builder: (context, provider, child) {
      return Column(
        children: [
          ResponsiveSizes.verticalSizebox(context, .03),
          const CustomTextField(
            hintText: "Full Name",
            prefixIcon: Icons.person,
          ),
          ResponsiveSizes.verticalSizebox(context, .03),
          CustomTextField(
            validator: (value) {
              if (value!.isEmpty) {
                return "Please enter email";
              }
              String emailPattern = r'^[^@]+@[^@]+\.[^@]+';
              RegExp regex = RegExp(emailPattern);
              if (!regex.hasMatch(value)) {
                return "Please enter a valid email address";
              }
              return null;
            },
            controller: provider.emailController,
            hintText: "Email",
            prefixIcon: Icons.alternate_email_outlined,
          ),
          ResponsiveSizes.verticalSizebox(context, .03),
          CustomTextField(
            validator: (value) {
              if (value!.isEmpty) {
                return "Please enter password";
              }
              return null;
            },
            controller: provider.passwordController,
            hintText: "Password",
            prefixIcon: Icons.password_outlined,
          ),
          ResponsiveSizes.verticalSizebox(context, .05),
          provider.state == ViewState.loading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                )
              : CustomButton(
                  label: "SignUp",
                  onPressed: () async {
                    if (provider.isLogin == false) {
                      if (provider.formKey.currentState!.validate()) {
                        await provider.signUpWithEmailAndPassword(
                            context: context);
                      }
                    }
                  })
        ],
      );
    });
  }
}

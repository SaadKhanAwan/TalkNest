import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:talknest/config/colors.dart';
import 'package:talknest/config/images.dart';
import 'package:talknest/responsiveness/sizes.dart';
import 'package:talknest/utils/routes/export_file.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Padding(
        padding: EdgeInsets.symmetric(
            vertical: 30.0, horizontal: ResponsiveSizes.width(context, .08)),
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
                      ?.copyWith(color: dhalforangeColor)),
              SizedBox(height: ResponsiveSizes.height(context, .09)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(MyImages.boyPic),
                  SvgPicture.asset(
                    MyImages.connect,
                  ),
                  Image.asset(MyImages.girlPic),
                ],
              ),
              ResponsiveSizes.verticalSizebox(context, .03),
              Text("Now You Are",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface)),
              Text("Connected",
                  style: Theme.of(context)
                      .textTheme
                      .headlineLarge
                      ?.copyWith(color: dhalforangeColor)),
              Text(
                  "Perfect solution of connexct with anyone easly and more secure",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelLarge),
              ResponsiveSizes.verticalSizebox(context, .19),
              SlideAction(
                text: "Slider to start now",
                textStyle: Theme.of(context).textTheme.labelLarge,
                onSubmit: () async {
                  Navigator.pushReplacementNamed(context, RouteNames.auth);
                },
                sliderButtonIcon: SvgPicture.asset(
                  MyImages.plugicon,
                ),
                innerColor: Theme.of(context).colorScheme.primary,
                outerColor: Theme.of(context).colorScheme.primaryContainer,
              )
            ],
          ),
        ),
      )),
    );
  }
}

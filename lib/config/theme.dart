import 'package:flutter/material.dart';
import 'package:talknest/config/colors.dart';

ThemeData lightTheme = ThemeData();
ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
        primary: dprimaryColor,
        onPrimary: donBackgroundColor,
        surface: dbackgroundColor,
        onSurface: donBackgroundColor,
        primaryContainer: dContainerColor,
        onPrimaryContainer: dContainerColor),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
          fontSize: 32,
          color: dprimaryColor,
          fontFamily: "Poppins",
          fontWeight: FontWeight.w800),
      headlineMedium: TextStyle(
          fontSize: 30,
          color: donBackgroundColor,
          fontFamily: "Poppins",
          fontWeight: FontWeight.w600),
      headlineSmall: TextStyle(
          fontSize: 20,
          color: donBackgroundColor,
          fontFamily: "Poppins",
          fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(
          fontSize: 18,
          color: donBackgroundColor,
          fontFamily: "Poppins",
          fontWeight: FontWeight.w500),
      bodyMedium: TextStyle(
          fontSize: 15,
          color: donBackgroundColor,
          fontFamily: "Poppins",
          fontWeight: FontWeight.w400),
      labelLarge: TextStyle(
          fontSize: 15,
          color: donContainerColor,
          fontFamily: "Poppins",
          fontWeight: FontWeight.w400),
      labelMedium: TextStyle(
          fontSize: 12,
          color: donContainerColor,
          fontFamily: "Poppins",
          fontWeight: FontWeight.w400),
      labelSmall: TextStyle(
          fontSize: 10,
          color: donContainerColor,
          fontFamily: "Poppins",
          fontWeight: FontWeight.w300),
    ));

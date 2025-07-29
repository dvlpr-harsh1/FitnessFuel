import 'package:fitnessfuel/utils/my_color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData themeData = ThemeData(
    scaffoldBackgroundColor: MyColor.background,
    appBarTheme: AppBarTheme(
      backgroundColor: MyColor.background,
      centerTitle: false,
    ),
    // textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme)
    //     .copyWith(
    //       displayLarge: GoogleFonts.poppins(color: Colors.white, fontSize: 40),
    //     ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: MyColor.black,
          width: 2,
        ), // Increased width
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: MyColor.black,
          width: 2,
        ), // Increased width
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: MyColor.black,
          width: 2,
        ), // Increased width
      ),
    ),
  );
}

import 'package:fitnessfuel/main.dart';
import 'package:fitnessfuel/responsive/screen_dimention.dart';
import 'package:fitnessfuel/utils/my_color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnimImage {
  Widget animatedImage({
    required String title,
    required String description,
    Image? image,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: mq.width * .1),
      width: mq.width,
      // color: Colors.redAccent,
      height: mq.width > webScreenSize ? 650 : 250,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                      color: MyColor.black.withOpacity(.6),
                      fontSize: mq.width > webScreenSize ? 60 : 30,
                      fontWeight: FontWeight.w800),
                ),
                SizedBox(
                  height: mq.width > webScreenSize ? 18 : 8,
                ),
                Text(
                  description,
                  maxLines: mq.width > webScreenSize ? 7 : 4,
                  style: GoogleFonts.poppins(
                      color: MyColor.black.withOpacity(.8),
                      fontSize: mq.width > webScreenSize ? 20 : 14),
                ),
              ],
            ),
          ),
          Flexible(
              flex: 2,
              child: Container(
                color: Colors.amber,
              ))
        ],
      ),
    );
  }
}

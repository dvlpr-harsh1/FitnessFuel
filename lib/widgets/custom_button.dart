import 'package:fitnessfuel/main.dart';
import 'package:fitnessfuel/utils/my_color.dart';
import 'package:flutter/material.dart';

class CustomButton {
  custButton({required String text, required Function() onTap}) {
    return Material(
      borderRadius: BorderRadius.circular(10),
      color: MyColor.black,
      child: InkWell(
        splashColor: Colors.transparent,
        splashFactory: InkRipple.splashFactory,
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          width: mq.width,
          height: 40,
          child: Text(
            text,
            style: TextStyle(color: MyColor.background, fontSize: 18),
          ),
        ),
      ),
    );
  }
}

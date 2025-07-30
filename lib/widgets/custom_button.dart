import 'package:fitnessfuel/main.dart';
import 'package:fitnessfuel/utils/my_color.dart';
import 'package:flutter/material.dart';

class CustomButton {
  custButton({required Widget labelWidget, required Function() onTap}) {
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
          child: labelWidget
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fitnessfuel/view/auth/login_page.dart';
import 'package:fitnessfuel/view/pages/home_page.dart';
import 'package:flutter/material.dart';

class SplashServices {
  final _auth = FirebaseAuth.instance;

  Future<void> splash(BuildContext context) async {
    final user = _auth.currentUser;

    Timer(Duration(seconds: 3), () {
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => Home()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LogInPage()),
        );
      }
    });
  }
}

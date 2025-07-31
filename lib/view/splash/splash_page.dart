import 'package:fitnessfuel/services/splash_services.dart';
import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  SplashServices splashServices = SplashServices();
  @override
  void initState() {
    // TODO: implement initState
    splashServices.splash(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/images/logo.jpg',
          height: 200,
          // width: 200,
        ),
      ),
    );
  }
}

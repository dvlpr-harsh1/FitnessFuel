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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Fitness',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                fontSize: 90,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'Fuel',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                fontSize: 90,
                color: Colors.redAccent,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

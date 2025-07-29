import 'package:firebase_core/firebase_core.dart';
import 'package:fitnessfuel/firebase_options.dart';
import 'package:fitnessfuel/provider/auth_provider.dart';
import 'package:fitnessfuel/provider/home_provider.dart';
import 'package:fitnessfuel/utils/theme.dart';
import 'package:fitnessfuel/view/auth/login_page.dart';
import 'package:fitnessfuel/view/splash/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthController()),
        ChangeNotifierProvider(create: (context) => HomeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

late Size mq;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData,
      home: SplashPage(),
    );
  }
}

import 'package:fitnessfuel/Home.dart';
import 'package:fitnessfuel/main.dart';
import 'package:fitnessfuel/provider/auth_provider.dart';
import 'package:fitnessfuel/view/pages/home_page.dart';
import 'package:fitnessfuel/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LogInPage extends StatefulWidget {
  const LogInPage({super.key});

  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  final emailController = TextEditingController();
  final passController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthController>(context);
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 900;

    void showError(String msg) {
      if (!isWide) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: Colors.black87,
            title: const Text('Error', style: TextStyle(color: Colors.white)),
            content: Text(msg, style: const TextStyle(color: Colors.white70)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
        );
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              children: [
                /// 🅰️ Title Branding
                RichText(
                  text: TextSpan(
                    text: 'Fitness',
                    style: TextStyle(
                      fontSize: isWide ? 48 : 34,
                      color: Theme.of(context).colorScheme.onBackground,
                      fontWeight: FontWeight.w600,
                    ),
                    children: [
                      TextSpan(
                        text: 'Fuel',
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                /// 🔒 Form Box
                Container(
                  width: isWide ? 450 : double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 30,
                    horizontal: 24,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        auth.isCreateAccountPage
                            ? 'Create Admin'
                            : 'Login to Admin Panel',
                        style: TextStyle(
                          fontSize: isWide ? 30 : 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),

                      if (auth.errorMessage != null)
                        Text(
                          auth.errorMessage!,
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      const SizedBox(height: 10),

                      Text('Email', style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: emailController,
                        style: TextStyle(color: Colors.white),
                        decoration: inputDecoration("Enter your email"),
                      ),

                      const SizedBox(height: 20),
                      Text('Password', style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: passController,
                        style: TextStyle(color: Colors.white),
                        obscureText: true,
                        decoration: inputDecoration("Enter your password"),
                      ),

                      const SizedBox(height: 30),

                      if (auth.isLoading)
                        const Center(
                          child: CircularProgressIndicator(
                            color: Colors.redAccent,
                          ),
                        )
                      else
                        CustomButton().custButton(
                          context: context, // context is now required and first
                          labelWidget: Text(
                            auth.isCreateAccountPage
                                ? 'Create Account'
                                : 'Log In',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onTap: () async {
                            final email = emailController.text.trim();
                            final pass = passController.text.trim();

                            if (email.isEmpty || pass.isEmpty) {
                              showError("Email and password required.");
                              return;
                            }

                            final success = auth.isCreateAccountPage
                                ? await auth.createAdmin(
                                    email: email,
                                    pass: pass,
                                  )
                                : await auth.adminLogin(
                                    email: email,
                                    pass: pass,
                                  );

                            if (success) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => Home()),
                              );
                            } else if (auth.errorMessage != null) {
                              showError(auth.errorMessage!);
                            }
                          },
                        ),

                      const SizedBox(height: 20),

                      Center(
                        child: TextButton(
                          onPressed: auth.toggleCreateAccountPage,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.redAccent,
                            textStyle: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          child: Text(
                            auth.isCreateAccountPage
                                ? 'Back to Login'
                                : 'Create Admin Account',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
                const Text(
                  '© 2025 FitnessFuel | All rights reserved',
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: Theme.of(context).hintColor),
    filled: true,
    fillColor: Theme.of(context).cardColor,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Theme.of(context).dividerColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
    ),
  );
}

import 'package:fitnessfuel/Home.dart';
import 'package:fitnessfuel/main.dart';
import 'package:fitnessfuel/provider/auth_provider.dart';
import 'package:fitnessfuel/responsive/screen_dimention.dart';
import 'package:fitnessfuel/utils/my_color.dart';
import 'package:fitnessfuel/view/footer/footer.dart';
import 'package:fitnessfuel/view/pages/home_page.dart';
import 'package:fitnessfuel/widgets/custom_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    final _authProvider = Provider.of<AuthController>(context);
    Footer footer = Footer();
    CustomButton customButton = CustomButton();

    void showError(String msg) {
      if (MediaQuery.of(context).size.width <= 900) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Error'),
            content: Text(msg),
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
          SnackBar(content: Text(msg), backgroundColor: Colors.red),
        );
      }
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        elevation: 0,
        toolbarHeight: mq.width > webScreenSize
            ? mq.height * .1
            : mq.height * .1,
        centerTitle: true,
        title: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => Home()),
              );
            },
            child: Text(
              'FitnessFuel',
              style: mq.width > webScreenSize
                  ? TextStyle(fontSize: 36)
                  : TextStyle(fontSize: 26),
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(4.0),
          child: Container(color: MyColor.borderColor, height: 2),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ///Login Form
              Container(
                width: mq.width,
                color: MyColor.lightOrange.withOpacity(.8),
                child: Center(
                  child: Container(
                    margin: EdgeInsets.only(
                      top: 50,
                      bottom: mq.width > webScreenSize ? 150 : 50,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: mq.width > webScreenSize
                          ? mq.width * .020
                          : mq.width * .05,
                      vertical: 40,
                    ),
                    width: mq.width > webScreenSize ? 450 : mq.width * .9,
                    decoration: BoxDecoration(
                      color: MyColor.background,
                      border: Border(
                        top: BorderSide(color: MyColor.black, width: 2),
                        bottom: BorderSide(color: MyColor.black, width: 7),
                        left: BorderSide(width: 2, color: MyColor.black),
                        right: BorderSide(width: 2, color: MyColor.black),
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _authProvider.isCreateAccountPage
                                ? 'Create Admin'
                                : 'Login',
                            style: TextStyle(
                              fontSize: mq.width > webScreenSize ? 46 : 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 15),

                        // Error message
                        if (_authProvider.errorMessage != null &&
                            mq.width > 900)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text(
                              _authProvider.errorMessage!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 15,
                              ),
                            ),
                          ),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Email', style: TextStyle(fontSize: 16)),
                        ),
                        SizedBox(height: 5),
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          textInputAction: TextInputAction.next,
                          onChanged: (_) =>
                              setState(() {}), // Ensures UI re-renders
                          decoration: InputDecoration(
                            hintText: "Enter your email",
                          ),
                        ),

                        SizedBox(height: 15),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Password',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        SizedBox(height: 5),
                        TextField(
                          controller: passController,
                          obscureText: true,
                          autofillHints: const [AutofillHints.password],
                          textInputAction: TextInputAction.done,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: "Enter your password",
                          ),
                        ),

                        SizedBox(height: 30),

                        if (_authProvider.isLoading)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            ),
                          ),

                        ///Login/Create Account Button
                        if (!_authProvider.isCreateAccountPage)
                          customButton.custButton(
                            labelWidget: _authProvider.isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.2,
                                    ),
                                  )
                                : Text(
                                    'Log In',
                                    style: TextStyle(
                                      color: MyColor.background,
                                      fontSize: 18,
                                    ),
                                  ),
                            onTap: () async {
                              FocusScope.of(context).unfocus();
                              final email = emailController.text.trim();
                              final pass = passController.text.trim();

                              if (email.isEmpty || pass.isEmpty) {
                                showError("Email and password required.");
                                return;
                              }

                              try {
                                final success = await _authProvider.adminLogin(
                                  email: email,
                                  pass: pass,
                                );
                                if (success) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (_) => Home()),
                                  );
                                } else if (_authProvider.errorMessage != null) {
                                  showError(_authProvider.errorMessage!);
                                }
                              } catch (e) {
                                showError("Login failed. Please try again.");
                              }
                            },
                          ),
                        if (!_authProvider.isCreateAccountPage)
                          SizedBox(height: 15),
                        if (!_authProvider.isCreateAccountPage)
                          customButton.custButton(
                            labelWidget: Text(
                              'Create Account',
                              style: TextStyle(
                                color: MyColor.background,
                                fontSize: 18,
                              ),
                            ),
                            onTap: () {
                              _authProvider.toggleCreateAccountPage();
                            },
                          ),
                        if (_authProvider.isCreateAccountPage)
                          customButton.custButton(
                            labelWidget: _authProvider.isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.2,
                                    ),
                                  )
                                : Text(
                                    'Create Account',
                                    style: TextStyle(
                                      color: MyColor.background,
                                      fontSize: 18,
                                    ),
                                  ),
                            onTap: () async {
                              FocusScope.of(context).unfocus();
                              final email = emailController.text.trim();
                              final pass = passController.text.trim();
                              if (email.isEmpty || pass.isEmpty) {
                                showError("Email and password required.");
                                return;
                              }
                              try {
                                final success = await _authProvider.createAdmin(
                                  email: email,
                                  pass: pass,
                                );
                                if (success) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (_) => Home()),
                                  );
                                } else if (_authProvider.errorMessage != null) {
                                  showError(_authProvider.errorMessage!);
                                }
                              } catch (e) {
                                showError("Sign up failed. Please try again.");
                              }
                            },
                          ),
                        if (_authProvider.isCreateAccountPage)
                          SizedBox(height: 15),
                        if (_authProvider.isCreateAccountPage)
                          customButton.custButton(
                            labelWidget: _authProvider.isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.2,
                                    ),
                                  )
                                : Text(
                                    'Log In',
                                    style: TextStyle(
                                      color: MyColor.background,
                                      fontSize: 18,
                                    ),
                                  ),
                            onTap: () {
                              _authProvider.toggleCreateAccountPage();
                            },
                          ),
                        SizedBox(height: 15),
                        if (!_authProvider.isCreateAccountPage)
                          TextButton(
                            style: ButtonStyle(
                              overlayColor: MaterialStateColor.resolveWith(
                                (states) => Colors.transparent,
                              ),
                            ),
                            onPressed: () {},
                            child: Text(
                              'Forgot your password?',
                              style: TextStyle(
                                color: MyColor.black,
                                fontSize: 16,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              ///Footer
              footer,
            ],
          ),
        ),
      ),
    );
  }
}

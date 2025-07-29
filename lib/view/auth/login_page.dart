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

class LogInPage extends StatelessWidget {
  const LogInPage({super.key});

  @override
  Widget build(BuildContext context) {
    final _authProvider = Provider.of<AuthController>(context);
    Footer footer = Footer();
    CustomButton customButton = CustomButton();
    TextEditingController _emailController = TextEditingController();
    TextEditingController _passController = TextEditingController();

    return Scaffold(
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
        // actions: [
        //   Container(
        //     alignment: Alignment.center,
        //     padding: mq.width > webScreenSize
        //         ? EdgeInsets.symmetric(horizontal: mq.width * .02)
        //         : EdgeInsets.only(left: mq.width * .05, right: mq.width * .05),
        //     child: MouseRegion(
        //       cursor: SystemMouseCursors.click,
        //       child: IconButton(
        //         hoverColor: Colors.transparent,
        //         onPressed: () {},
        //         icon: Icon(
        //           CupertinoIcons.cart,
        //           size: mq.width > webScreenSize ? 30 : 28,
        //         ),
        //       ),
        //     ),
        //   ),
        // ],
        // Add bottom border
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(4.0),
          child: Container(color: MyColor.borderColor, height: 2),
        ),
      ),
      body: SingleChildScrollView(
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
                      if (_authProvider.errorMessage != null)
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
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        decoration: const InputDecoration(
                          hintText: "Enter your email",
                        ),
                      ),
                      SizedBox(height: 15),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Password', style: TextStyle(fontSize: 16)),
                      ),
                      SizedBox(height: 5),
                      TextField(
                        controller: _passController,
                        obscureText: true,
                        autofillHints: const [AutofillHints.password],
                        decoration: const InputDecoration(
                          hintText: "Enter your password",
                        ),
                      ),
                      SizedBox(height: 30),

                      // Loading indicator
                      if (_authProvider.isLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: CircularProgressIndicator(),
                        ),

                      ///Login/Create Account Button
                      if (!_authProvider.isCreateAccountPage)
                        customButton.custButton(
                          text: 'Log In',
                          onTap: () async {
                            FocusScope.of(context).unfocus();
                            final email = _emailController.text.trim();
                            final pass = _passController.text.trim();
                            if (email.isEmpty || pass.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Email and password required."),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }
                            final success = await _authProvider.adminLogin(
                              email: email,
                              pass: pass,
                            );
                            if (success) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => Home()),
                              );
                            }
                            // Navigator.pushReplacement(
                            //   context,
                            //   MaterialPageRoute(builder: (_) => Home()),
                            // );
                          },
                        ),
                      if (!_authProvider.isCreateAccountPage)
                        SizedBox(height: 15),
                      if (!_authProvider.isCreateAccountPage)
                        customButton.custButton(
                          text: 'Create Admin',
                          onTap: () {
                            _authProvider.toggleCreateAccountPage();
                          },
                        ),
                      if (_authProvider.isCreateAccountPage)
                        customButton.custButton(
                          text: 'Create Admin',
                          onTap: () async {
                            FocusScope.of(context).unfocus();
                            final email = _emailController.text.trim();
                            final pass = _passController.text.trim();
                            if (email.isEmpty || pass.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Email and password required."),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }
                            final success = await _authProvider.createAdmin(
                              email: email,
                              pass: pass,
                            );
                            if (success) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => Home()),
                              );
                            }
                          },
                        ),
                      if (_authProvider.isCreateAccountPage)
                        SizedBox(height: 15),
                      if (_authProvider.isCreateAccountPage)
                        customButton.custButton(
                          text: 'Back to Login',
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
    );
  }
}

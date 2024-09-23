import 'package:flutter/material.dart';
import 'package:koukoku_business/COMPONENTS/button_view.dart';
import 'package:koukoku_business/COMPONENTS/image_view.dart';
import 'package:koukoku_business/COMPONENTS/main_view.dart';
import 'package:koukoku_business/COMPONENTS/padding_view.dart';
import 'package:koukoku_business/COMPONENTS/text_view.dart';
import 'package:koukoku_business/COMPONENTS/textfield_view.dart';
import 'package:koukoku_business/FUNCTIONS/colors.dart';
import 'package:koukoku_business/FUNCTIONS/nav.dart';
import 'package:koukoku_business/MODELS/DATAMASTER/datamaster.dart';
import 'package:koukoku_business/MODELS/firebase.dart';
import 'package:koukoku_business/MODELS/screen.dart';
import 'package:koukoku_business/VIEWS/analytics.dart';

class Login extends StatefulWidget {
  final DataMaster dm;
  const Login({super.key, required this.dm});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  //
  void onLogIn() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        widget.dm.alertMissingInfo();
      });
      return;
    }

    setState(() {
      widget.dm.setToggleLoading(true);
    });
    final user = await auth_SignIn(
        _emailController.text, _passwordController.text, 'Businesses');
    if (user != null) {
      print(user);
      final signedIn = await widget.dm.checkUser('Businesses');
      if (signedIn) {
        setState(() {
          widget.dm.setToggleLoading(false);
        });
        nav_PushAndRemove(context, Analytics(dm: widget.dm));
      }
    } else {
      setState(() {
        widget.dm.setToggleLoading(false);
        widget.dm.alertSomethingWrong();
      });
    }
  }

  void init() async {
    setState(() {
      widget.dm.setToggleLoading(true);
    });
    final signedIn = await widget.dm.checkUser('Businesses');
    if (signedIn) {
      setState(() {
        widget.dm.setToggleLoading(false);
      });
      nav_PushAndRemove(context, Analytics(dm: widget.dm));
      return;
    }
    //
    setState(() {
      widget.dm.setToggleLoading(false);
    });
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  //
  @override
  Widget build(BuildContext context) {
    return MainView(dm: widget.dm, children: [
      ImageView(
        imagePath: 'assets/logo.png',
        width: getWidth(context) * 0.75,
        height: getWidth(context) * 0.75,
      ),
      TextView(
        text: 'Ads without problems.',
        weight: FontWeight.w600,
        spacing: -1,
        size: 24,
      ),
      Spacer(),
      PaddingView(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextView(
                text: 'Login',
                size: 44,
                weight: FontWeight.w800,
                spacing: -1,
              ),
              TextView(
                text: 'Use the same login as the web-portal.',
                size: 16,
              ),
            ],
          ),
        ),
      ),
      PaddingView(
        child: Column(
          children: [
            TextfieldView(
              controller: _emailController,
              placeholder: 'Email',
              keyboardType: TextInputType.emailAddress,
              backgroundColor: hexToColor("#F6F8FA"),
            ),
            SizedBox(
              height: 10,
            ),
            TextfieldView(
              controller: _passwordController,
              isPassword: true,
              placeholder: 'Password',
              backgroundColor: hexToColor("#F6F8FA"),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ButtonView(
                  child: TextView(
                    text: 'forgot password?',
                    size: 16,
                  ),
                  onPress: () async {
                    final succ =
                        await auth_ForgotPassword(_emailController.text);
                    if (succ) {
                      setState(() {
                        widget.dm.setToggleAlert(true);
                        widget.dm.setAlertTitle('Email sent.');
                        widget.dm.setAlertText(
                            'A reset password link has been sent to your email.');
                      });
                    } else {
                      setState(() {
                        widget.dm.setToggleAlert(true);
                        widget.dm.setAlertTitle("Missing Email");
                        widget.dm.setAlertText(
                            'Please enter your email address to receive a link to reset your password.');
                      });
                    }
                  },
                ),
                ButtonView(
                    paddingTop: 8,
                    paddingBottom: 8,
                    paddingLeft: 18,
                    paddingRight: 18,
                    radius: 100,
                    backgroundColor: hexToColor("#2B2D34"),
                    child: TextView(
                      text: 'login',
                      color: Colors.white,
                      size: 16,
                      weight: FontWeight.w500,
                    ),
                    onPress: () {
                      onLogIn();
                    })
              ],
            )
          ],
        ),
      ),
      //
      SizedBox(
        height: 15,
      )
    ]);
  }
}

import 'package:flutter/material.dart';
import 'package:chat_app/widgets/rounded_button.dart';
import 'package:chat_app/constants.dart';
import 'package:chat_app/screens/chat_screen.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:chat_app/services/authentication.dart';
import 'package:chat_app/services/secure_storage.dart';

class LoginScreen extends StatefulWidget {
  static const id = 'login_screen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool showSpinner = false;
  late String email;
  late String password;
  bool loginFail = false;

  void getToken(String username, String password) async {
    Authentication auth = Authentication();
    try {
      await auth.authenticateUser(username, password);
      setState(() {
        loginFail = false;
        showSpinner = false;
      });
      Navigator.pushNamed(context, ChatScreen.id);
    } catch (e) {
      setState(() {
        loginFail = true;
        showSpinner = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                child: Container(
                  height: 200.0,
                  child: Icon(
                    FontAwesomeIcons.fish,
                    size: 100,
                    color: Colors.blueAccent[700],
                  ),
                ),
              ),
              SizedBox(
                height: 0.0,
              ),
              TextField(
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: Colors.grey[600]),
                  onChanged: (value) {
                    email = value;
                  },
                  decoration: kTextFieldAnotation.copyWith(
                      hintText: 'Enter your email',
                      errorText: loginFail ? '' : null)),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                  obscureText: true,
                  onChanged: (value) {
                    password = value;
                  },
                  decoration: kTextFieldAnotation.copyWith(
                      hintText: 'Enter your password',
                      errorText:
                          loginFail ? 'Invalid Username or Password' : null)),
              SizedBox(
                height: 24.0,
              ),
              RoundedButton(
                  color: Colors.blueAccent,
                  title: 'Log in',
                  onPressed: () async {
                    setState(() {
                      showSpinner = true;
                    });
                    try {
                      getToken(email, password);
                    } catch (e) {
                      showSpinner = false;
                      loginFail = true;
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }
}

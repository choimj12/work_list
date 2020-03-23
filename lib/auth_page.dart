import 'package:flutter/material.dart';
import 'firebase_provider.dart';
import 'login_page.dart';
import 'package:provider/provider.dart';
import 'tab_page.dart';


AuthPageState pageState;

class AuthPage extends StatefulWidget {
  @override
  AuthPageState createState() {
    pageState = AuthPageState();
    return pageState;
  }
}

class AuthPageState extends State<AuthPage> {
  FirebaseProvider fp;

  @override
  Widget build(BuildContext context) {
    fp = Provider.of<FirebaseProvider>(context);

    logger.d("user: ${fp.getUser()}");
    if (fp.getUser() != null && fp.getUser().isEmailVerified == true) {
      return TabPage();
    } else {
      return LoginPage();
    }
  }
}
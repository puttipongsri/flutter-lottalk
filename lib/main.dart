import 'package:flutter/material.dart';
import 'package:LotTalk/page/account.dart';
import 'page/login_page.dart';
import 'page/RegisterPage.dart';
// import 'home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'GlacialIndifference',
      ),
      // home: WelcomePage(),
      routes: {
        // '/': (context) => WelcomePage(), // WelcomePage as initial route
        '/': (context) => LoginPage(), // Main page
        '/register': (context) => RegisterPage(),
      },
    );
  }
}

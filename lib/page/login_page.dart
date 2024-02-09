import 'package:flutter/material.dart';
import 'package:LotTalk/pagewelcone.dart';
import '../../model/api_service.dart';
import 'home_screen.dart';
import 'RegisterPage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool obscureText = true; // เริ่มต้นรหัสผ่านเป็นสถานะที่ซ่อน

  String email = ''; // เพิ่มตัวแปร email ใน LoginPage
  String phoneNumber = ''; // เพิ่มตัวแปร phoneNumber ใน LoginPage
  String usernamebb = ''; // เพิ่มตัวแปร phoneNumber ใน LoginPage

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final logoSize = screenWidth * 0.5;
    return Scaffold(
      body: Container(
        height: screenHeight,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/img/bg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/img/logo.png',
                    width: logoSize,
                    height: logoSize,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Login",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  TextField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      labelStyle: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                      prefixIcon: Icon(
                        Icons.person,
                        color: Colors.black,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Color.fromARGB(255, 0, 0, 0), width: 2.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                      ),
                    ),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: passwordController,
                    obscureText: obscureText,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                      prefixIcon: Icon(Icons.lock, color: Colors.black),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Color.fromARGB(255, 0, 0, 0), width: 2.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                      ),
                      // เพิ่มไอคอนตาเพื่อแสดง/ซ่อนรหัสผ่าน
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureText ? Icons.visibility : Icons.visibility_off,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          // เปลี่ยนสถานะรหัสผ่านเมื่อกด
                          setState(() {
                            obscureText = !obscureText;
                          });
                        },
                      ),
                    ),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      final username = usernameController.text;
                      final password = passwordController.text;
                      final success =
                          await ApiService.login(username, password);
                      print('Login success: $success');
                      if (success) {
                        // เมื่อ Login สำเร็จ ดึงข้อมูลผู้ใช้งานจาก API
                        final userData = await ApiService.getUserData(username);
                        setState(() {
                          email = userData['address'];
                          usernamebb = userData['username'];
                          phoneNumber = userData['phoneNumber'];
                        });
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => WelcomePage(
                              email: email, // ส่ง email ไปยัง WelcomePage
                              phoneNumber:
                                  phoneNumber, // ส่ง phoneNumber ไปยัง WelcomePage
                              username:
                                  usernamebb, // ส่ง phoneNumber ไปยัง WelcomePage
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Login failed')),
                        );
                      }
                    },
                    child: Container(
                      width: double.infinity, // ทำให้ปุ่มเต็มความกว้าง
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(
                          child: Text(
                        'Login',
                        style: TextStyle(fontSize: 18.0),
                      )),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "New User ?",
                        style: TextStyle(
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => RegisterPage(),
                            ),
                          );
                        },
child: Text(
  'Sign up',
  style: TextStyle(
    fontSize: 25.0,
    fontWeight: FontWeight.bold,
    color: Color.fromARGB(255, 255, 1, 1),
    decoration: TextDecoration.underline, // เพิ่มขีดเส้นใต้
  ),
),

                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

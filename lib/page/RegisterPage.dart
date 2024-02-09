import 'package:flutter/material.dart';
import 'package:LotTalk/page/login_page.dart';
import '../model/api_service.dart';
import '../model/apimodel.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();

  bool obscureText = true; // สถานะสำหรับการซ่อน/แสดงรหัสผ่าน

  void _showAlertDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // ฟังก์ชันตรวจสอบว่า phone number มีตัวเลขอย่างเดียวและมี 10 หลัก
  bool isPhoneNumberValid(String phoneNumber) {
    final phonePattern = r'^[0-9]{10}$';
    final regExp = RegExp(phonePattern);
    if (!regExp.hasMatch(phoneNumber)) {
      _showAlertDialog(
        context,
        'ข้อผิดพลาด',
        'กรุณากรอกหมายเลขโทรศัพท์เป็นตัวเลขเท่านั้นและต้องมี 10 หลัก',
      );
      return false;
    }
    return true;
  }

  // ฟังก์ชันตรวจสอบรูปแบบของอีเมล
  bool isEmailValid(String email) {
    final emailPattern =
        r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$';
    final regExp = RegExp(emailPattern);
    if (!regExp.hasMatch(email)) {
      _showAlertDialog(
        context,
        'ข้อผิดพลาด',
        'กรุณากรอกอีเมลให้ถูกต้อง',
      );
      return false;
    }
    return true;
  }

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
                  const SizedBox(height: 20.0),
                  Image.asset(
                    'assets/img/logo.png',
                    width: logoSize,
                    height: logoSize,
                  ),
                  const Text(
                    'Register',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  TextField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      labelStyle: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                      prefixIcon: Icon(Icons.person, color: Colors.black),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Color.fromARGB(255, 0, 0, 0), width: 2.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                      ),
                    ),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16.0),
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
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureText
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          setState(() {
                            obscureText = !obscureText;
                          });
                        },
                      ),
                    ),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: addressController,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      labelStyle: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      prefixIcon:
                          Icon(Icons.location_on, color: Colors.black),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 0, 0, 0),
                          width: 2.0,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                    ),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: phoneNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      labelStyle: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      prefixIcon: Icon(
                        Icons.phone_android_outlined,
                        color: Colors.black,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 0, 0, 0),
                          width: 2.0,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                    ),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          final username = usernameController.text;
                          final password = passwordController.text;
                          final address = addressController.text;
                          final phoneNumber = phoneNumberController.text;

                          // ตรวจสอบความถูกต้องของข้อมูลที่รับมา
                          if (username.isEmpty ||
                              password.isEmpty ||
                              address.isEmpty ||
                              phoneNumber.isEmpty ||
                              !isPhoneNumberValid(phoneNumber) || // เรียกใช้ฟังก์ชันตรวจสอบ phone number
                              !isEmailValid(address)) { // เรียกใช้ฟังก์ชันตรวจสอบอีเมล
                            return; // หยุดการดำเนินการถ้าข้อมูลไม่ถูกต้อง
                          }

                          final user = Users(
                            username: username,
                            password: password,
                            address: address,
                            phoneNumber: phoneNumber,
                            // email: email, // เพิ่มค่าอีเมลใน User
                          );

                          final success = await ApiService.register(user);

                          if (success == 'Username already exists') {
                            Alert(
                              context: context,
                              type: AlertType.error,
                              title: 'ข้อผิดพลาด',
                              desc: 'มีผู้ใช้นี้อยู่แล้ว',
                              buttons: [
                                DialogButton(
                                  child: Text('OK'),
                                  onPressed: () =>
                                      Navigator.of(context).pop(),
                                ),
                              ],
                            ).show();
                          } else if (success == 'Email already exists') {
                            Alert(
                              context: context,
                              type: AlertType.error,
                              title: 'ข้อผิดพลาด',
                              desc: 'มีอีเมลนี้อยู่แล้ว',
                              buttons: [
                                DialogButton(
                                  child: Text('OK'),
                                  onPressed: () =>
                                      Navigator.of(context).pop(),
                                ),
                              ],
                            ).show();
                          } else if (success == 'Registration successful') {
                            Alert(
                              context: context,
                              type: AlertType.success,
                              title: 'สำเร็จ',
                              desc: 'สมัครสำเร็จ',
                              buttons: [
                                DialogButton(
                                  child: Text('OK'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (context) => LoginPage(),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ).show();
                          } else if (success == 'Registration failed') {
                            Alert(
                              context: context,
                              type: AlertType.error,
                              title: 'ข้อผิดพลาด',
                              desc: 'สมัครไม่สำเร็จ',
                              buttons: [
                                DialogButton(
                                  child: Text('OK'),
                                  onPressed: () =>
                                      Navigator.of(context).pop(),
                                ),
                              ],
                            ).show();
                          }
                        },
                        child: const Text('Register'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => LoginPage(),
                            ),
                          );
                        },
                        child: const Text('Login'),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

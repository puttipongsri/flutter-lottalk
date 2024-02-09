import 'package:LotTalk/page/account.dart';
import 'package:flutter/material.dart';
import '../model/api_service.dart';

class ChangePasswordPage extends StatefulWidget {
  final String username; // เพิ่มตัวแปร username

  ChangePasswordPage({required this.username}); // Constructor รับค่า username

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();

  void _changePassword() async {
    final currentPassword = currentPasswordController.text;
    final newPassword = newPasswordController.text;
    final confirmPassword = confirmPasswordController.text;

    final username =
        widget.username; // ใช้ค่า username ที่ถูกส่งมาจากหน้า account_page

    if (newPassword != confirmPassword) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Password Mismatch'),
          content: Text('New password and confirm password do not match.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // final username = ''; // ระบุชื่อผู้ใช้ที่เปลี่ยนรหัสผ่าน

    final success =
        await ApiService.changePassword(username, currentPassword, newPassword);

    if (success) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Password Changed'),
          content: Text('Your password has been successfully changed.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context)
                    .pop(); // กลับไปยังหน้าบัญชีหลักหลังจากเปลี่ยนรหัสผ่านสำเร็จ
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Change Password Failed'),
          content: Text(
              'Failed to change password. Please check your current password and try again.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
            appBar: AppBar(
        title: Text('Change Password'),
        backgroundColor: Color.fromARGB(255, 214, 130, 20),
      ),
       body: Container(
        height: screenHeight,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/img/bg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
       
    child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // ใช้ GlobalKey<FormState> ในการควบคุม Form
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Change Your Password',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller:
                    currentPasswordController, // ใช้ TextEditingController
                obscureText: false,
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value == '') {
                    return 'Please enter your current password.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: newPasswordController, // ใช้ TextEditingController
                obscureText: false,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value == '') {
                    return 'Please enter a new password.';
                  }
                  // เพิ่มเงื่อนไขตรวจสอบความถูกต้องของรหัสผ่านใหม่ที่นี่ (ตามความต้องการ)
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller:
                    confirmPasswordController, // ใช้ TextEditingController
                obscureText: false,
                decoration: InputDecoration(
                  labelText: 'Confirm New Password',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value == '') {
                    return 'Please confirm your new password.';
                  }
                  // เพิ่มเงื่อนไขตรวจสอบความถูกต้องของการยืนยันรหัสผ่านใหม่ที่นี่ (ตามความต้องการ)
                  return null;
                },
              ),
              SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _changePassword(); // เรียกเมื่อผ่านการตรวจสอบข้อมูล
                  }
                },
                style: ElevatedButton.styleFrom(
                  primary: Color.fromARGB(255, 112, 245, 255),
                ),
                child: Text(
                  'Change Password',
                  style: TextStyle(fontSize: 18.0, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../model/apimodel.dart';
import '../model/api_service.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../pagewelcone.dart';
class EditPostPage extends StatefulWidget {
  final String username;
  final String email;
  final String phoneNumber;
  final Post post;

  const EditPostPage({
    Key? key,
    required this.username,
    required this.email,
    required this.phoneNumber,
    required this.post,
  }) : super(key: key);

  @override
  _EditPostPageState createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _imgPathController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // กำหนดค่าเริ่มต้นของข้อความและ URL รูปภาพจากโพสต์ที่มีอยู่แล้ว
    _textController.text = widget.post.textpost ?? '';
    _imgPathController.text = widget.post.imgPath ?? '';
  }

  void _confirmEdit() {
    Alert(
      context: context,
      title: "Confirm Edit",
      content: Column(
        children: <Widget>[
          const Text("Do you want to save this edited post?"),
          if (_imgPathController.text.isNotEmpty)
            Image.network(
              _imgPathController.text,
              width: 200,
              height: 200,
              fit: BoxFit.cover,
            ),
        ],
      ),
      buttons: [
        DialogButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text(
            "Cancel",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          color: Colors.blue,
        ),
        DialogButton(
          onPressed: () {
            Navigator.of(context).pop();
            _saveEditedPost(); // เมื่อยืนยันแก้ไขโพสต์ให้เรียก _saveEditedPost()
          },
          child: const Text(
            "Save",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          color: Colors.green,
        ),
      ],
    ).show();
  }

  void _saveEditedPost() {
    // สร้างอินสแตนซ์ Post จากข้อมูลที่แก้ไขในฟอร์ม
    final editedPost = Post(
      id: widget.post.id,
      username: widget.username,
      textpost: _textController.text,
      imgPath: _imgPathController.text,
      likedUsers:List.empty()
    );

    // เรียกเมธอดสำหรับบันทึกโพสต์ที่แก้ไขไปยัง API ด้วยอินสแตนซ์ Post ที่แก้ไข
    _uploadEditedPost(editedPost);
  }

  void _uploadEditedPost(Post editedPost) {
    ApiService.updatePost(editedPost).then((result) {
      if (result) {
        // บันทึกโพสต์ที่แก้ไขสำเร็จ
        Navigator.pop(context); // ปิดหน้า EditPostPage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => WelcomePage(
              email: widget.email,
              phoneNumber: widget.phoneNumber,
              username: widget.username,
            ),
          ),
        );
      } else {
        // บันทึกโพสต์ที่แก้ไขไม่สำเร็จ
        Alert(
          context: context,
          type: AlertType.error,
          title: "Error",
          desc: "Failed to save edited post",
          buttons: [
            DialogButton(
              child: const Text(
                "OK",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              color: Colors.red,
            ),
          ],
        ).show();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final logoSize = screenWidth * 0.5;
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Post'),
        backgroundColor: const Color.fromARGB(255, 214, 130, 20),
      ),
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
                  TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      labelText: 'Edit Text Post',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _imgPathController,
                    decoration: const InputDecoration(
                      labelText: 'Edit Image link Path',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // เรียกเมธอดสำหรับยืนยันก่อนแก้ไขโพสต์
                      _confirmEdit();
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.green,
                    ),
                    child: const Text('Save Edited Post'),
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

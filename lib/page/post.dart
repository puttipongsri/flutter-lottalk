import 'package:flutter/material.dart';
import '../model/apimodel.dart'; // นำเข้าโมเดลข้อมูล
import '../model/api_service.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../pagewelcone.dart';

class PostPage extends StatefulWidget {
  final String username; // เพิ่มพารามิเตอร์ username ในคอนสตรักเตอร์
    final String email;
    final String phoneNumber;
  const PostPage({Key? key, required this.username, required this.email, required this.phoneNumber}) : super(key: key);

  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _imgPathController = TextEditingController();

  void _confirmPost() {
    Alert(
      context: context,
      title: "Confirm Post",
      content: Column(
        children: <Widget>[
          const Text("Do you want to post this image?"),
          if (_imgPathController.text.isNotEmpty)
            Image.network(
              _imgPathController.text,
              width: 200, // ปรับขนาดรูปภาพตามที่คุณต้องการ
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
            _savePost(); // เมื่อยืนยันโพสต์ให้เรียก _savePost()
          },
          child: const Text(
            "Post",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          color: Colors.green,
        ),
      ],
    ).show();
  }

  void _savePost() {
    // สร้างอินสแตนซ์ Post จากข้อมูลที่กรอกในฟอร์ม
    final newPost = Post(
      username: widget.username, // ใช้ค่า username ที่ส่งมาในพารามิเตอร์
      textpost: _textController.text,
      imgPath: _imgPathController.text,
    );

    // เรียกเมธอดสำหรับบันทึกโพสไปยัง API ด้วยอินสแตนซ์ Post ที่สร้างขึ้น
    _uploadPost(newPost);
  }

  void _showImageFromUrl() {
    if (_imgPathController.text.isNotEmpty) {
      Alert(
        context: context,
        title: '',
        content: Container(
          width: double.infinity,
          child: Image.network(
            _imgPathController.text,
            fit: BoxFit.cover,
          ),
        ),
        buttons: [
          DialogButton(
            child: const Text(
              "Close",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            color: Colors.blue,
          ),
        ],
      ).show();
    } else {
      Alert(
        context: context,
        type: AlertType.error,
        title: "Error",
        desc: "Please enter a valid image URL",
        buttons: [
          DialogButton(
            child: const Text(
              "OK",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () {
              // Navigator.pop(context);
            },
            color: Colors.red,
          ),
        ],
      ).show();
    }
  }

  void _uploadPost(Post post) {
  ApiService.uploadPost(post, widget.username).then((result) {
    if (result) {
      // บันทึกโพสต์สำเร็จ
Navigator.pop(context); // ปิดหน้า PostPage
Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (context) => WelcomePage(email: widget.email, phoneNumber: widget.phoneNumber, username: widget.username,)),
);
    } else {
      // บันทึกโพสต์ไม่สำเร็จ
      Alert(
        // แสดง Alert แจ้งเตือน
        context: context,
        type: AlertType.error,
        title: "Error",
        desc: "Failed to save post",
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
        title: Text('Post'),
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
                // const SizedBox(height: 20),
                TextField(
                  controller: _textController,
                  decoration: const InputDecoration(
                    labelText: 'Text Post',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _imgPathController,
                  decoration: const InputDecoration(
                    labelText: 'Image link Path',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // เรียกเมธอดสำหรับยืนยันก่อนโพส
                    _confirmPost();
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green,
                  ),
                  child: const Text('Save Post'),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}

import 'package:flutter/material.dart';
import '../model/api_service.dart';
import '../model/apimodel.dart';

class RankingPage extends StatefulWidget {
  @override
  _RankingPageState createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  List<Post> posts = [];

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    try {
      final loadedPosts = await ApiService.getPosts();
      setState(() {
        posts = loadedPosts;
      });
    } catch (error) {
      // จัดการข้อผิดพลาดที่เกิดขึ้นในการโหลดโพสต์
    }
  }

  @override
  Widget build(BuildContext context) {
    // ทำการคำนวณอันดับจากโพสต์ที่มีไลค์มากที่สุด
    posts.sort((a, b) {
      final aLength = a.likedUsers?.length ?? 0; // ใช้ .length หาก likedUsers ไม่ใช่ null
      final bLength = b.likedUsers?.length ?? 0; // ใช้ .length หาก likedUsers ไม่ใช่ null
      return bLength.compareTo(aLength);
    });

    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Ranking Page'),
      //   backgroundColor: Colors.blue, // สีพื้นหลังของ AppBar
      // ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/img/bg.jpg'), // เปลี่ยนเป็นรูปภาพพื้นหลังที่คุณต้องการ
            fit: BoxFit.cover, // ปรับขนาดรูปภาพให้พอดีกับพื้นที่
          ),
        ),
        child: ListView.builder(
          itemCount: posts.length > 10 ? 10 : posts.length, // แสดงเฉพาะ 10 อันดับแรก
          itemBuilder: (context, index) {
            final post = posts[index];
            final likesCount = post.likedUsers?.length ?? 0; // ใช้ .length หาก likedUsers ไม่ใช่ null
            final rank = index + 1; // คำนวณเลขลำดับ (เริ่มจาก 1)

            return Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Color.fromARGB(255, 255, 10, 10), // สีขอบ
                  width: 2.0, // ความหนาขอบ
                ),
                borderRadius: BorderRadius.circular(12.0), // กำหนดรูปร่างของกรอบ
                color: Colors.white.withOpacity(0.8), // สีพื้นหลังของ Container และทำให้มีความโปร่งใส
              ),
              margin: EdgeInsets.all(8), // ระยะห่างรอบขอบของ Container
              child: ListTile(
                title: Text(
                  'ลำดับที่ $rank: ${post.username}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20, // ปรับขนาดตัวอักษร
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (post.textpost != null && post.textpost!.isNotEmpty)
                      Text(
                        'โพสต์: ${post.textpost}',
                        style: TextStyle(
                          fontSize: 16, // ปรับขนาดตัวอักษร
                        ),
                      ),
                    Text(
                      'Likes: $likesCount',
                      style: TextStyle(
                        fontSize: 16, // ปรับขนาดตัวอักษร
                      ),
                    ),
                  ],
                ),
                // แสดงรูปภาพถ้าโพสต์มีรูป
                leading: post.imgPath != null && post.imgPath!.isNotEmpty
                    ? Image.network(
                        post.imgPath!,
                        width: 80, // กำหนดความกว้างของรูป
                        height: 80, // กำหนดความสูงของรูป
                        fit: BoxFit.cover, // ปรับขนาดรูปให้พอดีกับพื้นที่
                      )
                    : null,
              ),
            );
          },
        ),
      ),
    );
  }
}
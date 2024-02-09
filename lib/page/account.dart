import 'package:flutter/material.dart';
import 'login_page.dart';
import 'package:LotTalk/model/api_service.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:LotTalk/page/change_password_page.dart';
import '../model/apimodel.dart';
import 'dart:convert';
import 'comment.dart';
import 'editpost.dart';

class AccountPage extends StatefulWidget {
  final String username;
  final String avatarUrl;
  final String email;
  final String phoneNumber;

  AccountPage({
    Key? key,
    required this.avatarUrl,
    required this.email,
    required this.username,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  int postCount = 0;
  List<Post> userPosts = [];
  int totalLikesCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserPosts();
  }

  void _openCommentPage(int postId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CommentPage(
          postId: postId,
          username: widget.username,
        ),
      ),
    );
  }

  Future<void> _fetchUserPosts() async {
    try {
      final posts = await ApiService.getPostsByUsername(widget.username);

      setState(() {
        userPosts = posts;
        postCount = userPosts.length;
        userPosts.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));

        // Calculate the total likes count for all posts
        totalLikesCount = userPosts
            .map<int>((post) => post.likedUsers?.length ?? 0)
            .fold<int>(0, (previousValue, element) => previousValue + element);
      });
    } catch (error) {
      print('Error fetching user posts: $error');
    }
  }

  void _editPost(Post post) {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => EditPostPage(
          post: post,
          username: widget.username,
          phoneNumber: widget.phoneNumber,
          email: widget.email,
        ),
      ),
    )
        .then((edited) {
      if (edited == true) {
        _fetchUserPosts();
        // ถ้าผู้ใช้แก้ไขโพสต์และบันทึกสำเร็จ
        // ทำอะไรต่อไป เช่น อัปเดตหน้า AccountPage หรือแสดงข้อความแจ้งเตือน
      }
    });
  }

  void _deletePost(Post post) {
    // เรียกใช้งานฟังก์ชัน deletePost ใน ApiService
    ApiService.deletePostAndRelatedData(post.id ?? 0).then((success) {
      if (success) {
        // ลบโพสต์สำเร็จ
        setState(() {
          // ลบโพสต์ออกจากรายการ userPosts
          userPosts.remove(post);
          postCount = userPosts.length;
          _fetchUserPosts();
        });
        _fetchUserPosts();
        // แสดงแจ้งเตือนหรือทำอย่างอื่นตามที่คุณต้องการ
      } else {
        // _fetchUserPosts();
        // ไม่สามารถลบโพสต์ได้
        // แสดงข้อความแจ้งเตือนหรือทำอื่นๆ ตามที่คุณต้องการ
      }
    });
  }

  void _showPostOptions(Post post) {
    Alert(
      type: AlertType.warning,
      title: "Select",
      desc: "Choice for you want",
      context: context,
      buttons: [
        if (post.username ==
            widget
                .username) // แสดงตัวเลือกแก้ไขและลบเฉพาะถ้าโพสเป็นของผู้ใช้ปัจจุบัน
          DialogButton(
            onPressed: () {
              Navigator.pop(context);
              _editPost(post);
            },
            color: Colors.green,
            child: const Text(
              "Edit",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        if (post.username == widget.username)
          DialogButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePost(post);
            },
            color: Colors.red,
            child: const Text(
              "Delete",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        DialogButton(
          onPressed: () {
            Navigator.pop(context);
          },
          width: 120,
          child: const Text(
            "Cancel",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ).show();
  }

  void _toggleLike(int postId) async {
    setState(() {
      final postIndex = userPosts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        final post = userPosts[postIndex];
        final currentUserId = widget.username;

        if (post.likedUsers == null) {
          post.likedUsers = [currentUserId];
        } else if (post.likedUsers!.contains(currentUserId)) {
          post.likedUsers!.remove(currentUserId);
        } else {
          post.likedUsers!.add(currentUserId);
        }

        // อัปเดตข้อมูลใน JSON โพสต์โดยเรียกใช้งาน ApiService
        ApiService.updatePost(post);
        _fetchUserPosts();

        // เรียกสร้างการแจ้งเตือนเมื่อกด Like
        if (post.likedUsers != null &&
            post.likedUsers!.contains(currentUserId)) {
          _createLikeNotification(post.id ?? 0);
        }
      }
    });
  }

  void _createLikeNotification(int postId) async {
    try {
      final apiService = ApiService(); // Create an instance of ApiService
      final postUsername = await apiService.getUsernameByPostId(postId);

      if (postUsername != null) {
        final success = await ApiService.createNotification(
          postId,
          postUsername,
          'like',
          widget.username,
        );

        if (success) {
          print('Notification created for liked post with postId: $postId');
        } else {
          print('Failed to create notification for liked post with postId: $postId');
        }
      } else {
        print('Post with postId: $postId not found or error occurred.');
      }
    } catch (error) {
      print('Error creating notification: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 156, 100, 32),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('assets/img/bg.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.5),
                  BlendMode.darken,
                ),
              ),
            ),
          ),
          Positioned(
            top: 40.0,
            right: 16.0,
            child: IconButton(
              icon: const Icon(
                Icons.logout,
                size: 35,
              ),
              onPressed: () async {
                Alert(
                  context: context,
                  type: AlertType.warning,
                  title: "Confirm Logout",
                  desc: "Are you sure you want to log out?",
                  buttons: [
                    DialogButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      width: 120,
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    DialogButton(
                      color: Colors.red,
                      onPressed: () async {
                        await ApiService.logout();
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => LoginPage(),
                          ),
                        );
                      },
                      width: 120,
                      child: const Text(
                        "Logout",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ).show();
              },
              color: Colors.red,
            ),
          ),
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 100.0),

                Container(
                  width: 120.0,
                  height: 120.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 4.0,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(widget.avatarUrl),
                  ),
                ),
                const SizedBox(height: 16.0),
                Text(
                  'Username: ${widget.username}',
                  style: const TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'YourFont',
                  ),
                ),
                const SizedBox(height: 16.0),
                Text(
                  'Email: ${widget.email}',
                  style: const TextStyle(
                    fontSize: 20.0,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 3.0,
                        color: Colors.black,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Phone: ${widget.phoneNumber.substring(0, widget.phoneNumber.length - 4)}****',
                  style: const TextStyle(
                    fontSize: 20.0,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 3.0,
                        color: Colors.black,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Number of Posts: $postCount',
                  style: const TextStyle(
                    fontSize: 20.0,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 3.0,
                        color: Colors.black,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Total Like Your post: $totalLikesCount',
                  style: const TextStyle(
                    fontSize: 20.0,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 3.0,
                        color: Colors.black,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 16.0),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                ChangePasswordPage(username: widget.username),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        primary: const Color.fromARGB(255, 112, 245, 255),
                      ),
                      child: const Text(
                        'Change Password',
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.zero,
                    scrollDirection: Axis.vertical,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: userPosts.map((post) {
                        final isLiked = post.likedUsers
                                ?.contains(widget.username.toLowerCase()) ==
                            true;
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(20.0), // ปรับขอบของ Card
                          ),
                          child: ListTile(
                            onLongPress: () {
                              _showPostOptions(post);
                            },
                            title: Text(
                              post.textpost ?? '',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'โพสต์โดย: ${post.username ?? 'ไม่มีชื่อผู้ใช้'}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                                post.imgPath != null && post.imgPath != ""
                                    ? Image.network(
                                        post.imgPath ?? '',
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      )
                                    : const SizedBox.shrink(),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.favorite,
                                    color: isLiked ? Colors.red : null,
                                  ),
                                  onPressed: () {
                                    _toggleLike(post.id ?? 0);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.comment),
                                  onPressed: () {
                                    _openCommentPage(post.id ?? 0);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                SizedBox(
                    height:
                        70.0), // เพิ่ม SizedBox เพื่อเว้นระหว่าง SingleChildScrollview และส่วนอื่น
              ],
            ),
          ),
        ],
      ),
    );
  }
}

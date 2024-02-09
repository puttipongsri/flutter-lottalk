import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart'; // เพิ่ม import สำหรับ like_button
import '../model/api_service.dart';
import '../model/apimodel.dart';
import 'comment.dart';
import 'post.dart';

class HomeScreen extends StatefulWidget {
  final String email;
  final String phoneNumber;
  final String username;

  HomeScreen(
      {required this.username, required this.email, required this.phoneNumber});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Post> posts = [];

  @override
  void initState() {
    super.initState();
    fetchPosts();
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

  void _toggleLike(int postId) async {
    setState(() {
      final postIndex = posts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        final post = posts[postIndex];
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


  Future<void> fetchPosts() async {
    try {
      final fetchedPosts = await ApiService.getPosts();
      setState(() {
        posts = fetchedPosts;
        print(posts);
        posts.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
      });
    } catch (e) {
      print('Error loading posts: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 156, 100, 32),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          final isLiked =
              post.likedUsers?.contains(widget.username.toLowerCase()) == true;

          return Card(
            margin: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0), // ปรับขอบของ Card
            ),
            child: ListTile(
              title: Text(
                post.textpost ?? '',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'โพสต์โดย: ${post.username ?? 'ไม่มีชื่อผู้ใช้'}',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  post.imgPath != null && post.imgPath != ""
                      ? Image.network(
                          post.imgPath ?? '',
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : SizedBox.shrink(),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LikeButton(
                    // ใช้ LikeButton สำหรับปุ่ม Like
                    isLiked: isLiked,
                    onTap: (isLiked) {
                      _toggleLike(post.id ?? 0);
                      return Future.value(!isLiked);
                    },
                    likeBuilder: (isLiked) {
                      return Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : null,
                      );
                    },
                    likeCount: post.likedUsers?.length ?? 0, // แสดงจำนวนกดไลค์
                  ),
                  IconButton(
                    icon: Icon(Icons.comment),
                    onPressed: () {
                      _openCommentPage(post.id ?? 0);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: SizedBox(
        width: 60,
        height: 60,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PostPage(
                  username: widget.username,
                  email: widget.email,
                  phoneNumber: widget.phoneNumber,
                ),
              ),
            );
          },
          child: Icon(
            Icons.add_a_photo_outlined,
            size: 30,
          ),
          backgroundColor: Colors.green,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
    );
  }
}

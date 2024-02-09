import 'package:flutter/material.dart';
import '../model/api_service.dart';
import '../model/apimodel.dart';
import 'login_page.dart';

class CommentPage extends StatefulWidget {
  final int postId;
  final String username;

  CommentPage({required this.postId, required this.username});

  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  List<Comment> comments = [];
  TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchCommentsForPost(widget.postId);
  }

  Future<void> fetchCommentsForPost(int postId) async {
    try {
      final fetchedComments = await ApiService.getCommentsForPost(postId);
      setState(() {
        comments = fetchedComments;
      });
    } catch (e) {
      print('Error loading comments: $e');
    }
  }

  Future<void> addComment() async {
    String commentText = commentController.text;
    if (commentText.isNotEmpty) {
      CommentAll newComment = CommentAll(
        username: widget.username,
        textComment: commentText,
      );

      bool success = await ApiService.addComment(widget.postId, newComment);
      final apiService = ApiService(); // Create an instance of ApiService
      final postUsername = await apiService.getUsernameByPostId(widget.postId);

      if (success) {
        // เรียกใช้ createNotification เมื่อความคิดเห็นถูกสร้างขึ้น
        bool notificationSuccess = await ApiService.createNotification(
          widget.postId,
          postUsername,
          'comment',
          widget.username // ระบุ 'comment' เพื่อแสดงว่าเป็นการแจ้งเตือนเมื่อมีความคิดเห็น
        );

        if (notificationSuccess) {
          await fetchCommentsForPost(widget.postId);
          setState(() {
            commentController.clear();
          });
        } else {
          print('Error creating notification');
        }
      } else {
        print('Error adding comment');
      }

          }
        }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comments'),
        backgroundColor: Color.fromARGB(255, 200, 122, 32),
      ),
      body: Container(
        // height: screenHeight,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/img/bg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  final comment = comments[index];
                  if (comment.commentAll != null &&
                      comment.commentAll!.isNotEmpty) {
                    return Card(
                      elevation: 3.0,
                      margin: EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(
                          '${comment.commentAll![0].username}' ?? 'No Username',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Post : ${comment.commentAll![0].textComment}' ??
                              'No Comment Text',
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ),
                    );
                  } else {
                    return Card(
                      elevation: 3.0,
                      margin: EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text('No Comment'),
                      ),
                    );
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: commentController,
                      decoration: InputDecoration(
                        hintText: 'Add a comment...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        filled: true, // กำหนดให้มีสีพื้นหลัง
                        fillColor: Colors.white, // สีพื้นหลัง
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () {
                      addComment();
                    },
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'apimodel.dart';
import 'package:intl/intl.dart';


class ApiService {
  static const String baseUrl =
      'http://172.20.10.2:3000'; // เปลี่ยนเป็น URL ของ JSON server ของคุณ

  static Future<bool> login(String username, String password) async {
    final response = await http
        .get(Uri.parse('$baseUrl/users?username=$username&password=$password'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data.isNotEmpty) {
        final userId = data[0]['id'];
        final prefs = await SharedPreferences.getInstance();
        prefs.setInt('userId', userId);
        return true;
      }
    }
    return false;
  }

static Future<bool> createNotification(
  int postId,
  String username,
  String type,
  String actionUsername, // เพิ่มฟิลด์ "actionUsername"
) async {
  try {
    String desfix = type[0].toUpperCase() + type.substring(1);
    String formattedTime = DateFormat.Hm().format(DateTime.now());
    final response = await http.post(
      Uri.parse('$baseUrl/notifications'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'post_id': postId,
        'username': username,
        'des': '$actionUsername $desfix Your Post',
        'type': type,
        'actionUsername': actionUsername, // เพิ่มฟิลด์ "actionUsername"
        'time': formattedTime,
      }),
    );

    if (response.statusCode == 201) {
      return true; // สร้างการแจ้งเตือนสำเร็จ
    } else {
      print('Failed to create notification. Status code: ${response.statusCode}');
      return false; // เกิดข้อผิดพลาดในการสร้างการแจ้งเตือน
    }
  } catch (error) {
    print('Error creating notification: $error');
    return false; // เกิดข้อผิดพลาดระหว่างการสร้างการแจ้งเตือน
  }
}


static Future<List<Notificationaa>> getNotificationsByUsername(
    String username) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/notifications?username=$username'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List<dynamic>;
      final notifications = data
          .map<Notificationaa>((json) {
            final notification = Notificationaa.fromJson(json);
            if (notification.type == 'like' || notification.type == 'comment') {
              // ดึงข้อมูลโพสต์หรือความคิดเห็นที่เกี่ยวข้อง
              final actionPost = data
                  .where((postData) =>
                      postData['post_id'] == notification.postId)
                  .first;
              if (actionPost != null) {
                notification.actionUsername = actionPost['username'];
              }
            }
            return notification;
          })
          .toList();
      return notifications;
    } else {
      throw Exception('Failed to load notifications for user $username');
    }
  } catch (error) {
    print('Error getting notifications: $error');
    throw Exception('Failed to load notifications for user $username');
  }
}


  static Future<List<Post>> getPostsByUsername(String username) async {
    final response =
        await http.get(Uri.parse('$baseUrl/post?username=$username'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List<dynamic>;
      final posts = data.map<Post>((json) => Post.fromJson(json)).toList();
      return posts;
    } else {
      throw Exception('Failed to load posts for user $username');
    }
  }

  static Future<bool> updatePost(Post post) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/post/${post.id}'), // URL สำหรับอัปเดตโพสต์
        headers: {'Content-Type': 'application/json'},
        body: json.encode(post.toJson()), // ส่ง JSON โพสต์ที่อัปเดตแล้ว
      );

      if (response.statusCode == 200) {
        return true; // อัปเดตโพสสำเร็จ
      } else {
        return false; // เกิดข้อผิดพลาดในการอัปเดตโพสต์
      }
    } catch (error) {
      print('Error updating post: $error');
      return false; // เกิดข้อผิดพลาดระหว่างการอัปเดตโพสต์
    }
  }

  static Future<String> register(Users user) async {
    final checkUsernameResponse = await http.get(
      Uri.parse('$baseUrl/users?username=${user.username}'),
    );

    final checkEmailResponse = await http.get(
      Uri.parse('$baseUrl/users?address=${user.address}'),
    );

    if (checkUsernameResponse.statusCode == 200 &&
        checkEmailResponse.statusCode == 200) {
      final usernameData = json.decode(checkUsernameResponse.body);
      final emailData = json.decode(checkEmailResponse.body);

      if (usernameData.isNotEmpty) {
        // Username ซ้ำกับที่มีอยู่
        return 'Username already exists';
      } else if (emailData.isNotEmpty) {
        // Email ซ้ำกับที่มีอยู่
        return 'Email already exists';
      } else {
        // Username และ Email ไม่ซ้ำกับที่มีอยู่ ดำเนินการลงทะเบียน
        final registerResponse = await http.post(
          Uri.parse('$baseUrl/users'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(user.toJson()),
        );

        if (registerResponse.statusCode == 201) {
          // ลงทะเบียนสำเร็จ
          return 'Registration successful';
        } else {
          // ลงทะเบียนไม่สำเร็จ
          return 'Registration failed';
        }
      }
    } else {
      // เกิดข้อผิดพลาดในการตรวจสอบ
      return 'Error checking username or email';
    }
  }

  static Future<bool> uploadPost(Post post, String username) async {
    try {
      // แก้ไข JSON ที่จะส่งไปในการอัพโหลดโพส
      final postData = {
        'username': username, // เพิ่ม username ใน JSON โพสต์
        'textpost': post.textpost,
        'img_path': post.imgPath,
        'likedUsers': List.empty()
      };

      final response = await http.post(
        Uri.parse('$baseUrl/post'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(postData), // ส่ง JSON ที่แก้ไขแล้ว
      );

      if (response.statusCode == 201) {
        return true; // อัพโหลดโพสสำเร็จ
      } else {
        return false; // เกิดข้อผิดพลาดในการอัพโหลดโพส
      }
    } catch (error) {
      print('Error uploading post: $error');
      return false; // เกิดข้อผิดพลาดระหว่างการอัพโหลดโพส
    }
  }

  static Future<List<Post>> getPosts() async {
    final response = await http.get(Uri.parse('$baseUrl/post'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List<dynamic>;
      final posts = data.map<Post>((json) => Post.fromJson(json)).toList();
      return posts;
    } else {
      throw Exception('Failed to load posts');
    }
  }

  // เพิ่มฟังก์ชันเพื่อสร้าง Comment ใหม่และบันทึกลงใน JSON ไฟล์
  static Future<bool> addComment(int postId, CommentAll comment) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/comment'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'postid': postId,
          'comment_all': [comment.toJson()],
        }),
      );
      // print(object)

      if (response.statusCode == 201) {
        return true; // เพิ่มความคิดเห็นสำเร็จ
      } else {
        return false; // เกิดข้อผิดพลาดในการเพิ่มความคิดเห็น
      }
    } catch (error) {
      print('Error adding comment: $error');
      return false; // เกิดข้อผิดพลาดระหว่างการเพิ่มความคิดเห็น
    }
  }

  static Future<List<Comment>> getCommentsForPost(int postId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/comment?postid=$postId'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List<dynamic>;
      final comments =
          data.map<Comment>((json) => Comment.fromJson(json)).toList();
      return comments;
    } else {
      throw Exception('Failed to load comments for post $postId');
    }
  }

  static Future<Map<String, dynamic>> getUserData(String username) async {
    final response =
        await http.get(Uri.parse('$baseUrl/users?username=$username'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data.isNotEmpty) {
        // ตรวจสอบว่ามีข้อมูลผู้ใช้งานในระบบหรือไม่
        return data[0]; // คืนข้อมูลผู้ใช้งานในรูปแบบของ Map
      }
    }
    return {}; // ถ้าไม่พบข้อมูลผู้ใช้งาน ให้คืน Map ว่าง
  }

  static Future<bool> changePassword(
      String username, String currentPassword, String newPassword) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/users?username=$username&password=$currentPassword'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.isNotEmpty) {
          final userId = data[0]['id'];

          // สร้างอินสแตนซ์ของคลาส Users ที่มีข้อมูลรหัสผ่านใหม่เท่านั้น
          final updatedUser = {
            'username': data[0]['username'],
            'password': newPassword,
            'address': data[0]['address'],
            'phoneNumber': data[0]['phoneNumber'],
            'id': userId,
          };

          // ทำการเรียก API สำหรับการเปลี่ยนรหัสผ่าน
          final changePasswordResponse = await http.put(
            Uri.parse('$baseUrl/users/$userId'), // URL สำหรับเปลี่ยนรหัสผ่าน
            headers: {'Content-Type': 'application/json'},
            body: json
                .encode(updatedUser), // ส่ง JSON ที่มีข้อมูลเฉพาะรหัสผ่านใหม่
          );

          if (changePasswordResponse.statusCode == 200) {
            return true; // เปลี่ยนรหัสผ่านสำเร็จ
          } else {
            return false; // เกิดข้อผิดพลาดในการเปลี่ยนรหัสผ่าน
          }
        }
      }
      return false; // รหัสผ่านปัจจุบันไม่ถูกต้อง
    } catch (error) {
      print('Error changing password: $error');
      return false; // เกิดข้อผิดพลาดระหว่างการเปลี่ยนรหัสผ่าน
    }
  }
  static Future<bool> editPost(Post post) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/post/${post.id}'), // URL สำหรับแก้ไขโพสต์
        headers: {'Content-Type': 'application/json'},
        body: json.encode(post.toJson()), // ส่ง JSON โพสต์ที่แก้ไขแล้ว
      );

      if (response.statusCode == 200) {
        return true; // แก้ไขโพสต์สำเร็จ
      } else {
        return false; // เกิดข้อผิดพลาดในการแก้ไขโพสต์
      }
    } catch (error) {
      print('Error editing post: $error');
      return false; // เกิดข้อผิดพลาดระหว่างการแก้ไขโพสต์
    }
  }

static Future<bool> deletePostAndRelatedData(int postId) async {
  try {
    // ลบโพสต์
    final deletePostResponse = await ApiService.deletePost(postId);

    // print(deletePostResponse);
    if (deletePostResponse) {
      // ลบโพสต์สำเร็จ
      // ลบความคิดเห็นที่เกี่ยวข้องกับโพสต์
      final deleteCommentsResponse = await ApiService.deleteCommentsByPostId(postId);
      // print(deleteCommentsResponse);

      // ลบการแจ้งเตือนที่เกี่ยวข้องกับโพสต์
      final deleteNotificationsResponse = await ApiService.deleteNotificationsByPostId(postId);

      if (deleteCommentsResponse && deleteNotificationsResponse) {
        return true; // ลบโพสต์และข้อมูลที่เกี่ยวข้องสำเร็จ
      } else {
        return false; // เกิดข้อผิดพลาดในการลบความคิดเห็นหรือการแจ้งเตือน
      }
    } else {
      return false; // เกิดข้อผิดพลาดในการลบโพสต์
    }
  } catch (error) {
    print('Error deleting post and related data: $error');
    return false; // เกิดข้อผิดพลาดระหว่างการลบโพสต์และข้อมูลที่เกี่ยวข้อง
  }
}

static Future<bool> deleteCommentsByPostId(int postId) async {
  try {
    // ก่อนอื่น ให้เรียก HTTP GET เพื่อดึงความคิดเห็นโดยใช้ postId
    final response = await http.get(
      Uri.parse('$baseUrl/comment?postid=$postId'),
    );

    if (response.statusCode == 200) {
      // ถ้าการ GET สำเร็จและได้รับข้อมูลการแจ้งเตือน
      final notifications = jsonDecode(response.body); // ประมวลผลข้อมูล JSON จาก response

      // ตรวจสอบว่ามีการแจ้งเตือนหรือไม่
      if (notifications.isNotEmpty) {
        // คลาส Notification นี้ควรจะเป็นโมเดลของการแจ้งเตือนของคุณ
        for (final notification in notifications) {
          final notificationId = notification['id']; // แนะนำให้เปลี่ยนตามโมเดลของคุณ

          // ใช้ HTTP DELETE เพื่อลบแต่ละการแจ้งเตือน
          final deleteResponse = await http.delete(
            Uri.parse('$baseUrl/comment/$notificationId'),
          );

          if (deleteResponse.statusCode != 200) {
            // หากเกิดข้อผิดพลาดในการลบการแจ้งเตือนใดๆ ให้คืนค่า false
            return false;
          }
        }

        // หลังจากลบทั้งหมดสำเร็จ ให้คืนค่า true
        return true;
      }
    }

    return false; // เกิดข้อผิดพลาดในการดึงหรือลบความคิดเห็น
  } catch (error) {
    print('Error deleting comments: $error');
    return false; // เกิดข้อผิดพลาดระหว่างการลบความคิดเห็น
  }
}


static Future<bool> deleteNotificationsByPostId(int postId) async {
  try {
    // ก่อนอื่น ให้เรียก HTTP GET เพื่อดึงข้อมูลการแจ้งเตือนที่เกี่ยวข้องกับ postId
    final response = await http.get(
      Uri.parse('$baseUrl/notifications?post_id=$postId'),
    );

    if (response.statusCode == 200) {
      // ถ้าการ GET สำเร็จและได้รับข้อมูลการแจ้งเตือน
      final notifications = jsonDecode(response.body); // ประมวลผลข้อมูล JSON จาก response

      // ตรวจสอบว่ามีการแจ้งเตือนหรือไม่
      if (notifications.isNotEmpty) {
        // คลาส Notification นี้ควรจะเป็นโมเดลของการแจ้งเตือนของคุณ
        for (final notification in notifications) {
          final notificationId = notification['id']; // แนะนำให้เปลี่ยนตามโมเดลของคุณ

          // ใช้ HTTP DELETE เพื่อลบแต่ละการแจ้งเตือน
          final deleteResponse = await http.delete(
            Uri.parse('$baseUrl/notifications/$notificationId'),
          );

          if (deleteResponse.statusCode != 200) {
            // หากเกิดข้อผิดพลาดในการลบการแจ้งเตือนใดๆ ให้คืนค่า false
            return false;
          }
        }

        // หลังจากลบทั้งหมดสำเร็จ ให้คืนค่า true
        return true;
      }
    }

    return false; // เกิดข้อผิดพลาดในการดึงหรือลบการแจ้งเตือน
  } catch (error) {
    print('Error deleting notifications: $error');
    return false; // เกิดข้อผิดพลาดระหว่างการลบการแจ้งเตือน
  }
}



static Future<bool> deletePost(int postId) async {
  try {
    final response = await http.delete(
      Uri.parse('$baseUrl/post/$postId'),
    );

    if (response.statusCode == 200) {
      return true; // ลบโพสต์สำเร็จ
    } else {
      return false; // เกิดข้อผิดพลาดในการลบโพสต์
    }
  } catch (error) {
    print('Error deleting post: $error');
    return false; // เกิดข้อผิดพลาดระหว่างการลบโพสต์
  }
}
  Future<String> getUsernameByPostId(int postId) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/post/$postId'),
    );
    // print()

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // print('aaaa');
      print(data['username']);

      if (data.isNotEmpty) {
        return data['username'];
      }
    }
    return 'null'; // ถ้าไม่พบข้อมูลหรือเกิดข้อผิดพลาด
  } catch (error) {
    print('Error getting username by post id: $error');
    return 'null'; // เกิดข้อผิดพลาดระหว่างการเรียกข้อมูล
  }
  }
static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('userId');
  }
}

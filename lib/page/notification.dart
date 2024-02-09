import 'package:flutter/material.dart';
import 'package:LotTalk/model/apimodel.dart';
import '../model/api_service.dart';

class NotificationPage extends StatefulWidget {
  final String email;
  final String phoneNumber;
  final String username;

  NotificationPage(
      {required this.username, required this.email, required this.phoneNumber});
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<Notificationaa> notifications = [];

  @override
  void initState() {
    super.initState();
    loadNotifications();
  }

Future<void> loadNotifications() async {
  try {
    final loadedNotifications =
        await ApiService.getNotificationsByUsername(widget.username);
    setState(() {
      // กรองรายการการแจ้งเตือนเฉพาะที่เกี่ยวข้องกับ username คนอื่นที่กระทำกับโพสต์นั้น ๆ
      notifications = loadedNotifications
          .where((notification) =>
              notification.username == widget.username)
          .toList();
    });
  } catch (error) {
    print('Error loading notifications: $error');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 156, 100, 32),
      body: notifications.isEmpty
          ? Center(
              child: Text('No notifications yet.'),
            )
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Card(
                  elevation: 2, // เพิ่มเงาให้กับการแจ้งเตือน
                  margin: EdgeInsets.symmetric(
                      vertical: 8, horizontal: 5), // กำหนดระยะห่าง
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(30.0), // ปรับขอบของ Card
                  ),
                  child: ListTile(
                    title: Text(
                      notification.type == 'like'
                          ? 'Liked your post'
                          : 'Commented on your post',
                      style: TextStyle(
                        fontWeight: FontWeight.bold, // ตัวหนา
                      ),
                    ),
                    subtitle: Text(
                        notification.des ?? ''), // แสดงค่า "des" ใน subtitle
                    trailing: Text(
                      notification.time ?? '',
                      style: TextStyle(
                        fontStyle: FontStyle.normal, // ตัวเอียง
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

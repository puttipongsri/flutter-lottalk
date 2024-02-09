import 'package:LotTalk/page/ranking.dart';
import 'package:flutter/material.dart';
import 'package:LotTalk/page/post.dart';
import 'page/home_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'page/account.dart';
import 'page/notification.dart';

import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';

class WelcomePage extends StatefulWidget {
  final String email;
  final String phoneNumber;
  final String username;

  const WelcomePage({
    Key? key,
    required this.email,
    required this.phoneNumber,
    required this.username,
  }) : super(key: key);

  @override
  _WelcomePage createState() => _WelcomePage();
}

class _WelcomePage extends State<WelcomePage> {
  final _pageController = PageController(initialPage: 0);
  final _controller = NotchBottomBarController(index: 0);
  int maxCount = 4;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List bottomBarPages = [
  Page1(username : widget.username, email: widget.email, phoneNumber: widget.phoneNumber,),
  Page2(username : widget.username, email: widget.email, phoneNumber: widget.phoneNumber,),
  Page4(),
  Page3(
    email: widget.email,
    phoneNumber: widget.phoneNumber,
    avatarUrl: 'https://cdn.discordapp.com/attachments/893088061276192790/1157654921999556749/14_20230930192421.png?ex=651965a9&is=65181429&hm=ca193e18e756f555cee1948ca31d16816d5617d4d9850e2d0aa3f4689b6de808&',
    username : widget.username
  ),
];
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(
            bottomBarPages.length, (index) => bottomBarPages[index]),
      ),
      extendBody: true,
      bottomNavigationBar: (bottomBarPages.length <= maxCount)
          ? AnimatedNotchBottomBar(
              /// Provide NotchBottomBarController
              notchBottomBarController: _controller,
              color: Color.fromARGB(255, 194, 170, 135), // สีพื้นหลังของ BottomNavigationBar
              showLabel: false,
              notchColor: Color.fromARGB(221, 230, 230, 230),

              /// restart app if you change removeMargins
              removeMargins: false,
              bottomBarWidth: 500,
              durationInMilliSeconds: 300,
              bottomBarItems: const [
                BottomBarItem(
                  inActiveItem: Icon(
                    Icons.home_filled,
                    color: Color.fromARGB(255, 255, 255, 255), // สีของไอคอนที่ไม่ได้เลือก
                  ),
                  activeItem: Icon(
                    Icons.home_filled,
                    color: Color.fromARGB(255, 255, 0, 212), // สีของไอคอนที่เลือก
                  ),
                  itemLabel: 'Home',
                ),
                BottomBarItem(
                  inActiveItem: Icon(
                    Icons.notification_important_outlined,
                    color: Color.fromARGB(255, 255, 255, 255), // สีของไอคอนที่ไม่ได้เลือก
                  ),
                  activeItem: Icon(
                    Icons.notification_important_outlined,
                    color: Color.fromARGB(255, 255, 0, 212), // สีของไอคอนที่เลือก

                  ),
                  itemLabel: 'Notifications',
                ),
                BottomBarItem(
                  inActiveItem: Icon(
                    Icons.cabin_outlined,
                    color: Color.fromARGB(255, 255, 255, 255), // สีของไอคอนที่ไม่ได้เลือก
                  ),
                  activeItem: Icon(
                    Icons.cabin_outlined,
                    color: Color.fromARGB(255, 255, 0, 212), // สีของไอคอนที่เลือก

                  ),
                  itemLabel: 'Ranking',
                ),
                BottomBarItem(
                  inActiveItem: Icon(
                    Icons.person_2_outlined,
                    color: Color.fromARGB(255, 255, 255, 255), // สีของไอคอนที่ไม่ได้เลือก
                  ),
                  activeItem: Icon(
                    Icons.person_2_outlined,
                    color: Color.fromARGB(255, 255, 0, 212), // สีของไอคอนที่เลือก

                  ),
                  itemLabel: 'Account',
                ),
              ],
              onTap: (index) {
                /// perform action on tab change and to update pages you can update pages without pages
                // log('current selected index $index');
                _pageController.jumpToPage(index);
              },
            )
          : null,
    );
  }
}

class Page1 extends StatelessWidget {
    final String username;
    final String email;
    final String phoneNumber;

  const Page1({
    Key? key,
    required this.username,
    required this.email,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // นำข้อมูล email และ phoneNumber ไปใช้งานใน HomeScreen ตามที่คุณต้องการ
    return HomeScreen(username: username, email: email, phoneNumber: phoneNumber,);
  }
}

class Page2 extends StatelessWidget {
    final String username;
    final String email;
    final String phoneNumber;

  const Page2({
    Key? key,
    required this.username,
    required this.email,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // นำข้อมูล email และ phoneNumber ไปใช้งานใน HomeScreen ตามที่คุณต้องการ
    return NotificationPage(username: username, email: email, phoneNumber: phoneNumber,);
  }
}

class Page4 extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    // นำข้อมูล email และ phoneNumber ไปใช้งานใน HomeScreen ตามที่คุณต้องการ
    return RankingPage();
  }
}



class Page3 extends StatelessWidget {
  final String email;
  final String phoneNumber;
  final String avatarUrl;
  final String username;

  const Page3({
    Key? key,
    required this.email,
    required this.phoneNumber,
    required this.avatarUrl,
    required this.username,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AccountPage(email: email, phoneNumber: phoneNumber, avatarUrl: avatarUrl, username: username,);
  }
}

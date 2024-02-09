import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:social_katchup/utils/myTextStyle.dart';

class NewsFeedCard extends StatelessWidget {
  const NewsFeedCard({
    Key? key,
    required this.size,
    required this.nf,
    this.index,
    this.color,
  }) : super(key: key);

  final Size size;
  final dynamic nf;
  final dynamic index;
  final dynamic color;

  static Widget buildNewsFeedCard({
    required Size size,
    @required dynamic nf,
    int? index,
    dynamic color,
  }) {
    return Card(
      color: color == null ? Colors.white : color,
      child: Container(
        constraints: BoxConstraints(
          minHeight: 50.0,
          maxHeight: 370.0,
          minWidth: size.width,
          maxWidth: size.width,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.w),
          child: Wrap(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: AssetImage(nf.avatarUrl),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nf.username,
                          ),
                        ],
                      ),
                    ],
                  ),
                  Icon(Icons.more_horiz, size: 30, color: Colors.grey),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(left: 55.w, top: 8.w),
                child: Column(
                  children: [
                    Text(
                      nf.textpost,
                    ),
                    SizedBox(height: 8.0),
                    nf.img_path != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              child: Image(image: AssetImage(nf.imageUrl)),
                            ),
                          )
                        : SizedBox.shrink(),
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            index != 1
                                ? Icon(Icons.favorite_border, color: Colors.grey)
                                : Container(width: 25),
                            SizedBox(width: 8),
                            Icon(Icons.message, color: Colors.grey),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}

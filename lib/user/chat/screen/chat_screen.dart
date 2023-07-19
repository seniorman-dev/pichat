import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pichat/theme/app_theme.dart';
import 'package:pichat/user/chat/widget/friends_list.dart';
import 'package:pichat/user/chat/widget/recent_chats.dart';
import 'package:pichat/user/notifications/screen/notifications_sceen.dart';




class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppTheme().whiteColor,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 20.h,
                vertical: 20.w
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello Japhet,',
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                        color: AppTheme().darkGreyColor,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500
                      )
                    ),
                  ),
                  //SizedBox(height: 5.h,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.placemark_fill,
                            color: AppTheme().blackColor,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            'Shomolu Lagos, Nigeria.',
                            style: GoogleFonts.poppins(
                              color: AppTheme().blackColor,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500
                            ),
                          )
                        ],
                      ),
                      IconButton(
                        icon: Icon(
                          CupertinoIcons.bell_fill,
                          color: AppTheme().mainColor,
                          size: 30.r,
                        ),
                        onPressed: () {
                          Get.to(() => NotificationScreen());
                        },

                      ),
                    ],
                  )
                ],
              ),
            ),
            SizedBox(height: 10.h,),
            //list of friends
            FriendsList(),
            Divider(color: AppTheme().darkGreyColor, thickness: 1,),
            SizedBox(height: 10.h,), //30.h
            RecentChats(),
            SizedBox(height: 10.h,),
          ]
        ),
      ),
    );
  }
}
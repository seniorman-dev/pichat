import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pichat/api/api.dart';
import 'package:pichat/theme/app_theme.dart';
import 'package:pichat/user/settings/widget/all_users_list.dart';






class FriendsList extends StatelessWidget {
  const FriendsList({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170.h, //200.h
      child: ListView.separated(
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal, //Axis.vertical,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        separatorBuilder: (context, index) => SizedBox(width: 20.w),
        itemCount: 10,
        itemBuilder: (context, index) {
          if(index == 0) {
            return Column(
              children: [
                InkWell(
                  onTap: () {
                    /*API().sendPushNotificationWithFirebaseAPI(
                      receiverFCMToken: "eIM5YHWxQDOR1asjgpB5cV:APA91bED81BPl4r06ztWSQ7k34A2L8-HvVKQFKV8y5wdWe4TpVZi64KbGCYY-qSJhDvmCsRyAxTTcq8anaXQ06gVEKpYrYdrxjbzJfEgs3VPvDPE6U6lm5dFK8Rqv3-ylbty4WyYbesw", 
                      title: 'Hey Japhet', 
                      content: 'How are you doind today',
                    );*/
                    Get.to(() => const AllUsersList());
                  },
                  child: CircleAvatar(
                    radius: 40.r,
                    backgroundColor: AppTheme().lightGreyColor,
                    child: Icon(
                      CupertinoIcons.add,
                      color: AppTheme().blackColor,
                      size: 40.r,
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  'Add Friend',
                  style: GoogleFonts.poppins(
                    color: AppTheme().blackColor,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500
                  ),
                )
              ],
            );
          }
          else {
            return Column(
              children: [
                CircleAvatar(
                  radius: 40.r,
                  backgroundColor: AppTheme().opacityBlue,
                  child: CircleAvatar(
                    radius: 38.r,
                    backgroundColor: AppTheme().lightGreyColor,
                    child: Icon(
                      CupertinoIcons.person,
                      color: AppTheme().blackColor,
                      size: 40.r,
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  'Angelo',
                  style: GoogleFonts.poppins(
                    color: AppTheme().blackColor,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500
                  ),
                )
              ],
            );
          }
        }
      )
    );
  }
}
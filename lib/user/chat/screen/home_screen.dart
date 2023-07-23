import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pichat/auth/controller/auth_controller.dart';
import 'package:pichat/theme/app_theme.dart';
import 'package:pichat/user/chat/widget/friends_list.dart';
import 'package:pichat/user/chat/widget/recent_chats_list.dart';
import 'package:pichat/user/chat/widget/search_recent_charts.dart';
import 'package:pichat/user/notifications/screen/notifications_sceen.dart';
import 'package:pichat/utils/extract_firstname.dart';
import 'package:provider/provider.dart';






class ChatScreen extends StatelessWidget {
  ChatScreen({super.key});
  final TextEditingController textController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    var controller = Provider.of<AuthController>(context);
    //String? name = controller.gUser!.displayName!.substring(0, 6);
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppTheme().whiteColor,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 20.w, //25.W
                vertical: 20.h
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StreamBuilder(
                    stream: controller.firestore.collection('users').doc(controller.userID).snapshots(),
                    builder: (context, snapshot) {
                      //var data = snapshot.data!.data();  //how to call document snapshots
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        // Show a loading indicator while waiting for data
                        return Text(
                          '...',
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              color: AppTheme().darkGreyColor,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500
                            )
                          ),
                        );
                      } 
                      else if (snapshot.hasError) {
                        // Handle error if any
                        return Text(
                          'Error: ${snapshot.error}',
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              color: AppTheme().darkGreyColor,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500
                            )
                          ),
                        );
                      } 
                      else if (snapshot.hasData) {
                        // Check if the snapshot has data before accessing it
                        var data = snapshot.data!.data(); // Use null check operator (!) on data
                        if (data != null) {
                          // Access the data safely
                          var firstName = getFirstName(fullName: data['name']);   // Replace 'firstName' with your key
                          return Text(
                            'Hello $firstName',
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                color: AppTheme().darkGreyColor,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500
                              )
                            ),
                          );
                        } 
                        else {
                          return Text(
                            'Data not found',
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                color: AppTheme().darkGreyColor,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500
                              )
                            ),
                          );
                        }
                      } 
                      else {
                        return SizedBox();
                      }
                    }
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
                          CupertinoIcons.bell,
                          color: AppTheme().blackColor,
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
            SizedBox(height: 5.h,),
            //list of friends
            FriendsList(),
            Divider(color: AppTheme().darkGreyColor, thickness: 1,),
            SizedBox(height: 20.h,), //30.h
            //search for recent chats
            SearchRecentChatTextField(
              textController: textController,
              onChanged: (value) {},
            ),
            SizedBox(height: 20.h,), //30.h
            //recent chats
            RecentChats(),
            SizedBox(height: 10.h,),
          ]
        )      
      ),
    );
  }
}
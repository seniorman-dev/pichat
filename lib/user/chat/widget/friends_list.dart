import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pichat/auth/controller/auth_controller.dart';
import 'package:pichat/theme/app_theme.dart';
import 'package:pichat/user/chat/controller/chat_service_controller.dart';
import 'package:pichat/user/chat/screen/dm_screen.dart';
import 'package:pichat/utils/error_loader.dart';
import 'package:pichat/utils/extract_firstname.dart';
import 'package:pichat/utils/loader.dart';
import 'package:provider/provider.dart';








class FriendsList extends StatelessWidget {
  const FriendsList({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Provider.of<AuthController>(context);
    var chatServiceController = Provider.of<ChatServiceController>(context);
    return StreamBuilder(
      stream: controller.firestore.collection('users').doc(controller.userID).collection('friends').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator while waiting for data
          return const Loader();
        } 
        else if (snapshot.hasError) {
          // Handle error if any
          return const ErrorLoader();
        }
        else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 25.r,
                backgroundColor: AppTheme().lightestOpacityBlue,
                child: Icon(
                  CupertinoIcons.person_badge_plus,
                  color: AppTheme().mainColor,
                  size: 25.r,
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                'Add connections to your list',
                style: GoogleFonts.poppins(
                  color: AppTheme().greyColor,
                  fontSize: 13.sp,
                  //fontWeight: FontWeight.w500
                ),
              )
            ],
          );
        }
        else {
          return SizedBox(
            height: 170.h, //200.h
            child: ListView.separated(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal, //Axis.vertical,
              padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 20.h),
              separatorBuilder: (context, index) => SizedBox(width: 20.w),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var data = snapshot.data!.docs[index];
                return Column(
                  children: [
                    InkWell(
                      onTap: () async{
                        //did this to retrieve logged in user information
                        DocumentSnapshot snapshot = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(controller.userID)
                        .get();
                        String userName = snapshot.get('name');
                        String userId = snapshot.get('id');
                        ////////////////////////

                        Get.to(() => DMScreen(
                          isOnline: true, //data['isOnline'],
                          receiverProfilePic: data['photo'],
                          receiverID: data['id'],
                          receiverName: data['name'], 
                          senderName: userName, 
                          senderId: userId,
                        ));
                        //chatServiceController.updateisSeenStatus(isSeen: true, receiverId: data['id'],);
                        //chatServiceController.updateOnlineStatus(isOnline: true);
                      },
                      onLongPress: () {
                        chatServiceController.removeUserFromFriendList(friendId: data['id']);
                      },
                      child: CircleAvatar(
                        radius: 40.r,
                        backgroundColor: AppTheme().opacityBlue,
                        child: CircleAvatar(
                          radius: 38.r,
                          backgroundColor: AppTheme().lightGreyColor,
                          child: Icon(    ////data['photo']
                            CupertinoIcons.person,
                            color: AppTheme().blackColor,
                            size: 40.r,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      getFirstName(fullName: data['name']),
                      style: GoogleFonts.poppins(
                        color: AppTheme().blackColor,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500
                      ),
                    )
                  ],
                );
              }
          
          )
        );
        }
        
      }
    );
  }
}
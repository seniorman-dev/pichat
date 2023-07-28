import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pichat/api/api.dart';
import 'package:pichat/auth/controller/auth_controller.dart';
import 'package:pichat/theme/app_theme.dart';
import 'package:pichat/user/chat/screen/dm_screen.dart';
import 'package:pichat/utils/error_loader.dart';
import 'package:pichat/utils/loader.dart';
import 'package:provider/provider.dart';








class FriendsList extends StatelessWidget {
  const FriendsList({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Provider.of<AuthController>(context);
    return StreamBuilder(
      stream: controller.firestore.collection('users').doc(controller.userID).collection('friends').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator while waiting for data
          return Loader();
        } 
        else if (snapshot.hasError) {
          // Handle error if any
          return ErrorLoader();
        }
        else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 30.r,
                backgroundColor: AppTheme().lightestOpacityBlue,
                child: Icon(
                  CupertinoIcons.person_badge_plus,
                  color: AppTheme().mainColor,
                  size: 30.r,
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
              physics: BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal, //Axis.vertical,
              padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 20.h),
              separatorBuilder: (context, index) => SizedBox(width: 20.w),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var data = snapshot.data!.docs[index];
                //get logged in user's name from local storage
                String getUserName() {
                  final box = GetStorage();
                  return box.read('name') ?? ''; // Return an empty string if data is not found
                }
                return Column(
                  children: [
                    InkWell(
                      onTap: () {
                        Get.to(() => DMScreen(
                          isOnline: true,  //data['isOnline'],
                          receiverProfilePic: data['photo'],
                          receiverID: data['id'],
                          receiverName: data['name'], 
                          senderName: getUserName(),  //currentUserName controller.firebase.currentUser!.email
                        ));
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
                      data['name'],
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
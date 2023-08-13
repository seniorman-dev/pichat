import 'package:cached_network_image/cached_network_image.dart';
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
import 'package:pichat/utils/loader.dart';
import 'package:provider/provider.dart';










class MyConnects extends StatelessWidget {
  const MyConnects({super.key});

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
                'No connections found',
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
          return ListView.separated(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.vertical,
            //padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 20.h),
            separatorBuilder: (context, index) => SizedBox(width: 20.w),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {

              var data = snapshot.data!.docs[index];
                    
              return InkWell(
                onTap: () async{
                  //did this to retrieve logged in user information
                  DocumentSnapshot snapshot = await FirebaseFirestore.instance
                  .collection('users')
                  .doc(controller.userID)
                  .get();
                  String userName = snapshot.get('name');
                  String userId = snapshot.get('id');
                  String userPhoto = snapshot.get('photo');
                  ////////////////////////                 
                  //did this to retrieve chat buddy's info
                  DocumentSnapshot snapshotForUser = await FirebaseFirestore.instance
                  .collection('users')
                  .doc(data['id'])
                  .get();
                  bool isChatBuddyOnline = snapshotForUser.get('isOnline');
                  ///////////////////////             
                  Get.to(() => DMScreen(
                    isOnline: isChatBuddyOnline,
                    receiverProfilePic: data['photo'],
                    receiverID: data['id'],
                    receiverName: data['name'], 
                    senderName: userName, 
                    senderId: userId, 
                    //lastActive: "${formatTime(timestamp: data['lastActive'])} on ${formatDate(timestamp: data['lastActive'])}",
                  ));
                  //chatServiceController.updateisSeenStatus(isSeen: true, receiverId: data['id'],);
                  //chatServiceController.updateOnlineStatus(isOnline: true);
                },
                onLongPress: () {
                  chatServiceController.removeUserFromFriendList(friendId: data['id']);
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 25.w,
                    vertical: 20.h,
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 20.h, //20.h
                      horizontal: 15.w  //15.h
                    ),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: AppTheme().whiteColor,
                      borderRadius: BorderRadius.circular(30.r), //20.r
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 0.1.r,
                          blurRadius: 8.0.r,
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 40.r,
                          backgroundColor: AppTheme().opacityBlue,
                          child: CircleAvatar(
                            radius: 38.r,
                            backgroundColor: data['photo'] == null ? AppTheme().darkGreyColor : AppTheme().blackColor,
                            child: data['photo'] != null
                            ?ClipRRect(
                              borderRadius: BorderRadius.all(Radius.circular(10.r)), //.circular(20.r),
                              clipBehavior: Clip.antiAlias, //.antiAliasWithSaveLayer,
                              child: CachedNetworkImage(
                                imageUrl: data['photo'],
                                width: 50.w,
                                height: 50.h,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Loader(),
                                errorWidget: (context, url, error) => Icon(
                                  Icons.error,
                                  color: AppTheme().lightestOpacityBlue,
                                ),
                              ),
                            ) : null
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //SizedBox(height: 10.h),
                              Text(
                                data['name'],  //getFirstName(fullName: data['name']),
                                style: GoogleFonts.poppins(
                                  color: AppTheme().blackColor,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500
                                ),
                              ),
                              SizedBox(height: 10.h),
                              Text(
                                'Tap to message',  //getFirstName(fullName: data['name']),
                                style: GoogleFonts.poppins(
                                  color: AppTheme().darkGreyColor,
                                  fontSize: 14.sp,
                                  //fontWeight: FontWeight.w500,
                                  textStyle: TextStyle(
                                    overflow: TextOverflow.ellipsis
                                  )
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),         
                ),
              );
            }       
          );
        }  
      }
    );
  }
}
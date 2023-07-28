import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pichat/auth/controller/auth_controller.dart';
import 'package:pichat/theme/app_theme.dart';
import 'package:pichat/user/chat/controller/chat_service_controller.dart';
import 'package:pichat/user/chat/widget/friend_request_button.dart';
import 'package:pichat/utils/error_loader.dart';
import 'package:pichat/utils/firestore_timestamp_formatter.dart';
import 'package:pichat/utils/loader.dart';
import 'package:provider/provider.dart';
import 'package:date_time_format/date_time_format.dart';
import 'package:shared_preferences/shared_preferences.dart';








class AllUsersList extends StatefulWidget {
  const AllUsersList({super.key});

  @override
  State<AllUsersList> createState() => _AllUsersListState();
}

class _AllUsersListState extends State<AllUsersList> {


  @override
  Widget build(BuildContext context) {
    var controller = Provider.of<AuthController>(context);
    var chatServiceController = Provider.of<ChatServiceController>(context);
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppTheme().whiteColor,
        appBar: AppBar(
          backgroundColor: AppTheme().whiteColor,
          centerTitle: true,
          elevation: 0,
          leading: SizedBox(
            height: 50.h,
            width: 85.w,
            child: IconButton(
              onPressed: () {
                Get.back();
              }, 
              icon: Icon(
                CupertinoIcons.back,
                color: AppTheme().blackColor,
                size: 30.r,
              ),
            ),
          ),
          title: const Text(
            'Find Connects'
          ),
          titleSpacing: 2,
          titleTextStyle: GoogleFonts.poppins(
            textStyle: TextStyle(
              color: AppTheme().blackColor,
              fontSize: 15.sp,
              fontWeight: FontWeight.w500
            )
          ),
        ),
        body: StreamBuilder(
          stream: controller.firestore.collection('users').snapshots(),
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
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 25.w,
                  vertical: 20.h,
                ),
                child: Center(
                  child: Column(
                    //mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 200.h,),
                      CircleAvatar(
                        radius: 100.r,
                        backgroundColor: AppTheme().lightestOpacityBlue,
                          child: Icon(
                          CupertinoIcons.person_crop_circle_badge_xmark,
                          color: AppTheme().mainColor,
                          size: 70.r,
                        ),
                      ),
                      SizedBox(height: 50.h),
                      Text(
                        'No connects found',
                        style: GoogleFonts.poppins(
                          color: AppTheme().greyColor,
                          fontSize: 14.sp,
                          //fontWeight: FontWeight.w500
                        ),
                      )
                    ],
                  ),
                ),
              );
            }
            else {
    
              return ListView.separated(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                separatorBuilder: (context, index) => SizedBox(height: 0.h,), 
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var data = snapshot.data!.docs[index];
                  //to uniquely select users
                  var isSelected = chatServiceController.selectedDocumentIdForAllUsers.contains(data['id']); 
                  //exclude currently logged in user from the list of general users
                  ////data['id'] != controller.firebase.currentUser!.uid
                  if(snapshot.hasData){  
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 25.w,
                        vertical: 5.h //20.h
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: 30.h,),
                          Container(
                            height: 100.h,
                            padding: EdgeInsets.symmetric(
                              vertical: 15.h, //20.h
                              horizontal: 15.w  //20.h
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme().whiteColor,
                              borderRadius: BorderRadius.circular(20.r),
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
                                //profilePic
                                CircleAvatar(
                                  radius: 32.r,
                                  backgroundColor: AppTheme().opacityBlue,
                                  child: CircleAvatar(
                                    radius: 30.r,
                                    backgroundColor: AppTheme().darkGreyColor,
                                  ),
                                ),
                                SizedBox(width: 10.w,),
                                //details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data['name'],
                                        style: GoogleFonts.poppins(
                                          color: AppTheme().blackColor,
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w500
                                        ),
                                      ),
    
                                      SizedBox(height: 4.h,),
    
                                      //Row 2
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            data['isOnline'] ? 'online' : 'offline',
                                            style: GoogleFonts.poppins(
                                              color: AppTheme().darkGreyColor, //specify color when user is online or offline
                                              fontSize: 14.sp, //14.sp
                                              fontWeight: FontWeight.w500,
                                              textStyle: const TextStyle(
                                                overflow: TextOverflow.ellipsis
                                              )
                                            ),
                                          ),
    
                                          ////send connect request button
                                          /*SizedBox(
                                            height: 35.h,
                                            //width: 85.w,
                                            child: ElevatedButton(
                                              onPressed: () {},
                                              style: ElevatedButton.styleFrom(
                                                elevation: 2,
                                                backgroundColor: AppTheme().mainColor,
                                                minimumSize: Size.copy(Size(100.w, 50.h)),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),                                          ),        
                                              /*icon: Icon(
                                                chatServiceController.isAdded ? CupertinoIcons.clear_thick_circled: CupertinoIcons.person_crop_circle_fill_badge_plus,
                                                color: AppTheme().whiteColor,
                                                size: 18.r,
                                              ),*/
                                              child: Text(
                                                'connect',
                                                style: GoogleFonts.poppins(
                                                  textStyle: TextStyle(
                                                    color: AppTheme().whiteColor,
                                                    fontSize: 10.sp,
                                                    fontWeight: FontWeight.w500
                                                  )
                                                ),
                                              )
      
                                            ),
                                          )*/
                                          FriendRequestButton(
                                            currentUserId: chatServiceController.auth.currentUser!.uid, 
                                            receiverID: data['id'], 
                                            receiverName: data['name'], 
                                            receiverProfilePic: 'photo', //data['photo'],
                                            isSelected: isSelected,
                                          )                            
                                        ]
                                      )
                                    ]
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return null;
                }, 
              );
            }         
          }
        ),
      ),
    );
  }
}

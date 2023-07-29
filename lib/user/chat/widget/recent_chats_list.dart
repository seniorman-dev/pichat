import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pichat/theme/app_theme.dart';
import 'package:pichat/user/chat/controller/chat_service_controller.dart';
import 'package:pichat/user/chat/screen/dm_screen.dart';
import 'package:pichat/utils/error_loader.dart';
import 'package:pichat/utils/firestore_timestamp_formatter.dart';
import 'package:pichat/utils/loader.dart';
import 'dart:math';

import 'package:provider/provider.dart';






class RecentChats extends StatefulWidget {
  RecentChats({super.key, required this.isSearching, required this.textController});
  final TextEditingController textController;
  bool isSearching;

  @override
  State<RecentChats> createState() => _RecentChatsState();
}

class _RecentChatsState extends State<RecentChats> with WidgetsBindingObserver {

  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  //get the instance of firebaseauth and cloud firestore
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // widgets binding observer helps us to check if user is actively using the app (online) or not.
  // it check the state of our app
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // TODO: Handle this case. (update 'isOnline' field accordingly)
        firestore.collection('users').doc(auth.currentUser!.uid).update({"isOnline": true});
        break;
      case AppLifecycleState.inactive:
        // TODO: Handle this case.
        firestore.collection('users').doc(auth.currentUser!.uid).update({"isOnline":false});
        break;
      case AppLifecycleState.paused:
        // TODO: Handle this case.
        firestore.collection('users').doc(auth.currentUser!.uid).update({"isOnline": false});
        break;
      case AppLifecycleState.detached:
        // TODO: Handle this case.
        firestore.collection('users').doc(auth.currentUser!.uid).update({"isOnline": false});
        break;
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    var chatServiceontroller = Provider.of<ChatServiceController>(context);
    return StreamBuilder(
      stream: widget.isSearching ? chatServiceontroller.firestore.collection('users').doc(chatServiceontroller.auth.currentUser!.uid).collection('recent_chats').where("name", isEqualTo: widget.textController.text).snapshots() : chatServiceontroller.firestore.collection('users').doc(chatServiceontroller.auth.currentUser!.uid).collection('recent_chats').snapshots(),
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
                  SizedBox(height: 20.h,),
                  CircleAvatar(
                    radius: 100.r,
                    backgroundColor: AppTheme().lightestOpacityBlue,
                      child: Icon(
                      CupertinoIcons.chat_bubble,
                      color: AppTheme().mainColor,
                      size: 70.r,
                    ),
                  ),
                  SizedBox(height: 30.h),
                  Text(
                    "You don't have any recent messages yet",
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
          return Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              //separatorBuilder: (context, index) => SizedBox(height: 0.h,), 
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {

                var data = snapshot.data!.docs[index];
          
                return Dismissible(
                  key: UniqueKey(),
                  direction: DismissDirection.endToStart,
                  background: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        CupertinoIcons.delete_simple,
                        color: AppTheme().redColor                     
                      )
                    ]
                  ),
                  onDismissed: (direction) {
                    chatServiceontroller.deleteUserFromRecentChats(friendId: data['id']);
                  },
                  child: InkWell(
                    onTap: () async{
                      //did this to retrieve logged in user information
                      DocumentSnapshot snapshot = await FirebaseFirestore.instance
                      .collection('users')
                      .doc(chatServiceontroller.auth.currentUser!.uid)
                      .get();
                      String userName = snapshot.get('name');
                      String userId = snapshot.get('id');
                      ////////////////////////

                      Get.to(() => DMScreen(
                        isOnline: true, 
                        receiverName: data['name'],
                        receiverProfilePic: data['photo'],
                        receiverID: data['id'], 
                        senderName: userName,
                        senderId: userId,
                      ));
                        
                      chatServiceontroller.updateisSeenStatus(isSeen: true, receiverId: data['id']);
                      //chatServiceontroller.updateOnlineStatus(isOnline: true);
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.h,
                        vertical: 8.w
                      ),
                      child: Container(
                        //height: 100.h,
                        //width: 200.w,
                        padding: EdgeInsets.symmetric(
                          vertical: 20.h, //30.h
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
                            //profilePic  //data['photo'],
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
                                  //Row 1
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        data['name'],
                                        style: GoogleFonts.poppins(
                                          color: AppTheme().blackColor,
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w500
                                        ),
                                      ),
                                      Text(
                                        formatTime(timestamp: data['timestamp']),
                                        style: GoogleFonts.poppins(
                                          color: AppTheme().darkGreyColor,
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w500
                                        ),
                                      )
                                    ],
                                  ),
                                  SizedBox(height: 4.h,),
                                  //Row 2
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      //figure this out
                                      //show when a receiver sends a new message then disappear when the current user taps on it
                                      Text(
                                        data['lastMessage'],
                                        style: GoogleFonts.poppins(
                                          color: AppTheme().darkGreyColor,
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w500,
                                          textStyle: TextStyle(
                                            overflow: TextOverflow.ellipsis
                                          )
                                        ),
                                      ),

                                      //find a way to show this status bar when your chat partner sends you a message
                                      CircleAvatar(
                                        backgroundColor: AppTheme().mainColor,
                                        radius: 7.r,
                                        /*child: Text(
                                          '2',
                                          style: GoogleFonts.poppins(
                                            textStyle: TextStyle(
                                              color: AppTheme().whiteColor,
                                              fontSize: 9.sp,
                                              //fontWeight: FontWeight.w500
                                            )
                                          ),
                                        ),*/
                                      )
                                    ],
                                  )
                                ]
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }
            ),
          );
        }
      }
    );
  }
}
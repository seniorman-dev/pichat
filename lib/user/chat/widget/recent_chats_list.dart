import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pichat/theme/app_theme.dart';
import 'package:pichat/user/chat/controller/chat_service_controller.dart';
import 'package:pichat/user/chat/screen/dm_screen.dart';
import 'package:pichat/utils/error_loader.dart';
import 'package:pichat/utils/firestore_timestamp_formatter.dart';
import 'package:pichat/utils/loader.dart';
import 'package:provider/provider.dart';










// ignore: must_be_immutable
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

  //get the instance of firebaseauth and cloud firestore for the purpose below
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

    //dependency injection
    var chatServiceController = Provider.of<ChatServiceController>(context);

    return StreamBuilder(
      stream: chatServiceController.firestore.collection('users').doc(chatServiceController.auth.currentUser!.uid).collection('recent_chats').snapshots(),
      builder: (context, snapshot) {

        //filtered list
        var filteredList = snapshot.data!.docs.where((element) => element['name'].toString().contains(chatServiceController. recentChatsTextController.text)).toList();

        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator while waiting for data
          return const Loader();
        } 
        else if (snapshot.hasError) {
          // Handle error if any
          return const ErrorLoader();
        }
        else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) { //!snapshot.hasData || snapshot.data!.docs.isEmpty
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
                  SizedBox(height: 30.h,),
                  CircleAvatar(
                    radius: 70.r,
                    backgroundColor: AppTheme().lightestOpacityBlue,
                      child: Icon(
                      CupertinoIcons.chat_bubble,
                      color: AppTheme().mainColor,
                      size: 40.r,
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
          return SizedBox(
            height: 250.h,
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(), //const BouncingScrollPhysics(),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              //separatorBuilder: (context, index) => SizedBox(height: 0.h,), 
              itemCount: chatServiceController.isSearchingRecentChats ? filteredList.length : snapshot.data!.docs.length,  //filteredList.length,
              itemBuilder: (context, index) {

                var data2 = snapshot.data!.docs[index];  //normal list

                var data = filteredList[index];  //filtered list
          
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
                    chatServiceController.deleteUserFromRecentChats(friendId: chatServiceController.isSearchingRecentChats ? data['id'] : data2['id']);
                  },
                  child: InkWell(
                    onTap: () async{
                      //did this to retrieve logged in user information
                      DocumentSnapshot snapshot = await FirebaseFirestore.instance
                      .collection('users')
                      .doc(chatServiceController.auth.currentUser!.uid)
                      .get();
                      String userName = snapshot.get('name');
                      String userId = snapshot.get('id');
                      ////////////////////////

                      Get.to(() => DMScreen(
                        isOnline: true, 
                        receiverName: chatServiceController.isSearchingRecentChats ? data['name'] : data2['name'],
                        receiverProfilePic: chatServiceController.isSearchingRecentChats ? data['photo'] : data2['photo'],
                        receiverID: chatServiceController.isSearchingRecentChats ? data['id'] : data2['id'], 
                        senderName: userName,
                        senderId: userId,
                      ));
                        
                      //chatServiceontroller.updateisSeenStatus(isSeen: true, receiverId: data['id'],);
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
                            //profilePic  ===>> chatServiceontroller.isSearchingRecentChats ? data['photo'] : data2['photo'],
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
                                        chatServiceController.isSearchingRecentChats ? data['name'] : data2['name'],
                                        style: GoogleFonts.poppins(
                                          color: AppTheme().blackColor,
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w500
                                        ),
                                      ),
                                      Text(
                                        chatServiceController.isSearchingRecentChats ? formatTime(timestamp: data['timestamp']) : formatTime(timestamp: data2['timestamp']),
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
                                        chatServiceController.isSearchingRecentChats ? data['lastMessage'] : data2['lastMessage'],
                                        style: GoogleFonts.poppins(
                                          color: AppTheme().darkGreyColor,
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w500,
                                          textStyle: const TextStyle(
                                            overflow: TextOverflow.ellipsis
                                          )
                                        ),
                                      ),
                                       
                                      chatServiceController.isSearchingRecentChats 
                                      ? data['id'] != chatServiceController.auth.currentUser!.uid
                                      ? CircleAvatar(
                                         backgroundColor: AppTheme().mainColor,
                                         radius: 7.r,
                                      )
                                      //find a way to show this status bar when your chat partner sends you a message
                                      :const SizedBox()
                                      
                                      : data2['id'] != chatServiceController.auth.currentUser!.uid
                                      ? CircleAvatar(
                                         backgroundColor: AppTheme().mainColor,
                                         radius: 7.r,
                                      )
                                      //find a way to show this status bar when your chat partner sends you a message
                                      :const SizedBox()
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
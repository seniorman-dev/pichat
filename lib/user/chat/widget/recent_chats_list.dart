import 'package:cached_network_image/cached_network_image.dart';
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

import 'search_textfield.dart';










// ignore: must_be_immutable
class RecentChats extends StatefulWidget {
  const RecentChats({super.key,});


  @override
  State<RecentChats> createState() => _RecentChatsState();
}

class _RecentChatsState extends State<RecentChats> with WidgetsBindingObserver {

  //get the instance of firebaseauth and cloud firestore for the purpose below
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;


  @override
  void initState() {
    var chatServiceController = Provider.of<ChatServiceController>(context, listen: false);
    //initialized the stream
    chatServiceController.recentChatsStream = chatServiceController.firestore.collection('users').doc(chatServiceController.auth.currentUser!.uid).collection('recent_chats').orderBy('timestamp').snapshots();
    super.initState();
  }



  @override
  Widget build(BuildContext context) {

    //dependency injection
    var chatServiceController = Provider.of<ChatServiceController>(context);

    return Column(
      children: [

        //search for users
        /*SearchTextField(
          textController: chatServiceController.recentChatsTextController, 
          hintText: 'Search for recent messages',
          onChanged: (searchText) {
            // Update recentMessagesStream when search text changes
            setState(() {
              userStream = chatServiceController.firestore
              .collection('users')
              .doc(chatServiceController.auth.currentUser!.uid)
              .collection('recent_chats')
              //.orderBy('timestamp')
              .where(
                "name",
                isGreaterThanOrEqualTo: searchText,
                isLessThan: '${searchText}z')
                .snapshots();
              });
            },
          ),

          SizedBox(height: 10.h,),*/

          //the stream of the recent messages gan gan
          StreamBuilder(
          stream: chatServiceController.recentChatsStream ,
          builder: (context, snapshot) {

            //filtered list
            //var filteredList = snapshot.data!.docs.where((element) => element['name'].toString().contains(chatServiceController.recentChatsTextController.text)).toList();

            if (snapshot.connectionState == ConnectionState.waiting) {
              // Show a loading indicator while waiting for data
              return const Loader();
            } 
            if (snapshot.hasError) {
              // Handle error if any
              return const ErrorLoader();
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) { //!snapshot.hasData || snapshot.data!.docs.isEmpty
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
                          CupertinoIcons.text_bubble,
                          color: AppTheme().mainColor,
                          size: 40.r,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        "No recent messages found",
                        style: GoogleFonts.poppins(
                          color: AppTheme().greyColor,
                          fontSize: 14.sp,
                          //fontWeight: FontWeight.w500
                        ),
                      ),

                    ],
                  ),
                ),
              );
            }
            
            return SizedBox(
                height: 250.h,
                child: ListView.builder(
                  physics: NeverScrollableScrollPhysics(),  //const BouncingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  //separatorBuilder: (context, index) => SizedBox(height: 0.h,), 
                  itemCount: snapshot.data!.docs.length,  //filteredList.length,
                  itemBuilder: (context, index) {

                    var data2 = snapshot.data!.docs[index];  //normal list

                    //var data = filteredList[index];  //filtered list
              
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
                        chatServiceController.deleteUserFromRecentChats(friendId: data2['id']);
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
                          //did this to retrieve logged in user information
                          DocumentSnapshot snapshotForUser = await FirebaseFirestore.instance
                          .collection('users')
                          .doc(data2['id'],)
                          .get();
                          bool isChatBuddyOnline = snapshotForUser.get('isOnline');
                          ///////////////////////

                          Get.to(() => DMScreen(
                            isOnline: isChatBuddyOnline, 
                            receiverName: data2['name'],
                            receiverProfilePic: data2['photo'],
                            receiverID: data2['id'], 
                            senderName: userName,
                            senderId: userId, 
                            //lastActive: chatServiceController.isSearchingRecentChats ? "${formatTime(timestamp: data['lastActive'])} on ${formatDate(timestamp: data['lastActive'])}" : "${formatTime(timestamp: data2['lastActive'])} on ${formatDate(timestamp: data2['lastActive'])}",
                          ));
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
                                    backgroundColor: data2['photo'] == null ? AppTheme().darkGreyColor : AppTheme().blackColor,
                                    //backgroundColor: AppTheme().darkGreyColor,
                                    child: data2['photo'] == null 
                                    ?null
                                    :ClipRRect(
                                      borderRadius: BorderRadius.all(Radius.circular(10.r)), //.circular(20.r),
                                      clipBehavior: Clip.antiAlias, //.antiAliasWithSaveLayer,
                                      child: CachedNetworkImage(
                                        imageUrl: data2['photo'],
                                        width: 40.w,
                                        height: 40.h,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => Loader(),
                                        errorWidget: (context, url, error) => Icon(
                                          Icons.error,
                                          color: AppTheme().lightestOpacityBlue,
                                        ),
                                      ),
                                    ),
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
                                            data2['name'],
                                            style: GoogleFonts.poppins(
                                              color: AppTheme().blackColor,
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w500
                                            ),
                                          ),
                                          Text(
                                            formatTime(timestamp: data2['timestamp']),
                                            style: GoogleFonts.poppins(
                                              color: AppTheme().greyColor,
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
                                            data2['lastMessage'],
                                            style: GoogleFonts.poppins(
                                              color: AppTheme().greyColor,
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w500,
                                              textStyle: const TextStyle(
                                                overflow: TextOverflow.ellipsis
                                              )
                                            ),
                                          ),
                                          
                                          data2['sentBy'] == chatServiceController.auth.currentUser!.uid
                                          ? SizedBox()
                                          //find a way to show this status bar when your chat partner sends you a message
                                          :CircleAvatar(
                                            backgroundColor: AppTheme().mainColor,
                                            radius: 7.r,
                                          )
                                        ],
                                      ),
                                      /*SizedBox(height: 3.h,),
                                      Text(
                                        chatServiceController.isSearchingRecentChats ? "${formatDate(timestamp: data['timestamp'])}" : "${formatDate(timestamp: data2['timestamp'])}",
                                        style: GoogleFonts.poppins(
                                          color: AppTheme().blackColor,
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.w500
                                        ),
                                      )*/
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
        ),
      ],
    );
  }
}
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Ezio/theme/app_theme.dart';
import 'package:Ezio/user/group_chat/controller/group_chat_controller.dart';
import 'package:Ezio/user/group_chat/screen/group_messages_screen.dart';
import 'package:Ezio/user/group_chat/widget/create_group.dart';
import 'package:Ezio/user/group_chat/widget/search_textfield.dart';
import 'package:Ezio/utils/error_loader.dart';
import 'package:Ezio/utils/firestore_timestamp_formatter.dart';
import 'package:Ezio/utils/loader.dart';
import 'package:provider/provider.dart';









class GroupChatMessages extends StatefulWidget {
  const GroupChatMessages({super.key});

  @override
  State<GroupChatMessages> createState() => _GroupChatMessagesState();
}

class _GroupChatMessagesState extends State<GroupChatMessages> {
  bool showDateHeader = true;

  @override
  Widget build(BuildContext context) {
    //dependency injection
    var groupChatController = Provider.of<GroupChatController>(context);


    return Scaffold(
      backgroundColor: AppTheme().whiteColor,
      appBar: AppBar(
        backgroundColor: AppTheme().whiteColor,
        centerTitle: true,
        elevation: 0,
        title: const Text(
          'Groups'
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
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h,),

            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 25.w,
                vertical: 20.h
              ),
              child: Row(
                //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //search group text form field
                  Expanded(
                    child: SearchTextFieldForGroup(
                      textController: groupChatController.groupSearchTextController, 
                      hintText: 'Search for groups',
                      onChanged: (searchText) {
                        // Update userStream when search text changes
                        setState(() {
                          groupChatController.filteredUserGroups = FirebaseFirestore.instance
                          .collection('groups')
                          .where('groupMembers', arrayContains: groupChatController.auth.currentUser!.uid)
                          .where(
                            "groupName", isEqualTo: searchText
                          )
                          .snapshots();
                        });
                      },
                    ),
                  ),

                  SizedBox(width: 15.w,),
            
                  InkWell(
                    onTap: () {
                      Get.to(() => const CreateGroupScreen());
                    },
                    child: Container(
                      height: 65.h,
                      //width: 200.w,
                      padding: EdgeInsets.symmetric(
                        vertical: 15.h, //30.h
                        horizontal: 15.w  //20.h
                      ),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                       color: AppTheme().lightGreyColor,
                        borderRadius: BorderRadius.circular(20.r),
                        /*boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 0.1.r,
                            blurRadius: 8.0.r,
                          )
                        ],*/
                      ),
                      child: Icon(
                        CupertinoIcons.plus,
                        color: AppTheme().blackColor,
                        size: 35.r,
                      )
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h,),

            //stream builder
            StreamBuilder(
              stream: groupChatController.userGroupListStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Show a loading indicator while waiting for data
                  return const Loader();
                } 
                if (snapshot.hasError) {
                  // Handle error if any
                  return const ErrorLoader();
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 25.w,
                      vertical: 20.h,
                    ),
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        //mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 120.h,), //210.h
                          CircleAvatar(
                            radius: 100.r,
                            backgroundColor: AppTheme().lightestOpacityBlue,
                            child: Icon(
                              CupertinoIcons.chat_bubble_text,
                              color: AppTheme().mainColor,
                              size: 70.r,
                            ),
                          ),
                          SizedBox(height: 50.h),
                          Text(
                            "No groups available",
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
                //when snapshot exits
                /////////////beginning
                return SizedBox(
                  height: 250.h,
                  child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),//const BouncingScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    //separatorBuilder: (context, index) => SizedBox(height: 0.h,), 
                    itemCount: snapshot.data!.docs.length, 
                    itemBuilder: (context, index) {
                      var data = snapshot.data!.docs[index]; 
                      // Check if the current message's date is different from the previous message's date
                      if (index > 0) {
                        var previousData = snapshot.data!.docs[index - 1];
                        var currentDate = formatDate(timestamp: data['timestamp']);
                        var previousDate = formatDate(timestamp: previousData['timestamp']);
                        showDateHeader = currentDate != previousDate;
                      }
              
                      return Column(
                        children: [
                          //Show the date header if needed
                          if (showDateHeader)
                            Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: 30.h, 
                                  horizontal: 150.w
                                ),
                                child: Container(
                                  alignment: Alignment.center,
                                  height: 30.h,
                                  //width: 150.w,
                                  padding: EdgeInsets.symmetric(
                                    //vertical: 0.h, //20.h
                                    horizontal: 5.w  //15.h
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme().lightGreyColor,
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: Text(
                                    formatDate(timestamp: data['timestamp']),
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey,
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          //////
                          Dismissible(
                            key: UniqueKey(),
                            direction: DismissDirection.endToStart,
                            background: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(
                                  CupertinoIcons.delete_simple,
                                  color: AppTheme().redColor                     
                                ),
                                SizedBox(width: 10.w,),
                              ]
                            ),
                            onDismissed: (direction) {
                              //swipe to delete group
                              groupChatController
                              .deleteGroup(groupId: data['groupId']);
                            },
                            child: InkWell(
                              onTap: () async{
                                //get to group chat screen
                                Get.to(() =>
                                 GroupMessagingScreen(  
                                  groupId: data['groupId'],  
                                  groupName: data['groupName'], 
                                  groupPhoto: data['groupPhoto'], 
                                  groupBio: data['groupBio']
                                 )
                                );
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 25.w,
                                  vertical: 20.h
                                ),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 20.h, //30.h
                                    horizontal: 15.w  //20.h
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme().whiteColor,
                                    borderRadius: BorderRadius.circular(30.r),
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
                                          backgroundColor: data['groupPhoto'] == null ? AppTheme().darkGreyColor : AppTheme().blackColor,
                                          //backgroundColor: AppTheme().darkGreyColor,
                                          child: data['groupPhoto'] == null 
                                          ?null
                                          :ClipRRect(
                                            borderRadius: BorderRadius.all(Radius.circular(10.r)), //.circular(20.r),
                                            clipBehavior: Clip.antiAlias, //.antiAliasWithSaveLayer,
                                            child: CachedNetworkImage(
                                              imageUrl: data['groupPhoto'],
                                              width: 42.w,
                                              height: 42.h,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) => const Loader(),
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
                                                  data['groupName'],
                                                  style: GoogleFonts.poppins(
                                                    color: AppTheme().blackColor,
                                                    fontSize: 14.sp,
                                                    fontWeight: FontWeight.w500,
                                                    textStyle: const TextStyle(
                                                      overflow: TextOverflow.ellipsis
                                                    )
                                                  ),
                                                ),
                                                Text(
                                                  formatTime(timestamp: data['timestamp']),
                                                  style: GoogleFonts.poppins(
                                                    color: AppTheme().greyColor,
                                                    fontSize: 12.sp,
                                                    fontWeight: FontWeight.w500
                                                  ),
                                                )
                                              ],
                                            ),
      
                                            SizedBox(height: 4.h,),

                                            Text(
                                              data['lastMessage'],
                                              style: GoogleFonts.poppins(
                                                color: AppTheme().greyColor,
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.w500,
                                                textStyle: const TextStyle(
                                                  overflow: TextOverflow.ellipsis
                                                )
                                              ),
                                            ),
                                            
                                          ]
                                        ),
                                      ),
                                      SizedBox(width: 8.w,),
                                      data['sentBy'] == groupChatController.auth.currentUser!.uid
                                      ? const SizedBox()
                                      //find a way to show this status bar when your chat partner sends you a message
                                      :CircleAvatar(
                                        backgroundColor: AppTheme().mainColor,
                                          radius: 7.r,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  ),
                );
                /////////////end
              }
            )
          ],
        ),
      ),
    );
  }
}
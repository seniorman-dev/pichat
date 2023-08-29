import 'package:Ezio/auth/controller/auth_controller.dart';
import 'package:Ezio/theme/app_theme.dart';
import 'package:Ezio/user/chat/controller/chat_service_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Ezio/user/group_chat/controller/group_chat_controller.dart';
import 'package:Ezio/utils/error_loader.dart';
import 'package:Ezio/utils/extract_firstname.dart';
import 'package:Ezio/utils/loader.dart';
import 'package:provider/provider.dart';








class AddUserToGroup extends StatefulWidget {
  const AddUserToGroup({super.key, required this.groupId, required this.groupPhoto, required this.groupName});
  final String groupId;
  final String groupPhoto;
  final String groupName;

  @override
  State<AddUserToGroup> createState() => _AddUserToGroupState();
}

class _AddUserToGroupState extends State<AddUserToGroup> {
  @override
  Widget build(BuildContext context) {
    
    var authController = Provider.of<AuthController>(context);
    var chatServiceController = Provider.of<ChatServiceController>(context);
    var groupChatController = Provider.of<GroupChatController>(context);

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppTheme().whiteColor,
        appBar: AppBar(
          backgroundColor: AppTheme().whiteColor,
          centerTitle: true,
          elevation: 0,
          leading: IconButton(
            onPressed: () {
              Get.back();
            }, 
            icon: Icon(
              CupertinoIcons.back,
              color: AppTheme().blackColor,
              size: 30.r,
            )
          ),
          title: const Text(
            'Add Friend'
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
        //wrap with column if needed
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h,),
            Center(
              child: Text(
                'Choose connects you want to \n       add to "${widget.groupName}"',
                style: GoogleFonts.poppins(
                  color: AppTheme().greyColor,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.normal //.w500
                ),
              ),
            ),
            SizedBox(height: 20.h,),
            StreamBuilder(
              stream: authController.firestore.collection('users').doc(authController.userID).collection('friends').snapshots(),
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
                          SizedBox(height: 210.h,),
                          CircleAvatar(
                            radius: 100.r,
                            backgroundColor: AppTheme().lightestOpacityBlue,
                            child: Icon(
                              CupertinoIcons.person_badge_minus,
                              color: AppTheme().mainColor,
                              size: 70.r,
                            ),
                          ),
                          SizedBox(height: 50.h),
                          Text(
                            "Add connections to your list",
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
                //
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  separatorBuilder: (context, index) => SizedBox(height: 10.h),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var data = snapshot.data!.docs[index];
                    //
                    bool isSelected = groupChatController.selectedIndicesForFriends.contains(data['id']);
                    //to keep track if a post is liked or saved by user or not
                    List<dynamic> memebersList = data['groups'];

                    return Padding(
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
                                backgroundColor: data['photo'] == null ? AppTheme().darkGreyColor : AppTheme().blackColor,
                                //backgroundColor: AppTheme().darkGreyColor,
                                child: data['photo'] == null 
                                ?null
                                :ClipRRect(
                                  borderRadius: BorderRadius.all(Radius.circular(30.r)), //.circular(20.r),
                                  clipBehavior: Clip.antiAlias, //.antiAliasWithSaveLayer,
                                  child: CachedNetworkImage(
                                    imageUrl: data['photo'],
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
                                  Text(
                                    getFirstName(fullName: data['name']),
                                    style: GoogleFonts.poppins(
                                      color: AppTheme().blackColor,
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w500
                                    ),
                                  ),
                                  SizedBox(height: 4.h,),
                                  Text(
                                    data['email'],
                                    style: GoogleFonts.poppins(
                                      color: AppTheme().greyColor,
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.normal,
                                      textStyle: const TextStyle(
                                        overflow: TextOverflow.ellipsis
                                      )
                                    ),
                                  ),                                      
                                ]
                              ),
                            ),
                            //add friend icon here
                            IconButton(
                              onPressed: () {

                                setState(() {

                                  if (isSelected || memebersList.contains(widget.groupId)) {
                                    groupChatController.selectedIndicesForFriends.remove(data['id']);
                                    groupChatController.removeFriendFromGroupChat(groupId: widget.groupId, friendId: data['id'])
                                    .then((value) => debugPrint('${data['name']} has been removed from ${widget.groupName}'));                          
                                    setState(() {
                                      groupChatController.isAdded = false;
                                    });
                                  } 
                                  else {
                                    groupChatController.selectedIndicesForFriends.add(data['id']);
                                    groupChatController.addFriendToGroupChat(
                                      groupId: widget.groupId, 
                                      groupName: widget.groupName, 
                                      groupPhoto: widget.groupPhoto, 
                                      friendId: data['id'], 
                                      friendName: data['name'], 
                                      friendPhoto: data['photo']
                                    )
                                    .then((value) => debugPrint('${data['name']} has been added to ${widget.groupName}'));                          
                                    setState(() {
                                      groupChatController.isAdded = true;
                                    });
                                  }
                                });

                              }, 
                              icon: Icon(
                                isSelected || memebersList.contains(widget.groupId) ?
                                CupertinoIcons.check_mark_circled_solid
                                :CupertinoIcons.add_circled
                              ),
                              color: isSelected || memebersList.contains(widget.groupId) ?
                              AppTheme().mainColor
                              :AppTheme().greyColor,
                              iconSize: 30.r,
                            )
                            
                            //SizedBox(width: 5.w,),

                          ],
                        ),
                      ),
                    );
                  }
                );
              }
            ),
          ],
        )
      ),
    );
  }
}
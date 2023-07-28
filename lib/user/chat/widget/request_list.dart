import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pichat/api/api.dart';
import 'package:pichat/auth/controller/auth_controller.dart';
import 'package:pichat/theme/app_theme.dart';
import 'package:pichat/user/chat/controller/chat_service_controller.dart';
import 'package:pichat/user/chat/screen/dm_screen.dart';
import 'package:pichat/user/chat/widget/all_users_list.dart';
import 'package:pichat/utils/error_loader.dart';
import 'package:pichat/utils/loader.dart';
import 'package:provider/provider.dart';









class FriendsRequestList extends StatefulWidget {
  const FriendsRequestList({super.key});

  @override
  State<FriendsRequestList> createState() => _FriendsRequestListState();
}

class _FriendsRequestListState extends State<FriendsRequestList> {
  @override
  Widget build(BuildContext context) {
    var controller = Provider.of<AuthController>(context);
    var chatController = Provider.of<ChatServiceController>(context);
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
          title: Text(
            'Connect Request'
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
          stream: controller.firestore.collection('users').doc(controller.userID).collection('friend_request').snapshots(),
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    //mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 210.h,),
                      CircleAvatar(
                        radius: 100.r,
                        backgroundColor: AppTheme().lightestOpacityBlue,
                        child: Icon(
                          CupertinoIcons.person_crop_circle_badge_exclam,
                          color: AppTheme().mainColor,
                          size: 70.r,
                        ),
                      ),
                      SizedBox(height: 50.h),
                      Text(
                        "You don't have any connect request yet",
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
                //height: 170.h, //200.h
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: BouncingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 20.h),
                  separatorBuilder: (context, index) => SizedBox(width: 20.w),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var data = snapshot.data!.docs[index];
                    var isSelected = chatController.selectedDocumentIdForConnectRequest.contains(data['id']);        
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 5.w,
                        vertical: 20.h
                      ),
                      child: Column(
                        children: [
                        SizedBox(height: 10.h,),
                        Container(
                          //height: 110.h,
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
                                    SizedBox(height: 7.h,),
                                    Text(
                                      data['name'],  //data['name'] or //data['id']
                                      style: GoogleFonts.poppins(
                                        color: AppTheme().blackColor,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500
                                      ),
                                    ),
                                    SizedBox(height: 4.h,),
                                    Text(
                                      data['email'] , //data['isOnline'] ? 'online' : 'offline',  //data['email'],     
                                      style: GoogleFonts.poppins(
                                        color: AppTheme().darkGreyColor, //specify color when user is online or offline
                                        fontSize: 14.sp, //14.sp
                                        fontWeight: FontWeight.w500,
                                        textStyle: const TextStyle(
                                          overflow: TextOverflow.ellipsis
                                        )
                                      ),
                                    ),
                                    //Row (button to send friend request)
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        //button to decline friend request
                                        SizedBox(
                                          height: 30.h,
                                          //width: 85.w,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              //chatController.declineFriendRequest(friendId: data['id']);
                                              setState(() {
                                                //isSelected = !isSelected;
                                                if (isSelected) {
                                                  chatController.selectedDocumentIdForAllUsers.remove(data['id']);
                                                  chatController.declineFriendRequest(friendId: data['id']);
                                                } 
                                                else {
                                                  chatController.selectedDocumentIdForAllUsers.add(data['id']);
                                                  chatController.acceptFriendRequest(friendName: data['name'], friendId: data['id'], friendProfilePic: data['photo']);  //data['photo']
                                                }
                                              });
                                            },
                                            style: ElevatedButton.styleFrom(
                                              elevation: 2,
                                              backgroundColor: AppTheme().mainColor,
                                              minimumSize: Size.copy(Size(100.w, 50.h)),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),                                          
                                            ),        
                                            /*icon: Icon(
                                              chatServiceController.isAdded ? CupertinoIcons.clear_thick_circled: CupertinoIcons.person_crop_circle_fill_badge_plus,
                                              color: AppTheme().whiteColor,
                                              size: 18.r,
                                            ),*/
                                            child: Text(
                                              isSelected ? 'decline' : 'accept',
                                              style: GoogleFonts.poppins(
                                                textStyle: TextStyle(
                                                  color: AppTheme().whiteColor,
                                                  fontSize: 10.sp,
                                                  fontWeight: FontWeight.w500
                                                )
                                              ),
                                            )
                                          ),
                                        ),
                                        /*SizedBox(width: 10.w,),
                                        //button to accept friend request
                                        SizedBox(
                                          height: 35.h,
                                          //width: 85.w,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              chatController.acceptFriendRequest(friendName: data['name'], friendId: data['id'], friendProfilePic: 'photURL');  //daa['photo']
                                            },
                                            style: ElevatedButton.styleFrom(
                                              elevation: 2,
                                              backgroundColor: AppTheme().mainColor,
                                              minimumSize: Size.copy(Size(100.w, 50.h)),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),                                          
                                            ),        
                                            /*icon: Icon(
                                              chatServiceController.isAdded ? CupertinoIcons.clear_thick_circled: CupertinoIcons.person_crop_circle_fill_badge_plus,
                                              color: AppTheme().whiteColor,
                                              size: 18.r,
                                            ),*/
                                            child: Text(
                                              'accept',
                                              style: GoogleFonts.poppins(
                                                textStyle: TextStyle(
                                                  color: AppTheme().whiteColor,
                                                  fontSize: 10.sp,
                                                  fontWeight: FontWeight.w500
                                                )
                                              ),
                                            )
                                          ),
                                        ),*/
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
                )
              );
            }     
          }
        ),
      ),
    );
  }
}
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pichat/auth/controller/auth_controller.dart';
import 'package:pichat/theme/app_theme.dart';
import 'package:pichat/user/chat/controller/chat_service_controller.dart';
import 'package:pichat/user/chat/widget/all_users_list.dart';
import 'package:pichat/user/chat/widget/friends_list.dart';
import 'package:pichat/user/chat/widget/recent_chats_list.dart';
import 'package:pichat/user/chat/widget/request_list.dart';
import 'package:pichat/user/chat/widget/search_textfield.dart';
import 'package:pichat/user/notifications/screen/notifications_sceen.dart';
import 'package:pichat/utils/extract_firstname.dart';
import 'package:provider/provider.dart';






class ChatScreen extends StatefulWidget {
  ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController textController = TextEditingController();
  bool isLoading = false;


  @override
  Widget build(BuildContext context) {
    
    //Dependency injection by provider
    var controller = Provider.of<AuthController>(context);
    var chatServiceontroller = Provider.of<ChatServiceController>(context);

    //function called when a recent chat message is being searched for
    void onSearch() async{
      setState(() {
        isLoading = true;
        chatServiceontroller.isSearchingRecentChats = true;
      });
      await chatServiceontroller.firestore.collection('users').doc(chatServiceontroller.auth.currentUser!.uid).collection('recent_chats').where("name", isEqualTo: textController.text).get().then((value) => setState(() => isLoading = false));
    }



    return SafeArea(
      child: Scaffold(
        backgroundColor: AppTheme().whiteColor,
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 20.w, //25.W
                  vertical: 20.h
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 30.h,),   
                    //to get logged in user's name
                    StreamBuilder(
                      stream: controller.firestore.collection('users').doc(controller.userID).snapshots(),
                      builder: (context, snapshot) {
                        //var data = snapshot.data!.data();  //how to call document snapshots
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          // Show a loading indicator while waiting for data
                          return Text(
                            '...',
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                color: AppTheme().darkGreyColor,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500
                              )
                            ),
                          );
                        } 
                        else if (snapshot.hasError) {
                          // Handle error if any
                          return Text(
                            'Error: ${snapshot.error}',
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                color: AppTheme().darkGreyColor,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500
                              )
                            ),
                          );
                        } 
                        else if (snapshot.hasData) {
                          // Check if the snapshot has data before accessing it
                          var data = snapshot.data!.data(); 
                          if (data != null) {
                            // Access the data safely
                            var firstName = getFirstName(fullName: data['name']);  
                            return Text(
                              'Hello $firstName,',
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                  color: AppTheme().darkGreyColor,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500
                                )
                              ),
                            );
                          } 
                          else {
                            return Text(
                              'Data not found',
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                  color: AppTheme().darkGreyColor,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500
                                )
                              ),
                            );
                          }
                        } 
                        else {
                          return SizedBox();
                        }
                      }
                    ),
        
                    //SizedBox(height: 5.h,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              CupertinoIcons.placemark_fill,
                              color: AppTheme().blackColor,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              'Shomolu Lagos, Nigeria.',
                              style: GoogleFonts.poppins(
                                color: AppTheme().blackColor,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500
                              ),
                            )
                          ],
                        ),
                        IconButton(
                          icon: Icon(
                            CupertinoIcons.bell,
                            color: AppTheme().blackColor,
                            size: 30.r,
                          ),
                          onPressed: () {
                            Get.to(() => NotificationScreen());
                          },          
                        ),
                      ],
                    )
                  ],
                ),
              ),
              SizedBox(height: 5.h,),
              //find connects button
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    //find connects button
                    SizedBox(
                      height: 40.h,
                      //width: 120.w,
                      child: ElevatedButton( 
                        onPressed: () {
                          Get.to(() => AllUsersList());
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: AppTheme().lightestOpacityBlue,
                          minimumSize: Size.copy(Size(100.w, 50.h)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.r),
                          )
                        ), 
                        child: Text(
                          'find connects',
                          style: TextStyle(
                            color: AppTheme().mainColor,  //.blackColor,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500
                          ),
                        ),
                      ),     
                    ),
                    //connect requests button
                    SizedBox(
                      height: 40.h,
                      //width: 190.w,
                      child: ElevatedButton( 
                        onPressed: () {
                          Get.to(() => FriendsRequestList());
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: AppTheme().lightestOpacityBlue,
                          minimumSize: Size.copy(Size(100.w, 50.h)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.r),
                          )
                        ), 
                        child: Text(
                          'connect requests',
                          style: TextStyle(
                            color: AppTheme().mainColor,  //.blackColor,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500
                          ),
                        ),
                      ),     
                    ),
                  ],
                ),
              ),           
              SizedBox(height: 30.h,),

              //list of friends
              FriendsList(),

              SizedBox(height: 20.h,),
              Divider(color: AppTheme().darkGreyColor, thickness: 1,),
              SizedBox(height: 20.h,), //30.h

              //search for recent chats
              SearchTextField(
                textController: textController,
                onChanged: (value) => onSearch(), 
                hintText: 'Search recent messages...',
              ),

              SizedBox(height: 20.h,), //30.h

              //recent chats stream
              RecentChats(
                isSearching: chatServiceontroller.isSearchingRecentChats,
                textController: textController,
              ),

              SizedBox(height: 10.h,),
            ]
          ),
        )      
      ),
    );
  }
}
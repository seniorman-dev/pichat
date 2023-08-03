import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pichat/theme/app_theme.dart';
import 'package:pichat/user/chat/widget/bottom_engine.dart';
import 'package:pichat/user/chat/widget/chat_list.dart';






class DMScreen extends StatelessWidget {
  DMScreen({super.key, required this.receiverProfilePic, required this.receiverName, required this.receiverID, required this.isOnline, required this.senderName, required this.senderId});
  final String receiverProfilePic;
  final String receiverName;
  final String receiverID;
  final String senderName;
  final String senderId;
  final bool isOnline;

  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: AppTheme().whiteColor,//.lightGreyColor,
        appBar: AppBar(
          toolbarHeight: 110.h,
          backgroundColor: AppTheme().whiteColor,
          centerTitle: false,
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
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              //profilePic
              CircleAvatar(
                radius: 30.r,
                backgroundColor: AppTheme().opacityBlue,
                child: CircleAvatar(
                  radius: 28.r, 
                  backgroundColor: AppTheme().darkGreyColor,  //receiverProfilePic
                ),
              ),
              SizedBox(width: 10.w,),
              //details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  //mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      receiverName,
                      style: GoogleFonts.poppins(
                        color: AppTheme().blackColor,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500
                      ),
                    ),
                    SizedBox(height: 2.h,),
                    Text(
                      isOnline ? 'online' : 'offline',
                      style: GoogleFonts.poppins(
                        color: isOnline? AppTheme().greenColor : AppTheme().darkGreyColor,
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
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(
                CupertinoIcons.videocam,
                color: AppTheme().blackColor,
                size: 32.r,
              ),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(
                CupertinoIcons.phone_down,
                color: AppTheme().blackColor,
                size: 32.r,
              ),
              onPressed: () {},
            )  
          ],
        ),
        body: Column(
          children: [         
            //list of messages        
            ChatList(
              senderName: senderName, 
              senderId: senderId,
              receiverName: receiverName, 
              receiverId: receiverID,
            ),

            Expanded(
              child: BottomEngine(
                receiverName: receiverName, 
                receiverId: receiverID, 
                receiverPhoto: receiverProfilePic,
              ),
            ),

            SizedBox(
              height: MediaQuery.of(context).viewInsets.bottom,
            )
          ],
        )    
      ),   
    );
  }
}

//Future<bool> onBackPress() {
    //Navigator.pop(context);
    //return Future.value(false);
 //}
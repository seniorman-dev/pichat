import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pichat/theme/app_theme.dart';
import 'package:pichat/user/chat/widget/bottom_engine.dart';
import 'package:pichat/user/chat/widget/chat_list.dart';






class DMScreen extends StatefulWidget {
  const DMScreen({super.key, required this.receiverProfilePic, required this.receiverName, required this.receiverID, required this.isOnline, required this.senderName, required this.senderId});
  final String receiverProfilePic;
  final String receiverName;
  final String receiverID;
  final String senderName;
  final String senderId;
  final bool isOnline;

  @override
  State<DMScreen> createState() => _DMScreenState();
}

class _DMScreenState extends State<DMScreen> with WidgetsBindingObserver{
  
  double keyboardHeight = 0;
  double keyboardTop = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    final topInset = WidgetsBinding.instance.window.viewInsets.top;
    setState(() {
      keyboardHeight = bottomInset;
      keyboardTop = topInset; 
    });
  }

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Scaffold(
        //resizeToAvoidBottomInset: true,
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
          title: Row( //title
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
                      widget.receiverName,
                      style: GoogleFonts.poppins(
                        color: AppTheme().blackColor,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500
                      ),
                    ),
                    SizedBox(height: 2.h,),
                    Text(
                      widget.isOnline ? 'online' : 'offline',
                      style: GoogleFonts.poppins(
                        color: widget.isOnline? AppTheme().greenColor : AppTheme().darkGreyColor,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ChatList(
              senderName: widget.senderName, 
              senderId: widget.senderId,
              receiverName: widget.receiverName, 
              receiverId: widget.receiverID,
            ),
            Padding(
              padding: EdgeInsets.only(
                top: keyboardTop,
                //bottom: keyboardHeight - MediaQuery.of(context).padding.bottom,
                bottom: keyboardHeight > MediaQuery.of(context).padding.bottom + 10
                ? keyboardHeight - MediaQuery.of(context).padding.bottom - 250
                : 0,
              ),
              child: BottomEngine(
                receiverName: widget.receiverName, 
                receiverId: widget.receiverID, 
                receiverPhoto: widget.receiverProfilePic
              ),
            ),
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
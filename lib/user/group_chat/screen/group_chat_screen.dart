import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pichat/theme/app_theme.dart';








class GroupChatMessages extends StatefulWidget {
  const GroupChatMessages({super.key});

  @override
  State<GroupChatMessages> createState() => _GroupChatMessagesState();
}

class _GroupChatMessagesState extends State<GroupChatMessages> {
  @override
  Widget build(BuildContext context) {
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
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 25.w,
          vertical: 20.h,
        ),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            //mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 135.h,), //210.h
              CircleAvatar(
                radius: 100.r,
                backgroundColor: AppTheme().lightestOpacityBlue,
                child: Icon(
                  CupertinoIcons.text_bubble,
                  color: AppTheme().mainColor,
                  size: 70.r,
                ),
              ),
              SizedBox(height: 50.h),
              Text(
                "Chat collectively with your friends \n                (coming soon 🔥)",
                style: GoogleFonts.poppins(
                  color: AppTheme().greyColor,
                  fontSize: 14.sp,
                  //fontWeight: FontWeight.w500
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
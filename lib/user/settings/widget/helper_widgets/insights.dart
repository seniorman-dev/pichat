import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pichat/theme/app_theme.dart';
import 'package:pichat/utils/elevated_button.dart';








class InsightScreen extends StatelessWidget {
  const InsightScreen ({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        //appBar: const CustomAppBar(title: 'Withdrawal',),
        backgroundColor: AppTheme().whiteColor,
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: buildBody(context),
        )
      ),
    );
  }

  //buildBody
  Widget buildBody(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 25.w,
        vertical: 20.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 100.h,), //120.h
          CircleAvatar(
            radius: 150.r,
            backgroundColor: AppTheme().lightestOpacityBlue,  //.opacityBlue,
            child: Icon(
              CupertinoIcons.graph_circle,
              size: 140.r,
              color: AppTheme().mainColor,
            )                   
          ),
          /*SvgPicture.asset(
            'assets/svg/green_check.svg',
          ),*/
          SizedBox(height: 40.h,),
          Text(
            'View your account analytics on the go',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: AppTheme().blackColor,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500
            ),
          ),
          SizedBox(height: 20.h,),
          Text(
            "Explore detailed statistics of \nyour account as it thrives\n(Coming Soon)",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: AppTheme().greyColor,
              fontSize: 14.sp,
              fontWeight: FontWeight.normal
            ),
          ),
          SizedBox(height: 120.h,),
          CustomElevatedButton(
            text: 'Got It', 
            onPressed: () {
              Get.back();
            }
          ),
          SizedBox(height: 40.h,),
        ]
      )
    );
  }
}
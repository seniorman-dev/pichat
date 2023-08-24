import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Ezio/theme/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:Ezio/main_page/screen/main_page.dart';
import 'package:Ezio/utils/elevated_button.dart';










class WalletScreen extends StatelessWidget {
  const WalletScreen ({super.key});

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
              CupertinoIcons.money_dollar_circle,
              size: 140.r,
              color: AppTheme().mainColor,
            )                   
          ),
          /*SvgPicture.asset(
            'assets/svg/green_check.svg',
          ),*/
          SizedBox(height: 40.h,),
          Text(
            'Send cash 💸 to your connects seamlessly with just one tap',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: AppTheme().blackColor,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500
            ),
          ),
          SizedBox(height: 20.h,),
          Text(
            "perform e-wallet transactions with your connects through unique id's\n(coming soon)",
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
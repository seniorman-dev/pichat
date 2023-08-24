import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Ezio/main_page/screen/main_page.dart';
import 'package:Ezio/utils/elevated_button.dart';
import '../../../../../../../theme/app_theme.dart';








class ProfileUpdatedSuccessScreen extends StatelessWidget {
  const ProfileUpdatedSuccessScreen ({super.key});

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
          SizedBox(height: 55.h,),
          Center(
            child: Text(
              'Update Successful',
              style: GoogleFonts.poppins(
                color: AppTheme().blackColor,
                fontSize: 18.sp,
                fontWeight: FontWeight.w500
              ),
            ),
          ),
          SizedBox(height: 120.h,),
          CircleAvatar(
            radius: 150.r,
            backgroundColor: AppTheme().lightGreyColor, //.lightestOpacityBlue,
            child: Icon(
              CupertinoIcons.checkmark_seal_fill,
              size: 140.r,
              color: AppTheme().greenColor,
            )                   
          ),
          /*SvgPicture.asset(
            'assets/svg/green_check.svg',
          ),*/
          SizedBox(height: 40.h,),
          Text(
            'Congratulations!',
            style: GoogleFonts.poppins(
              color: AppTheme().mainColor,
              fontSize: 15.sp,
              fontWeight: FontWeight.w500
            ),
          ),
          SizedBox(height: 20.h,),
          Text(
            "Your profile was updated successfully",
            style: GoogleFonts.poppins(
              color: AppTheme().blackColor,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500
            ),
          ),
          SizedBox(height: 120.h,),
          CustomElevatedButton(
            text: 'Go To Home', 
            onPressed: () {
              Get.offAll(() => const MainPage());
            }
          )
        ]
      )
    );
  }
}
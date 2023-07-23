import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pichat/auth/screen/google_sign_in_screen.dart';
import 'package:pichat/theme/app_theme.dart';






class SplashePage1 extends StatelessWidget {
  const SplashePage1({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.chart_pie_fill,
              color: AppTheme().mainColor,
              size: 50.r, //40.r
            ),
            SizedBox(width: 10.w,),
            Text(
              'J U N O',
              style: GoogleFonts.comfortaa(
                textStyle: TextStyle(
                  color: AppTheme().blackColor,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold
                )
              ),
            )
          ],
        ),
      ), 
      nextScreen: GoogleSignInScreen(), 
      duration: 2000, //4000
      backgroundColor: AppTheme().whiteColor, //real image color
      centered: true,
      splashIconSize: 500.h,  //700,
      splashTransition: SplashTransition.fadeTransition,
      animationDuration: const Duration(seconds: 2),  //2
    );
  }
}
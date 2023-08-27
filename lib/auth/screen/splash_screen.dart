import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Ezio/auth/screen/onboarding_screen.dart';
import 'package:Ezio/theme/app_theme.dart';






class SplashePage1 extends StatelessWidget {
  const SplashePage1({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Center(
        child: Image.asset('asset/img/my_icon.png'),
      ),  
      nextScreen: const OnboardingScreen(), 
      duration: 2000, //4000
      backgroundColor: AppTheme().whiteColor, //real image color
      centered: true,
      splashIconSize: 500.h,  //700,
      splashTransition: SplashTransition.fadeTransition,
      animationDuration: const Duration(seconds: 2),  //2
    );
  }
}
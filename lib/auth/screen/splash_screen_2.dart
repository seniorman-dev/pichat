import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Ezio/main_page/screen/main_page.dart';
import 'package:Ezio/theme/app_theme.dart';







class SplashePage2 extends StatelessWidget {
  const SplashePage2({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Center(
        child: Image.asset('asset/img/my_icon.png'),
      ), 
      nextScreen: const MainPage(), 
      duration: 2000, //4000
      backgroundColor: AppTheme().whiteColor, //real image color
      centered: true,
      splashIconSize: 500.h,  //700,
      splashTransition: SplashTransition.fadeTransition,
      animationDuration: const Duration(seconds: 2),  //2
    );
  }
}
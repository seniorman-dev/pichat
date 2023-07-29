import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pichat/auth/controller/auth_controller.dart';
import 'package:pichat/auth/screen/login_screen.dart';
import 'package:pichat/main_page/screen/main_page.dart';
import 'package:pichat/theme/app_theme.dart';
import 'package:pichat/utils/loader.dart';
import 'package:provider/provider.dart';








class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});
  final bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    var controller = Provider.of<AuthController>(context);
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppTheme().whiteColor,
        //appBar: CustomAppBar(title: 'Created Events'),
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(), //ClampingScrollPhysics(),
          child: buildBody(context),
        ),
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    final size = MediaQuery.of(context).size;
    var controller = Provider.of<AuthController>(context);
    return Stack(
      children: [
        //custom background
        SizedBox(
          height: size.height,
          width: size.width,
          child: Column(
            children: [
              Container(
                height: 480.h, //450.h
                decoration: BoxDecoration(
                  color: AppTheme().whiteColor, 
                  // put the exact color later
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40.r),
                    bottomRight: Radius.circular(40.r),
                  )
                ),
              )
            ],
          )
        ),

        //body
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 40.w, //25.w
            vertical: 20.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment. center,
            children: [           
              //SizedBox(height: 500.h,),
              SizedBox(height: 80.h,),
              Image.asset('asset/img/nice.jpg'),
              SizedBox(height: 70.h,),            
              Text(
                'Enjoy the awesome experience of\n     chatting with friends globally',
                style: GoogleFonts.poppins(
                  color: AppTheme().blackColor,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold
                ),
              ),
              SizedBox(height: 20.h,),
              Text(
                'Connect with people round the \n        globe with just one tap',
                style: GoogleFonts.poppins(
                  color: AppTheme().darkGreyColor,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500
                ),
              ),
              SizedBox(height: 50.h,),
              SizedBox(
                height: 70.h,
                width: double.infinity,
                child: OutlinedButton( 
                  onPressed: () {
                    Get.offAll(() => LoginScreen());
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 3,
                    backgroundColor: AppTheme().mainColor,
                    minimumSize: Size.copy(Size(100.w, 50.h)),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 3,
                        style: BorderStyle.solid,
                        color: AppTheme().mainColor
                      ),
                      borderRadius: BorderRadius.circular(30.r),
                    )
                  ), 
                  /*icon: Icon(
                    CupertinoIcons.rotate_right,
                    color: AppTheme().whiteColor,
                  ),*/  //use google photo
                  child: Text(
                    'Get Started',
                    style: TextStyle(
                      color: AppTheme().whiteColor,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500
                    ),
                  ),
                ),     
              ),
              SizedBox(height: 20.h,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Powered by',
                    style: GoogleFonts.poppins(
                      color: AppTheme().blackColor,
                      fontSize: 12.sp,
                      //fontWeight: FontWeight.w500
                    ),
                  ),
                  SizedBox(width: 4.w,),
                  Text(
                    'J e t i f y',
                    style: GoogleFonts.poppins(
                      color: AppTheme().mainColor,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500
                    ),
                  ),
                ],
              )
            ]
          )
        )
      ]
    );
  }
}
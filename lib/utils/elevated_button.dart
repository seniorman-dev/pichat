import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pichat/theme/app_theme.dart';





class CustomElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  const CustomElevatedButton({Key? key, required this.text, required this.onPressed,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70.h,
      width: double.infinity,
      child: ElevatedButton( 
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 3,
          backgroundColor: AppTheme().mainColor,
          minimumSize: Size.copy(Size(100.w, 50.h)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          )
        ), 
        child: Text(
          text,
          style: TextStyle(
            color: AppTheme().whiteColor,
            fontSize: 16.sp,
            fontWeight: FontWeight.w500
          ),
        ),
      ),     
    );
  
  }
}

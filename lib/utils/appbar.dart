import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Ezio/theme/app_theme.dart';




class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
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
      title: Text(
        title
      ),
      titleSpacing: 2,
      titleTextStyle: GoogleFonts.poppins(
        textStyle: TextStyle(
          color: AppTheme().blackColor,
          fontSize: 15.sp,
          fontWeight: FontWeight.w500
        )
      ),
    );
  }

  Size get preferredSize => Size.fromHeight(40.h); //60.h
}
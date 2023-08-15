import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pichat/theme/app_theme.dart';





Future<void> getToast({required BuildContext context, required String text}) async {
  final snackBar = SnackBar(
    //action: SnackBarAction(label: label, onPressed: onPressed),
    duration: Duration(milliseconds: 2000),
    dismissDirection: DismissDirection.down,
    behavior: SnackBarBehavior.fixed,
    //shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(5.r)),
    elevation: 0,
    backgroundColor: AppTheme().opacityBlue,
    content: Text(
      textAlign: TextAlign.center,
      text,
      style: GoogleFonts.poppins(
        color: AppTheme().blackColor,
        fontSize: 13.sp,
        fontWeight: FontWeight.normal,
        textStyle: TextStyle(
          overflow: TextOverflow.ellipsis
        )
      ),
    )
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
  debugPrint("Toast message: $text");
}
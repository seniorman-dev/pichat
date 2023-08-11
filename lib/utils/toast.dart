import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pichat/theme/app_theme.dart';





Future<void> getToast({required BuildContext context, required String text}) async {
  final snackBar = SnackBar(
    backgroundColor: AppTheme().whiteColor, //.lightestOpacityBlue,
    content: Text(
      text,
      style: GoogleFonts.poppins(
        color: AppTheme().blackColor
      ),
    )
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
  debugPrint("Toast message: $text");
}
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pichat/theme/app_theme.dart';


Future<void> customGetXSnackBar({required String title, required String subtitle}) async{
  Get.snackbar(title, subtitle, duration: const Duration(seconds: 3), isDismissible: true, colorText: Colors.black, borderRadius: 20.r, backgroundColor: AppTheme().opacityBlue, snackPosition: SnackPosition.BOTTOM, dismissDirection: DismissDirection.down);
}
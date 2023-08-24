import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:Ezio/theme/app_theme.dart';




class ErrorLoader extends StatelessWidget {
  const ErrorLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LoadingAnimationWidget.inkDrop(
        color: AppTheme().redColor, 
        size: 30.r,
      ),
    );
  }
}

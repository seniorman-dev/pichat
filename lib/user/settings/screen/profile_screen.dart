import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pichat/auth/controller/auth_controller.dart';
import 'package:pichat/theme/app_theme.dart';
import 'package:pichat/utils/loader.dart';
import 'package:provider/provider.dart';






class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
  
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
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 25.w,
        vertical: 20.h,
      ),
      child: Column(
        children: [
          Center(
            child: IconButton(
              onPressed: () {
                controller.signOut();
              }, 
              icon: Icon(Icons.logout_rounded),
              color: AppTheme().mainColor,
            ),
          )
        ]
      ),
    );
  }
}
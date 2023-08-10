import 'package:pichat/user/settings/widget/connects.dart';
import 'package:pichat/user/settings/widget/posts.dart';
import 'package:pichat/user/settings/widget/re-posts.dart';
import 'package:pichat/utils/error_loader.dart';
import 'package:pichat/utils/loader.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pichat/auth/controller/auth_controller.dart';
import 'package:pichat/theme/app_theme.dart';










class ViewPostsScreen extends StatefulWidget {
  const ViewPostsScreen({super.key});

  @override
  State<ViewPostsScreen> createState() => _ViewPostsScreenState();
}

class _ViewPostsScreenState extends State<ViewPostsScreen> with SingleTickerProviderStateMixin{
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppTheme().whiteColor,
        appBar: AppBar(
          backgroundColor: AppTheme().whiteColor,
          centerTitle: true,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded),
            color: AppTheme().blackColor,
            onPressed: () {
              Get.back();
            },
          ),
          title: const Text(
            'Activities'
          ),
          titleSpacing: 2,
          titleTextStyle: GoogleFonts.poppins(
            textStyle: TextStyle(
              color: AppTheme().blackColor,
              fontSize: 15.sp,
              fontWeight: FontWeight.w500
            )
          ),
        ),
        body: SingleChildScrollView(
          physics: const ClampingScrollPhysics(), //BouncingScrollPhysics(),
          child: buildBody(context),
        ),
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    return _tabSection(context);
    /*Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20.h,),
        //Tab Bar Next
        _tabSection(context)
      ],
    );*/
  }

  Widget _tabSection(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[           
          TabBar(
            isScrollable: false,
            physics: const BouncingScrollPhysics(),
            labelColor: AppTheme().mainColor,
            unselectedLabelColor: AppTheme().greyColor,
            indicatorColor: AppTheme().mainColor,
            indicatorSize: TabBarIndicatorSize.label, 
            splashBorderRadius: BorderRadius.circular(20.r),      
            tabs: [
              Tab(
                child: Text(
                  'Posts',
                  style: GoogleFonts.poppins(  //urbanist
                    //color: AppTheme().blackColor,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500
                  ),
                ),
              ),
              Tab(
                child: Text(
                  'Re-posts',
                  style: GoogleFonts.poppins(  //urbanist
                    //color: AppTheme().blackColor,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500
                  ),
                ),
              ),
              Tab(
                child: Text(
                  'Connects',
                  style: GoogleFonts.poppins(  //urbanist
                    //color: AppTheme().blackColor,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500
                  ),
                ),
              ),
            ]
          ),  
          SizedBox( 
            //Add this to give height
            height: MediaQuery.of(context).size.height,
            child: TabBarView(
              //controller: TabController(length: 3, vsync: this),
              physics: BouncingScrollPhysics(),
              children: [           
                MyPosts(),              
                RePosts(),
                MyConnects()
            ]
          ),
        ),
      ],
    ),
  );
}
}
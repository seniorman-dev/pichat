import 'package:Ezio/user/settings/widget/activities/connects.dart';
import 'package:Ezio/user/settings/widget/activities/posts.dart';
import 'package:Ezio/user/settings/widget/activities/re-posts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Ezio/theme/app_theme.dart';










class ViewPostsScreen extends StatefulWidget {
  const ViewPostsScreen({super.key});

  @override
  State<ViewPostsScreen> createState() => _ViewPostsScreenState();
}

class _ViewPostsScreenState extends State<ViewPostsScreen> with TickerProviderStateMixin {

  @override
  Widget build(BuildContext context) {

    //tabbar controller
    TabController tabBarController = TabController(length: 3, vsync: this);

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppTheme().whiteColor,
        appBar: AppBar(
          backgroundColor: AppTheme().whiteColor,
          centerTitle: true,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
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
 
          bottom: TabBar(
            controller: tabBarController,
            isScrollable: true,
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
                  'Saves',
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
       ),
        body: SafeArea(
          //physics: NeverScrollableScrollPhysics(), //BouncingScrollPhysics(),
          child: _tabSection(context, tabBarController),
        ),
      ),
    );
  }
  Widget _tabSection(BuildContext context, TabController tabBarController) {
    return TabBarView(
      physics: const BouncingScrollPhysics(),
      controller: tabBarController,
      children: const [
        MyPosts(),              
        RePosts(),
        MyConnects()     
      ],
    );
  }
}






import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pichat/auth/controller/auth_controller.dart';
import 'package:pichat/theme/app_theme.dart';
import 'package:pichat/user/settings/widget/connects.dart';
import 'package:pichat/user/settings/widget/posts.dart';
import 'package:pichat/user/settings/widget/re-posts.dart';
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
          physics: const ClampingScrollPhysics(), //BouncingScrollPhysics(),
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
                height: 350.h, //450.h
                decoration: BoxDecoration(
                  color: AppTheme().opacityBlue, //.lightestOpacityBlue, 
                  // put the exact color later
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30.r),
                    bottomRight: Radius.circular(30.r),
                  )
                ),
              )
            ],
          )
        ),

        //body
      
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 80.h,),
              /*IconButton(
                onPressed: () => controller.signOut(), 
                icon: Icon(Icons.logout_rounded)
              )*/
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 25.w,
                  vertical: 20.h,
                ),
                child: Container(             
                  //height: 209.h,
                  //width: 200.w,
                  padding: EdgeInsets.symmetric(
                    vertical: 25.h, //20.h
                    horizontal: 18.w  //15.h
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme().whiteColor,
                    borderRadius: BorderRadius.circular(30.r), //20.r
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 0.1.r,
                        blurRadius: 8.0.r,
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          //profilePic
                          CircleAvatar(
                            radius: 40.r,
                            backgroundColor: AppTheme().opacityBlue,
                            child: CircleAvatar(
                              radius: 38.r,
                              backgroundColor: AppTheme().darkGreyColor,
                            ),
                          ),
                          SizedBox(width: 10.w,),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                //1
                                Column(
                                  children: [
                                    Text(
                                      //posts
                                      '93330',
                                      style: GoogleFonts.poppins(
                                        color: AppTheme().greyColor,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                        textStyle: const TextStyle(
                                          overflow: TextOverflow.ellipsis
                                        )
                                      ),
                                    ),
                                    SizedBox(height: 10.h),
                                    Text(
                                      'Posts',
                                      style: GoogleFonts.poppins(
                                        color: AppTheme().blackColor,
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w500
                                      ),
                                    ),
                                  ],
                                ),
                                //2
                                Column(
                                  children: [
                                    Text(
                                      //reports
                                      '93330',
                                      style: GoogleFonts.poppins(
                                        color: AppTheme().greyColor,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                        textStyle: const TextStyle(
                                          overflow: TextOverflow.ellipsis
                                        )
                                      ),
                                    ),
                                    SizedBox(height: 10.h),
                                    Text(
                                      'Re-posts',
                                      style: GoogleFonts.poppins(
                                        color: AppTheme().blackColor,
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w500
                                      ),
                                    ),
                                  ],
                                ),
                                //2
                                Column(
                                  children: [
                                    //connects
                                    Text(
                                      '93330',
                                      style: GoogleFonts.poppins(
                                        color: AppTheme().greyColor,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                        textStyle: const TextStyle(
                                          overflow: TextOverflow.ellipsis
                                        )
                                      ),
                                    ),
                                    SizedBox(height: 10.h),
                                    Text(
                                      'Connects',
                                      style: GoogleFonts.poppins(
                                        color: AppTheme().blackColor,
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w500
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          )
                        ],
                      ),
                      SizedBox(height: 20.h,),
                      //my name
                      Text(
                        'Japhet Ebele',
                        style: GoogleFonts.poppins(
                          color: AppTheme().blackColor,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500
                        ),
                      ),
                      SizedBox(height: 10.h,),
                      //about me
                      Text(
                        '93330ffgfgfh\ngghgjjghjgjgkhhh',
                        style: GoogleFonts.poppins(
                          color: AppTheme().greyColor, //.darkGreyColor,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                            textStyle: const TextStyle(
                              overflow: TextOverflow.visible
                            )
                        ),
                      ),
                      SizedBox(height: 15.h,),
                      //link to other socials or sumtin
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            CupertinoIcons.link,
                            color: AppTheme().mainColor, //opacityBlue,
                            size: 20.r,
                          ),
                          SizedBox(width: 5.w),
                          //use url launcher to launch this bitch
                          InkWell(
                            onTap: () {
                              controller.signOut();
                            },
                            child: Text(
                              'https://www.jetify.web.app',
                              style: GoogleFonts.poppins(
                                color: AppTheme().mainColor, //opacityBlue,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w500,
                                textStyle: const TextStyle(
                                  overflow: TextOverflow.ellipsis
                                )
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h,),
                      //Edit Profile Button and Share Profile Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          //Edit Profile
                          Expanded(
                            child: SizedBox(
                              height: 50.h,
                              width: 100.h, //double.infinity,
                              child: ElevatedButton( 
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: AppTheme().lightGreyColor,
                                  minimumSize: Size.copy(Size(100.w, 50.h)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.r),
                                  )
                                ), 
                                child: Text(
                                  'Edit Profile',
                                  style: GoogleFonts.poppins(  //urbanist
                                    color: AppTheme().blackColor,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500
                                  ),
                                ),
                              ),     
                            ),
                          ),
                          SizedBox(width: 10.w,),
                          //Share Profile
                          Expanded(
                            child: SizedBox(
                              height: 50.h,
                              width: 100.w, //double.infinity,
                              child: ElevatedButton( 
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: AppTheme().lightGreyColor,
                                  minimumSize: Size.copy(Size(100.w, 50.h)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.r),
                                  )
                                ), 
                                child: Text(
                                  'Share Profile',
                                  style: GoogleFonts.poppins(  //urbanist
                                    color: AppTheme().blackColor,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500
                                  ),
                                ),
                              ),     
                            ),
                          )
                        ],
                      )
                                                                                                              
                    ]
                  )
                ),
              ),
              SizedBox(height: 30.h,),
              /////////////////////////
              //Tab Bar Next
               _tabSection(context)
            ]
          )

      ]
    );    
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
            tabs: [
              Tab(
                child: Text(
                  'My Posts',
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
            child: const TabBarView(
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
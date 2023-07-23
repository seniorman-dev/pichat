import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pichat/theme/app_theme.dart';






class AllUsersList extends StatefulWidget {
  const AllUsersList({super.key});

  @override
  State<AllUsersList> createState() => _AllUsersListState();
}

class _AllUsersListState extends State<AllUsersList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme().whiteColor,
        centerTitle: true,
        elevation: 0,
        leading: SizedBox(
          height: 50.h,
          width: 85.w,
          child: IconButton(
            onPressed: () {
              Get.back();
            }, 
            icon: Icon(
              CupertinoIcons.back,
              color: AppTheme().blackColor,
              size: 30.r,
            ),
          ),
        ),
        title: const Text(
          'Find Connects'
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
      backgroundColor: AppTheme().whiteColor,
      body: ListView.separated(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        separatorBuilder: (context, index) => SizedBox(height: 5.h,), 
        itemCount: 20,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 25.w,
              vertical: 0.h
            ),
            child: Column(
              children: [
                SizedBox(height: 30.h,),
                Container(
                  height: 100.h,
                  padding: EdgeInsets.symmetric(
                    vertical: 15.h, //20.h
                    horizontal: 15.w  //20.h
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme().whiteColor,
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 0.1.r,
                        blurRadius: 8.0.r,
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      //profilePic
                      CircleAvatar(
                        radius: 32.r,
                        backgroundColor: AppTheme().opacityBlue,
                        child: CircleAvatar(
                          radius: 30.r,
                          backgroundColor: AppTheme().darkGreyColor,
                        ),
                      ),
                      SizedBox(width: 10.w,),
                      //details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mike Angelo',
                              style: GoogleFonts.poppins(
                                color: AppTheme().blackColor,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500
                              ),
                            ),
                            SizedBox(height: 4.h,),
                            //Row 2
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'offline',
                                  style: GoogleFonts.poppins(
                                    color: AppTheme().darkGreyColor, //specify color when user is online or offline
                                    fontSize: 14.sp, //14.sp
                                    fontWeight: FontWeight.w500,
                                    textStyle: const TextStyle(
                                      overflow: TextOverflow.ellipsis
                                    )
                                  ),
                                ),
                                SizedBox(
                                  height: 35.h,
                                  width: 80.w,
                                  child: ElevatedButton.icon(       
                                    icon: Icon(
                                      CupertinoIcons.person_crop_circle_fill_badge_plus,
                                      color: AppTheme().whiteColor,
                                      size: 18.r,
                                    ), 
                                    onPressed: () {}, 
                                    label: Text(
                                      'Add',
                                      style: GoogleFonts.poppins(
                                        textStyle: TextStyle(
                                          color: AppTheme().whiteColor,
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.w500
                                        )
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      elevation: 2,
                                      backgroundColor: AppTheme().mainColor,
                                      minimumSize: Size.copy(Size(100.w, 50.h)),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.r),
                                      )
                                    ),
                                  ),     
                                )
                              ],
                            )
                          ]
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }, 
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pichat/theme/app_theme.dart';







class CallScreen extends StatelessWidget {
  const CallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppTheme().whiteColor,
        appBar: AppBar(
          backgroundColor: AppTheme().whiteColor,
          centerTitle: true,
          elevation: 0,
          title: Text(
            'Calls'
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
          physics: BouncingScrollPhysics(),
          child: buildBody(context),
        )
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 25.w,
        vertical: 20.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 10.h,),
          ListView.separated(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            separatorBuilder: (context, index) => SizedBox(height: 20.h,), 
            itemCount: 10,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {},
                child: Container(
                  //height: 100.h,
                  //width: 200.w,
                  padding: EdgeInsets.symmetric(
                    vertical: 15.h, //30.h
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
                            //Row 1
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Mike Angelo',
                                  style: GoogleFonts.poppins(
                                    color: AppTheme().blackColor,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500
                                  ),
                                ),
                                Text(
                                  '12:09',
                                  style: GoogleFonts.poppins(
                                    color: AppTheme().darkGreyColor,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500
                                  ),
                                )
                              ],
                            ),
                            SizedBox(height: 4.h,),
                            //Row 2
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Session ID: 100000',
                                  style: GoogleFonts.poppins(
                                    color: AppTheme().darkGreyColor,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                    textStyle: TextStyle(
                                      overflow: TextOverflow.ellipsis
                                    )
                                  ),
                                ),
                                Icon(
                                  CupertinoIcons.phone_fill_arrow_up_right,
                                  color: AppTheme().greenColor,
                                )
                              ],
                            )
                          ]
                        ),
                      ),
                    ],
                  ),
                ),           
              );
            }
          ),
        ]
      )
    );
  }
}
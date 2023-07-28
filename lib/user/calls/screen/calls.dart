import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pichat/auth/controller/auth_controller.dart';
import 'package:pichat/theme/app_theme.dart';
import 'package:pichat/utils/error_loader.dart';
import 'package:pichat/utils/firestore_timestamp_formatter.dart';
import 'package:pichat/utils/loader.dart';
import 'package:provider/provider.dart';







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
    var authController = Provider.of<AuthController>(context);
    return StreamBuilder(
      stream: authController.firestore.collection('users').doc(authController.userID).collection('calls').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator while waiting for data
          return Loader();
        } 
        else if (snapshot.hasError) {
          // Handle error if any
          return ErrorLoader();
        }
        else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 25.w,
              vertical: 20.h,
            ),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                //mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 210.h,),
                  CircleAvatar(
                    radius: 100.r,
                    backgroundColor: AppTheme().lightestOpacityBlue,
                    child: Icon(
                      CupertinoIcons.phone_down,
                      color: AppTheme().mainColor,
                      size: 70.r,
                    ),
                  ),
                  SizedBox(height: 50.h),
                  Text(
                    "You haven't made any calls yet",
                    style: GoogleFonts.poppins(
                      color: AppTheme().greyColor,
                      fontSize: 14.sp,
                      //fontWeight: FontWeight.w500
                    ),
                  )
                ],
              ),
            ),
          );
        }
        else {
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
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var data = snapshot.data!.docs[index];
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
                                radius: 30.r,    //data['photo']
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
                                        data['name'],
                                        style: GoogleFonts.poppins(
                                          color: AppTheme().blackColor,
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w500
                                        ),
                                      ),
                                      Text(
                                        "${formatDate(timestamp: data['timestamp'])}-${formatTime(timestamp: data['timestamp'])}",
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
                                        data['session_id'],  //'Session ID: 100000',
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
    );
  }
}
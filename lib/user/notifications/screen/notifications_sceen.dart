import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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







class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
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
            onPressed: () {
              Get.back();
            }, 
            icon: Icon(
              CupertinoIcons.back,
              color: AppTheme().blackColor,
              size: 30.r,
            )
          ),
          title: Text(
            'Notifications'
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
      stream: authController.firestore.collection('users').doc(authController.userID).collection('notifications').snapshots(),
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
                      CupertinoIcons.bell,
                      color: AppTheme().mainColor,
                      size: 70.r,
                    ),
                  ),
                  SizedBox(height: 50.h),
                  Text(
                    "You don't have any notifications currently",
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
              /*controller.notificationsList.isEmpty
              //when the document snapshot list in the database is empty
              ?Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 150.h,),       
                    //SvgPicture.asset('assets/svg/consultation_empty.svg'),
                    CircleAvatar(
                      backgroundColor: AppTheme.opacityOfMainColor.withOpacity(0.3),
                      radius: 150.r,
                      child: Icon(
                        Icons.notifications_on_rounded,
                        color: AppTheme.mainColor, //.withOpacity(0.5),
                        size: 150.h,
                      ),
                    ),
                    SizedBox(height: 20.h,),
                    Text(
                      "You currently do not have any notifications.",
                      style: TextStyle(
                        color: AppTheme.blackColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 18.sp,
                      ),
                    ),            
                    SizedBox(height: 40.h,),
                  ]
                ), 
              )
              //when the document snapshot list in the database is not empty
              :*/
              ListView.separated(
                scrollDirection: Axis.vertical,
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                separatorBuilder: (context, index) {
                  return SizedBox(height: 20.h,);
                },
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var data = snapshot.data!.docs[index];
                  return Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 15.h, //15.h
                      horizontal: 15.w, //21.w
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xffD3C2C2).withOpacity(0.5),
                          spreadRadius: 0.1.r,
                          blurRadius: 10.0.r,
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        //icon
                        Container(
                          height: 50.h,
                          width: 40.w,
                          alignment: Alignment.center,
                          /*padding: EdgeInsets.symmetric(
                            vertical: 18.h,                  
                            horizontal: 18.w
                          ),*/
                          decoration: BoxDecoration(
                            color: AppTheme().opacityBlue.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(15.r),
                          ),
                          child: Icon(
                            CupertinoIcons.bell_fill,
                            color: AppTheme().mainColor,
                          )                   
                        ),
                        SizedBox(width: 15.w),  //just incase it's needed
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //title
                            Text(
                              data['title'],
                              style: GoogleFonts.poppins(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w500,
                                color: AppTheme().blackColor
                              ),
                            ),
                            SizedBox(height: 10.h),
                            //subtitle
                            Text(
                              data['body'],
                              style: GoogleFonts.poppins(
                                fontSize: 12.sp,
                                //fontWeight: FontWeight.w500,
                                color: AppTheme().blackColor,
                                textStyle: TextStyle(
                                  overflow: TextOverflow.ellipsis
                                )
                              ),
                            ),
                            SizedBox(height: 6.h),
                            //date
                            Text(
                              formatDate(timestamp: data['timestamp']),
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.normal,
                                color: AppTheme().darkGreyColor
                              ),
                            ),
                            SizedBox(height: 4.h),
                            //time
                            Text(
                              formatTime(timestamp: data['timestamp']),
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.normal,
                                color: AppTheme().darkGreyColor
                              ),
                            )
                          ],
                        )
                      ]
                    )
                  );
                },
              ),
            ]
          )
        );
        }
      }
    );
  }
}
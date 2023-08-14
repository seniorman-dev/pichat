import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pichat/auth/controller/auth_controller.dart';
import 'package:pichat/theme/app_theme.dart';
import 'package:pichat/user/notifications/controller/notifications_controller.dart';
import 'package:pichat/utils/error_loader.dart';
import 'package:pichat/utils/firestore_timestamp_formatter.dart';
import 'package:pichat/utils/loader.dart';
import 'package:provider/provider.dart';








class NotificationScreenForProfile extends StatefulWidget {
  const NotificationScreenForProfile({super.key});

  @override
  State<NotificationScreenForProfile> createState() => _NotificationScreenForProfileState();
}

class _NotificationScreenForProfileState extends State<NotificationScreenForProfile> {
  bool showDateHeader = true;
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
          title: const Text(
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
          physics: const BouncingScrollPhysics(),
          child: buildBody(context),
        )
      ),
    );
  }

  Widget buildBody(BuildContext context) {

    var authController = Provider.of<AuthController>(context);
    var notificationsCntroller = Provider.of<NotificationsController>(context);

    return StreamBuilder(
      stream: authController.firestore.collection('users').doc(authController.userID).collection('notifications').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator while waiting for data
          return const Loader();
        } 
        else if (snapshot.hasError) {
          // Handle error if any
          return const ErrorLoader();
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
            vertical: 5.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ///SizedBox(height: 10.h,),
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

                  // Check if the current message's date is different from the previous message's date
                  if (index > 0) {
                    var previousData = snapshot.data!.docs[index - 1];
                    var currentDate = formatDate(timestamp: data['timestamp']);
                    var previousDate = formatDate(timestamp: previousData['timestamp']);
                    showDateHeader = currentDate != previousDate;
                  }
                  
                  return Column(
                    children: [
                      //Show the date header if needed
                      if (showDateHeader)
                        Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 30.h, 
                              horizontal: 120.w
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              height: 30.h,
                              //width: 150.w,
                              padding: EdgeInsets.symmetric(
                                //vertical: 0.h, //20.h
                                horizontal: 5.w  //15.h
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme().lightGreyColor,
                                borderRadius: BorderRadius.circular(10.r),
                                /*boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    //color: AppTheme().lightGreyColor,
                                    spreadRadius: 0.1.r,
                                    blurRadius: 8.0.r,
                                  )
                                ],*/
                              ),
                              child: Text(
                                formatDate(timestamp: data['timestamp']),
                                style: GoogleFonts.poppins(
                                  color: Colors.grey,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),

                      SizedBox(height: 10.h),


                      //the list gan gan
                      Dismissible(
                      key: UniqueKey(),
                      direction: DismissDirection.endToStart,
                      background: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(
                            CupertinoIcons.delete_simple,
                            color: AppTheme().redColor,
                          )
                        ],
                      ),
                      onDismissed: (direction) {
                        notificationsCntroller.deleteNotification();
                      },
                      child: Container(
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
                                    textStyle: const TextStyle(
                                      overflow: TextOverflow.ellipsis
                                    )
                                  ),
                                ),
                                SizedBox(height: 6.h),
                                //date & time 
                                Text(
                                  formatTime(timestamp: data['timestamp']),
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.normal,
                                    color: AppTheme().darkGreyColor
                                  ),
                                ),
                              ],
                            )
                          ]
                        )
                      ),
                  )
                    ],
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
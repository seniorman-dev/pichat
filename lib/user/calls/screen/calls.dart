import 'package:Ezio/utils/extract_firstname.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Ezio/auth/controller/auth_controller.dart';
import 'package:Ezio/theme/app_theme.dart';
import 'package:Ezio/utils/error_loader.dart';
import 'package:Ezio/utils/firestore_timestamp_formatter.dart';
import 'package:Ezio/utils/loader.dart';
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
          title: const Text(
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
          physics: const BouncingScrollPhysics(),
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
                      CupertinoIcons.phone,
                      color: AppTheme().mainColor,
                      size: 70.r,
                    ),
                  ),
                  SizedBox(height: 50.h),
                  Text(
                    "No call sessions found",
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
                //SizedBox(height: 10.h,),
                ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  separatorBuilder: (context, index) => SizedBox(height: 30.h,), 
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var data = snapshot.data!.docs[index];
                    bool showDateHeader = true;
                    if (index > 0) {
                      var previousData = snapshot.data!.docs[index - 1];
                      var currentDate = formatDate(timestamp: data['timestamp']);
                      var previousDate = formatDate(timestamp: previousData['timestamp']);
                      showDateHeader = currentDate != previousDate;
                    }

                    return InkWell(
                      onTap: () {},
                      child: Dismissible(
                        key: UniqueKey(),
                        direction: DismissDirection.endToStart,
                        background: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(
                              CupertinoIcons.delete_simple,
                              color: AppTheme().redColor                     
                            )
                          ]
                        ),
                        onDismissed: (direction) async{
                          authController
                          .firestore
                          .collection('users')
                          .doc(authController.userID)
                          .collection('calls')
                          .doc(data['sessionId'])
                          .delete();
                        },
                        child: Column(
                          children: [
                            // Show the date header if needed
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


                            ///
                            Container(
                              //height: 100.h,
                              //width: 200.w,
                              padding: EdgeInsets.symmetric(
                                vertical: 15.h, //15.h
                                horizontal: 15.w  //15.w
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme().whiteColor,
                                borderRadius: BorderRadius.circular(30.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 0.1.r,
                                    blurRadius: 8.0.r,
                                  )
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  //profilePic
                                  CircleAvatar(
                                    radius: 32.r,
                                    backgroundColor: AppTheme().blackColor,
                                    child: CircleAvatar(
                                      backgroundColor: AppTheme().blackColor,
                                      radius: 30.r,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.all(Radius.circular(10.r)), //.circular(20.r),
                                        clipBehavior: Clip.antiAlias, //.antiAliasWithSaveLayer,
                                        child: CachedNetworkImage(
                                          imageUrl: data['receiverProfilePic'],
                                          width: 45.w,
                                          height: 45.h,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => Loader(),
                                          errorWidget: (context, url, error) => Icon(
                                            Icons.error,
                                            color: AppTheme().lightestOpacityBlue,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10.w,),
                                  //details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              getFirstName(fullName: data['name']),
                                              //getFirstName(fullName: data['name'],),
                                              style: GoogleFonts.poppins(
                                                color: AppTheme().blackColor,
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w500
                                              ),
                                            ),
                                            Text(
                                              formatTime(timestamp: data['timestamp']),
                                              style: GoogleFonts.poppins(
                                                color: AppTheme().greyColor,
                                                fontSize: 10.sp,
                                                fontWeight: FontWeight.normal
                                              ),
                                            )
                                          ],
                                        ),
                                        SizedBox(height: 4.h,),
                                        Text(
                                          'session id: ${data['sessionId']}',  //'Session ID: 100000',
                                          style: GoogleFonts.poppins(
                                          color: AppTheme().greyColor,
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.normal,
                                            textStyle: const TextStyle(
                                              overflow: TextOverflow.ellipsis
                                            )
                                          ),
                                        ),
                                        
                                      ]
                                    ),
                                  ),
                                  SizedBox(width: 10.w,),
                                  data['type'] == 'audio' ?
                                  CircleAvatar(
                                    backgroundColor: AppTheme().greenColor.withOpacity(0.05),
                                    radius: 25.r,
                                    child: Icon(
                                      CupertinoIcons.phone_fill_arrow_up_right,
                                      size: 30.r,
                                      color: AppTheme().greenColor,
                                    ),
                                  )
                                  :CircleAvatar(
                                    backgroundColor: AppTheme().greenColor.withOpacity(0.05),
                                    radius: 25.r,
                                    child: Icon(
                                      CupertinoIcons.videocam_fill,
                                      size: 30.r,
                                      color: AppTheme().greenColor,
                                    ),
                                  )
                                ],
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
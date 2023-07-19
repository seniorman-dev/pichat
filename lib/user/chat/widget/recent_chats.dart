import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pichat/theme/app_theme.dart';
import 'package:pichat/user/chat/screen/dm_screen.dart';





class RecentChats extends StatelessWidget {
  const RecentChats({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        //separatorBuilder: (context, index) => SizedBox(height: 0.h,), 
        itemCount: 10,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              Get.to(() => DMScreen(
                isOnline: true, 
                receiverName: 'Mike Angelo',
                receiverProfilePic: 'https/fjfjfnvkdnkkvf',
                receiverID: '170313027',
              ));
            },
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 20.h,
                vertical: 8.w
              ),
              child: Container(
                height: 100.h,
                //width: 200.w,
                padding: EdgeInsets.symmetric(
                  vertical: 20.h, //30.h
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
                      radius: 30.r,
                      backgroundColor: AppTheme().darkGreyColor,
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
                                'Hey big man, what are you doing?',
                                style: GoogleFonts.poppins(
                                  color: AppTheme().darkGreyColor,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  textStyle: TextStyle(
                                    overflow: TextOverflow.ellipsis
                                  )
                                ),
                              ),
                              CircleAvatar(
                                backgroundColor: AppTheme().mainColor,
                                radius: 10.r,
                                child: Text(
                                  '2',
                                  style: GoogleFonts.poppins(
                                    textStyle: TextStyle(
                                      color: AppTheme().whiteColor,
                                      fontSize: 9.sp,
                                      //fontWeight: FontWeight.w500
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
            ),
          );
        }
      ),
    );
  }
}
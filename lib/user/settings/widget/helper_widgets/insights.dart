import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pichat/theme/app_theme.dart';






//Alert Dialog for insights page (coming soons)
  Future showInsightsDialogue(BuildContext context) async{
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme().whiteColor,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 30.w, //50.w
            vertical: 40.h, //50.h
          ),
          content: SizedBox(
            height: 280.h, //260.h,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 50.h,
                        width: 40.w,
                        alignment: Alignment.center,
                        /*padding: EdgeInsets.symmetric(
                          vertical: 18.h,
                          horizontal: 18.w
                        ),*/
                        decoration: BoxDecoration(
                          color: AppTheme().lightestOpacityBlue,  
                          borderRadius: BorderRadius.circular(15.r),
                          /*boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 0.1.r,
                              blurRadius: 8.0.r,
                            )
                          ],*/
                          //border: Border.all(color: AppTheme.opacityOfMainColor, width: 2)
                        ),
                        child: Icon(
                          CupertinoIcons.graph_square,
                          color: AppTheme().mainColor,
                        )                   
                      ),
                    ],
                  ),
                  SizedBox(height: 30.h,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Explore detailed statistics of your \naccount as it thrives.\n(Coming Soon👌)',
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                            overflow: TextOverflow.visible,
                          ),
                          color: AppTheme().blackColor, //.normalGreyColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 15.sp,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(
                    height: 40.h,
                  ),
                  
                  //OK Button
                  ElevatedButton(
                    onPressed: () {
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(15.r) //5.r
                        )
                      ),
                      side: BorderSide(
                        width: 1.5,
                        color: AppTheme().mainColor,
                        style: BorderStyle.solid
                      ),
                      backgroundColor: AppTheme().mainColor,
                      foregroundColor: AppTheme().mainColor,
                      minimumSize:const Size(double.infinity, 50)
                    ),
                    child: Text(
                      "OK",
                      style: GoogleFonts.poppins(
                        color: AppTheme().whiteColor,
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }
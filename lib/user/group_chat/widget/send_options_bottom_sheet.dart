import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Ezio/theme/app_theme.dart';










//takePhotoBottomSheet
Future<void> showSendOptionsBottomSheetForGroup({required BuildContext context, required VoidCallback onPressedForImage, required VoidCallback onPressedForVideo,}) async {
  //var chatServiceController = Provider.of<ChatServiceController>(context, listen: false);
  showModalBottomSheet(
    isScrollControlled: true,
    clipBehavior: Clip.antiAliasWithSaveLayer,
    elevation: 2,
    isDismissible: false,
    useSafeArea: true,
    backgroundColor: AppTheme().whiteColor, //.backgroundColor,
    //barrierColor: Theme.of(context).colorScheme.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(20)
      )
    ),
    context: context, 
    builder: (context) {
      return Wrap(
        children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          decoration: BoxDecoration(
            //image: DecorationImage(image: AssetImage(''),),
            color: AppTheme().whiteColor, //.backgroundColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40.r),
              topRight: Radius.circular(40.r),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: 50.w,
                child: Divider(
                  thickness: 4,
                  color: AppTheme().darkGreyColor,
                ),
              ),
              
              SizedBox(height: 20.h),

              Container(
                //color: Colors.white,
                //semanticContainer: true,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                //shape: RoundedRectangleBorder(
                  //borderRadius: BorderRadius.circular(10.0),
                //),
                //elevation: 2,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    ////////////////////////
                    InkWell(
                      onTap: onPressedForImage,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 15.w,
                          vertical: 20.h
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                borderRadius: BorderRadius.circular(15.r)
                              ),
                              child: Icon(
                                CupertinoIcons.camera_viewfinder,
                                color: AppTheme().mainColor,
                              )                   
                            ),
                            SizedBox(width: 20.w,),
                            Expanded(
                              child: Text(
                                'Photo',
                                style: TextStyle(
                                  color: AppTheme().blackColor,
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w500
                                ),
                              )
                            ),
                            Icon(
                              CupertinoIcons.forward,
                              size: 20.r,
                            )
                          ],
                        ),
                      ),
                    ),
                    /////////////////
                    SizedBox(
                      width: double.infinity,
                      child: Divider(
                        thickness: 1,
                        color: AppTheme().darkGreyColor,
                      ),
                    ),
                    ////////////////////////
                    InkWell(
                      onTap: onPressedForVideo,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 15.w,
                          vertical: 20.h
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                borderRadius: BorderRadius.circular(15.r)
                              ),
                              child: Icon(
                                CupertinoIcons.videocam,
                                color: AppTheme().mainColor,
                              )                   
                            ),
                            SizedBox(width: 20.w,),
                            Expanded(
                              child: Text(
                                'Video',
                                style: TextStyle(
                                  color: AppTheme().blackColor,
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w500
                                ),
                              )
                            ),
                            Icon(
                              CupertinoIcons.forward,
                              size: 20.r,
                            )
                          ],
                        ),
                      ),
                    ),
                    /////////////////
                  ],
                ),           
              ),

              SizedBox(height: 20.h), //50.h
            ],
          ),
        )
      ],
    );
    }
  );
}
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pichat/theme/app_theme.dart';







//takePhotoBottomSheet
Future<void> takePhotoBottomSheet({required BuildContext context, required VoidCallback onPressedForCamera, required VoidCallback onPressedForGallery, required VoidCallback onPressedForSavingImage}) async {
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
              SizedBox(height: 32.h),

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
                    Center(
                      child: TextButton(
                        onPressed: onPressedForCamera, 
                        child: Text(
                          'Take Photo',
                          style: TextStyle(
                            color: AppTheme().mainColor,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w500
                          ),
                        )
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: Divider(
                        thickness: 1,
                        color: AppTheme().darkGreyColor,
                      ),
                    ),
                    Center(
                      child: TextButton(
                        onPressed: onPressedForGallery,
                        child: Text(
                          'Select Photo From Gallery',
                          style: TextStyle(
                            color: AppTheme().mainColor,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w500
                          ),
                        )
                      ),
                    ),
                  ],
                ),           
              ),
              SizedBox(height: 50.h),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(
                    height: 70.h,
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme().mainColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        minimumSize: Size.copy(
                          Size(100.w, 55.h),
                        ),
                        maximumSize: Size.copy(
                          Size(100.w, 55.h),
                        ),
                      ),
                      onPressed: onPressedForSavingImage,
                      child: Text(
                        'Save Photo',
                        style: TextStyle(
                          color: AppTheme().whiteColor,
                          fontWeight: FontWeight.w500,  //.bold,
                          fontSize: 16.sp
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                ],
              ),
            ],
          ),
        )
      ],
    );
    }
  );
}
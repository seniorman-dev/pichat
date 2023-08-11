import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pichat/auth/screen/login_screen.dart';
import 'package:pichat/theme/app_theme.dart';
import 'package:pichat/utils/snackbar.dart';

  





  final FirebaseAuth firebase = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  User? get user => firebase.currentUser;
  String get userID => firebase.currentUser!.uid;
  String? get userDisplayName => firebase.currentUser!.displayName;
  String? get userEmail => firebase.currentUser!.email;


  //SIGN OUT METHOD
  Future<void> signOut() async {
    try {
      await firestore.collection('users').doc(userID).update({"isOnline": false});
      await firebase.signOut()
      .whenComplete(() => Get.offAll(() => LoginScreen()));
    } on FirebaseAuthException catch (e) {
      customGetXSnackBar(title: 'Uh-Oh!', subtitle: "${e.message}");
    }
  }



  ///Alert Dialog for get support page
  Future showLogoutDialogue(BuildContext context) {
    //var controller = Provider.of<AuthController>(context);
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
            height: 180.h,
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
                          Icons.logout_rounded,
                          color: AppTheme().mainColor,
                        )                   
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Are you sure you want to logout?',
                        style: TextStyle(
                          color: AppTheme().blackColor, //.normalGreyColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 15.sp
                        ),
                      ),
                    ],
                  ),

                  SizedBox(
                    height: 30.h,
                  ),
                  
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          width: 100,
                          child: ElevatedButton(
                            onPressed: () {
                              signOut();
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(15.0.r))
                              ),
                              side: BorderSide(
                                color: AppTheme().mainColor,
                                style: BorderStyle.solid
                              ),
                              backgroundColor: AppTheme().whiteColor,
                              foregroundColor: AppTheme().whiteColor,
                              minimumSize:const Size(double.infinity, 50)
                            ),
                            child: Text(
                              "Yes",
                              style: TextStyle(
                                color: AppTheme().mainColor,
                                fontSize: 16.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 20.h,
                      ),
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          width: 100,
                          child: ElevatedButton(
                            onPressed: () {
                              Get.back();
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(15.0.r)
                                )
                              ),
                              side: BorderSide(
                                color: AppTheme().mainColor,
                                  style: BorderStyle.solid
                              ),
                              backgroundColor: AppTheme().mainColor,
                              foregroundColor: AppTheme().mainColor,
                              minimumSize:const Size(double.infinity, 50)
                            ),
                            child: Text(
                              "No",
                              style: TextStyle(
                                color: AppTheme().whiteColor,
                                fontSize: 16.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ]
                  )
                ],
              ),
            ),
          ),
        );
      }
    );
  }
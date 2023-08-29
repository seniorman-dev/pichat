import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Ezio/auth/screen/login_screen.dart';
import 'package:Ezio/theme/app_theme.dart';
import 'package:Ezio/utils/snackbar.dart';

  





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
      .whenComplete(() => Get.offAll(() => const LoginScreen()));
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
            height: 210.h, //180.h
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 30.r,
                    backgroundColor: AppTheme().lightestOpacityBlue,  //.opacityBlue,
                    child: Icon(
                      Icons.logout_rounded,
                      size: 20.r,
                      color: AppTheme().mainColor,
                    )                   
                  ),
                  SizedBox(height: 20.h,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Are you sure you want to logout?',
                        style: GoogleFonts.poppins(
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
                          //width: 100,
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
                              style: GoogleFonts.poppins(
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
                          //width: 100,
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
                              style:  GoogleFonts.poppins(
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